#!/bin/bash
set -eu

if [ -z "${KAM_HOOKS_ROOT:-}" ]; then
    echo "[ERROR] KAM_HOOKS_ROOT environment variable is not defined" >&2
    exit 1
fi
. "$KAM_HOOKS_ROOT/lib/utils.sh"

require_command "gh" "Please install GitHub CLI and log in: https://cli.github.com/"
require_command "wget" "Please install wget"
require_command "tar" "Please install tar"
require_command "file" "Please install file"
require_command "sha256sum" "Please install sha256sum (required for hash verification)"

MODULE_ID="${KAM_MODULE_ID:-asl}"
VERSION_FILE="${KAM_MODULE_ROOT}/rurima.version"
HASH_FILE="${KAM_MODULE_ROOT}/rurima.hash"
DEST_DIR="${KAM_DIST_DIR}/rurima-bin"
EXEC_DEST="${KAM_MODULE_ROOT}/.local/bin"
EXEC_PATH="${EXEC_DEST}/rurima"
EXEC_TMP_PATH="${EXEC_DEST}/rurima.tmp"
VERSION_TMP_PATH="${KAM_MODULE_ROOT}/rurima.version.tmp"
HASH_TMP_PATH="${KAM_MODULE_ROOT}/rurima.hash.tmp"
ARCH="aarch64"
REPO="rurioss/rurima"
ASSET_NAME="${ARCH}.tar"

LOCAL_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "0.0.0")
LOCAL_HASH=$(cat "$HASH_FILE" 2>/dev/null || echo "0000000000000000000000000000000000000000000000000000000000000000")
log_info "[$MODULE_ID] Local status - Version: $LOCAL_VERSION | Hash: ${LOCAL_HASH:0:8}..."

