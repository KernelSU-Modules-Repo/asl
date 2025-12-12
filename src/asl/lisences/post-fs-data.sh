#!/system/bin/sh
#
# post-fs-data.sh
#
# This script runs in the "post-fs-data" stage of the boot process.
#
# ---------------------------------------------------------------------------------------
# EXECUTION CONTEXT
# ---------------------------------------------------------------------------------------
# - BLOCKING: The boot process is PAUSED until this script finishes (or times out).
# - TIMEOUT:  Usually 10 seconds. If it takes longer, boot continues.
# - TIMING:   Runs BEFORE modules are mounted.
# - ENV:      Runs in KernelSU's BusyBox ash shell (Standalone Mode).
#             $MODDIR is set to the module's directory.
#             $KSU_MODULE is set to the module ID.
#
# ---------------------------------------------------------------------------------------
# USE CASES
# ---------------------------------------------------------------------------------------
# - Dynamically modifying module files before they are mounted.
# - Loading custom sepolicy rules (if not using sepolicy.rule file).
# - Setting system properties (use `resetprop`).
# - Managing module configuration (clearing temp configs).
#
# ---------------------------------------------------------------------------------------
# MODULE CONFIGURATION (KernelSU)
# ---------------------------------------------------------------------------------------
# KernelSU provides a built-in key-value store for modules.
#
# Get a value:
# val=$(ksud module config get my_key)
#
# Set a persistent value:
# ksud module config set my_key "value"
#
# Set a temporary value (cleared on next boot):
# ksud module config set --temp runtime_state "active"
#
# ---------------------------------------------------------------------------------------

MODDIR=${0%/*}

# Example: Log execution
# echo "Executing post-fs-data.sh for $KSU_MODULE" > /dev/kmsg

# Example: Clear temporary runtime state on boot
# ksud module config delete --temp runtime_state

# Example: Dynamic mounting preparation
# if [ -f "$MODDIR/enable_feature" ]; then
#     # Do something
# fi

# WARNING: Do NOT use `setprop` here, it may deadlock boot. Use `resetprop`.
# resetprop -n my.custom.prop value
