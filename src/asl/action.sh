# shellcheck shell=ash
# action.sh - minimal and direct: import `rich` and use `ask` (no fallbacks)

MODDIR=${0%/*}
[ -f "$MODDIR/lib/kamfw/.kamfwrc" ] && . "$MODDIR/lib/kamfw/.kamfwrc" || abort '! File "kamfw/.kamfwrc" does not exist!'
import __runtime__

# Import rich to get `ask` / `guide`
import rich
# Import i18n and register localized strings
import i18n

set_i18n "TOGGLE_RURIMARC" "zh" "切换 .rurimarc？"
set_i18n "TOGGLE_RURIMARC" "en" "Toggle .rurimarc?"
set_i18n "TOGGLE_RURIMARC" "ja" ".rurimarc を切り替えますか？"
set_i18n "TOGGLE_RURIMARC" "ko" ".rurimarc 를 전환하시겠습니까?"

set_i18n "CURRENT_LINE" "zh" "当前: {}"
set_i18n "CURRENT_LINE" "en" "Current: {}"
set_i18n "CURRENT_LINE" "ja" "現在: {}"
set_i18n "CURRENT_LINE" "ko" "현재: {}"

set_i18n "NEW_FIRST_LINE" "zh" "新的第一行:"
set_i18n "NEW_FIRST_LINE" "en" "New first line:"
set_i18n "NEW_FIRST_LINE" "ja" "新しい最初の行:"
set_i18n "NEW_FIRST_LINE" "ko" "새 첫 줄:"

set_i18n "TOGGLE_FAILED" "zh" "切换失败"
set_i18n "TOGGLE_FAILED" "en" "Toggle failed"
set_i18n "TOGGLE_FAILED" "ja" "切り替えに失敗しました"
set_i18n "TOGGLE_FAILED" "ko" "전환에 실패했습니다"

set_i18n "FILE_NOT_FOUND" "zh" "文件未找到: {}"
set_i18n "FILE_NOT_FOUND" "en" "File not found: {}"
set_i18n "FILE_NOT_FOUND" "ja" "ファイルが見つかりません: {}"
set_i18n "FILE_NOT_FOUND" "ko" "파일을 찾을 수 없습니다: {}"

f="$MODDIR/.zshrc"
[ -f "$f" ] || { print "$(i18n 'FILE_NOT_FOUND' | t "$f")"; exit 1; }

toggle_now() {
    sed -i '1{s/^[[:space:]]*#[[:space:]]*//;t;s/^/#/}' "$f" || { print "$(i18n 'TOGGLE_FAILED')"; exit 1; }
    print "$(i18n 'NEW_FIRST_LINE')"
    sed -n '1p' "$f"
}


guide "$(i18n 'TOGGLE_RURIMARC')" "$(i18n 'CURRENT_LINE' | t "$(sed -n '1p' "$f")")"
ask "TOGGLE_RURIMARC" \
        "CONFIRM" \
            'toggle_now' \
        "REFUSE" \
            'exit 0' \
        1
exit 0
