# FILE AUTOMATICALLY GENERATED FROM /data/adb/modules/asl//.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source "${HOME}.zim/zimfw.zsh" "${@}" }
fpath=("${HOME}.zim/modules/git/functions" "${HOME}.zim/modules/utility/functions" "${HOME}.zim/modules/duration-info/functions" "${HOME}.zim/modules/git-info/functions" "${HOME}.zim/modules/zsh-completions/src" "${HOME}.zim/modules/completion/functions" ${fpath})
autoload -Uz -- git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw duration-info-precmd duration-info-preexec coalesce git-action git-info
source "${HOME}.zim/modules/environment/init.zsh"
source "${HOME}.zim/modules/git/init.zsh"
source "${HOME}.zim/modules/input/init.zsh"
source "${HOME}.zim/modules/termtitle/init.zsh"
source "${HOME}.zim/modules/utility/init.zsh"
source "${HOME}.zim/modules/duration-info/init.zsh"
source "${HOME}.zim/modules/asciiship/asciiship.zsh-theme"
source "${HOME}.zim/modules/completion/init.zsh"
source "${HOME}.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${HOME}.zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "${HOME}.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${HOME}.zim/modules/powerlevel10k/powerlevel10k.zsh-theme"
