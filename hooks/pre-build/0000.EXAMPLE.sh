#!/bin/bash
# Example pre-build hook script
# This script runs before the build process starts.

. "$KAM_HOOKS_ROOT/lib/utils.sh"

log_info "Running tmpl pre-build hook..."
log_info "Building module: $KAM_MODULE_ID v$KAM_MODULE_VERSION"

# If KAM_DEBUG is set to 1, print a pretty dump of all environment variables
if [ "${KAM_DEBUG:-}" = "1" ]; then
    log_warn "KAM_DEBUG=1: dumping KAM* environment variables (sorted)"
    # Ensure color variables exist to avoid raw escape sequences if utils.sh is missing
    if [ -z "${BLUE:-}" ]; then
        BLUE=""
        GREEN=""
        YELLOW=""
        NC=""
    fi
    printf "${BLUE}KAM variables:${NC}\n"
    if env | grep '^KAM' >/dev/null 2>&1; then
        env | sort | grep '^KAM' | while IFS= read -r line; do
            name="${line%%=*}"
            val="${line#*=}"
            printf "  ${BLUE}%s${NC} = ${GREEN}%s${NC}\n" "$name" "$val"
        done
    else
        log_info "No KAM-prefixed environment variables found."
    fi

    # Update PS1 so child shells/interactive shells show we're in KAM debug mode
    if [ -z "$PS1" ]; then
        PS1='$ '
    fi
    export PS1="[KAM_DEBUG:${KAM_MODULE_ID}] $PS1"
fi

# Add your pre-build logic here (e.g., downloading assets, checking environment)
