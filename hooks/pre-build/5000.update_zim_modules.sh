#!/bin/bash

. "$KAM_HOOKS_ROOT/lib/utils.sh"

require_command which "which not found"
require_command zsh "zsh not found" || ci_install zsh


export HOME=$KAM_MODULE_ROOT
if [ "$KAM_INTERACTIVE" = "1" ]; then
    log_info "Starting interactive shell"
    exec $(which zsh) -i
else
    # 执行zimfw update
    log_info "Starting zimfw update"
    $(which zsh) -c "source $HOME/.zshrc && which git && zimfw update && zimfw upgrade"
fi
