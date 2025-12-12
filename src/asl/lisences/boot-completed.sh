#!/system/bin/sh
#
# boot-completed.sh
#
# This script runs when the Android system has finished booting.
# Specifically, it triggers when the "ACTION_BOOT_COMPLETED" broadcast is sent.
#
# ---------------------------------------------------------------------------------------
# EXECUTION CONTEXT
# ---------------------------------------------------------------------------------------
# - TRIGGER:      Runs when `sys.boot_completed` property becomes "1".
# - TIMING:       The UI is usually up (lock screen or launcher).
# - ENV:          Runs in KernelSU's BusyBox ash shell (Standalone Mode).
#                 $MODDIR is set to the module's directory.
#                 $KSU_MODULE is set to the module ID.
#
# ---------------------------------------------------------------------------------------
# USE CASES
# ---------------------------------------------------------------------------------------
# - Tasks that strictly require the Android framework/UI to be fully initialized.
# - Showing notifications or toasts (via `cmd notification` or similar).
# - Final cleanup tasks.
# - Interacting with system services that might not be ready during `service.sh`.
#
# ---------------------------------------------------------------------------------------

MODDIR=${0%/*}

# Example: Log execution
# echo "Executing boot-completed.sh for $KSU_MODULE" > /dev/kmsg

# Example: Check if a specific app is installed (pm is available now)
# if pm list packages | grep -q "com.example.app"; then
#     # Do something
# fi

# Example: Post a notification (requires root/shell privileges)
# cmd notification post -S bigtext -t "KernelSU Module" "Boot completed successfully!"Tag "1"