log_info "[$MODULE_ID] Fetching latest remote tags..."
LATEST_TAG=$(gh api repos/"$REPO"/tags --jq '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
if [ -z "$LATEST_TAG" ]; then
    log_error "[$MODULE_ID] No valid remote tags found (must match vX.Y.Z format)"
    exit 1
fi
LATEST_VERSION=$(echo "$LATEST_TAG" | sed 's/^v//')
log_info "[$MODULE_ID] Latest remote version: $LATEST_VERSION (tag: $LATEST_TAG)"

if [ "$LOCAL_VERSION" = "$LATEST_VERSION" ]; then
    log_info "[$MODULE_ID] Local version matches remote, no update needed"
    mkdir -p "$DEST_DIR"
    cp "$VERSION_FILE" "$DEST_DIR/rurima.version" 2>/dev/null || true
    cp "$HASH_FILE" "$DEST_DIR/rurima.hash" 2>/dev/null || true
    exit 0
fi

log_info "[$MODULE_ID] Version mismatch (local:$LOCAL_VERSION → remote:$LATEST_VERSION), starting atomic update..."

cleanup() {
    rm -rf "$DEST_DIR" "$EXEC_TMP_PATH" "$VERSION_TMP_PATH" "$HASH_TMP_PATH"
    log_error "[$MODULE_ID] Update failed, all changes rolled back"
}
trap cleanup EXIT

rm -rf "$DEST_DIR" && mkdir -p "$DEST_DIR" "$EXEC_DEST" || {
    log_error "[$MODULE_ID] Failed to create directories ($DEST_DIR or $EXEC_DEST)"
    exit 1
}
cd "$DEST_DIR" || exit 1

log_info "[$MODULE_ID] Finding remote asset URL..."
ALL_ASSETS=$(gh api repos/"$REPO"/releases/tags/"$LATEST_TAG" --jq '.assets[] | {name: .name, url: .browser_download_url, sha256: .sha256}')
ASSET_INFO=$(echo "$ALL_ASSETS" | jq --arg name "$ASSET_NAME" '. | select(.name == $name)')

if [ -z "$ASSET_INFO" ] || [ "$ASSET_INFO" = "null" ]; then
    log_error "[$MODULE_ID] Remote asset not found: $ASSET_NAME (check asset name in release)"
    exit 1
fi

ASSET_URL=$(echo "$ASSET_INFO" | jq -r '.url')
REMOTE_HASH=$(echo "$ASSET_INFO" | jq -r '.sha256')

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
    log_error "[$MODULE_ID] Invalid asset URL (missing or null)"
    exit 1
fi

if [ -z "$REMOTE_HASH" ] || [ "$REMOTE_HASH" = "null" ] || [ ${#REMOTE_HASH} -ne 64 ]; then
    log_warn "[$MODULE_ID] GitHub official SHA256 not found, skipping official hash verification"
    REMOTE_HASH="skip"
fi

log_info "[$MODULE_ID] Downloading executable: $ASSET_URL"
wget -q --show-progress --progress=bar:force:noscroll -O "$ASSET_NAME" "$ASSET_URL" || {
    log_error "[$MODULE_ID] Failed to download executable"
    exit 1
}

if [ "$REMOTE_HASH" != "skip" ]; then
    log_info "[$MODULE_ID] Verifying file hash (GitHub official hash)..."
    LOCAL_DOWNLOAD_HASH=$(sha256sum "$ASSET_NAME" | awk '{print $1}')
    if [ "$LOCAL_DOWNLOAD_HASH" != "$REMOTE_HASH" ]; then
        log_error "[$MODULE_ID] Hash verification failed (local:${LOCAL_DOWNLOAD_HASH:0:8}... vs official:${REMOTE_HASH:0:8}...)"
        exit 1
    fi
    log_success "[$MODULE_ID] Official hash verification passed"
else
    log_info "[$MODULE_ID] Skipping hash verification (no official SHA256 provided)"
fi

tar -xf "$ASSET_NAME" && rm -f "$ASSET_NAME" rurima-dbg || {
    log_error "[$MODULE_ID] Extraction failed"
    exit 1
}
if [ ! -f "./rurima" ]; then
    log_error "[$MODULE_ID] Executable not found after extraction"
    exit 1
fi
mv ./rurima "$EXEC_TMP_PATH" || {
    log_error "[$MODULE_ID] Failed to deploy temporary file"
    exit 1
}

log_info "[$MODULE_ID] Verifying temporary deployed file..."
if ! file "$EXEC_TMP_PATH" | grep -qE "ELF.*64-bit.*executable"; then
    log_error "[$MODULE_ID] Temporary file verification failed: not a 64-bit ELF executable"
    exit 1
fi
TMP_FILE_HASH=$(sha256sum "$EXEC_TMP_PATH" | awk '{print $1}')
log_success "[$MODULE_ID] Temporary file verification passed"

log_info "[$MODULE_ID] Performing atomic replacement..."
echo "$LATEST_VERSION" > "$VERSION_TMP_PATH" || {
    log_error "[$MODULE_ID] Failed to write temporary version file"
    exit 1
}
echo "$TMP_FILE_HASH" > "$HASH_TMP_PATH" || {
    log_error "[$MODULE_ID] Failed to write temporary hash file"
    exit 1
}
mv -f "$EXEC_TMP_PATH" "$EXEC_PATH" || {
    log_error "[$MODULE_ID] Failed to atomically replace executable"
    exit 1
}
mv -f "$VERSION_TMP_PATH" "$VERSION_FILE" || {
    log_error "[$MODULE_ID] Failed to atomically replace version file"
    exit 1
}
mv -f "$HASH_TMP_PATH" "$HASH_FILE" || {
    log_error "[$MODULE_ID] Failed to atomically replace hash file"
    exit 1
}

cp "$VERSION_FILE" "$DEST_DIR/rurima.version"
cp "$HASH_FILE" "$DEST_DIR/rurima.hash"

trap - EXIT
log_success "[$MODULE_ID] Atomic update completed successfully!"
log_success "  - Deployment path: $EXEC_PATH"
log_success "  - Version synced: $LOCAL_VERSION → $LATEST_VERSION"
log_success "  - Stored hash: ${TMP_FILE_HASH:0:8}..."

# remove ririma-bin/
rm -rf "$DEST_DIR"

exit 0
