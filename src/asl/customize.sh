# shellcheck shell=ash
# {{prop.name}} customize.sh
#
# ---------------------------------------------------------------------------------------
# CUSTOM INSTALLATION LOGIC
# ---------------------------------------------------------------------------------------
[ -f "$MODPATH/lib/kamfw/.kamfwrc" ] && . "$MODPATH/lib/kamfw/.kamfwrc" || abort '! File "kamfw/.kamfwrc" does not exist!'
# 作者注：导入以上工具库，会自动依据ROOT管理器
# 进行一些特殊处理
# 比如，如果是magisk.补全META-INF
# boot-completed --> service
# 记得在boot-completed调用：
# wait_boot_if_magisk
# 详见 lib/kamfw/magisk.sh
# lib/kamfw/ksu.sh
# lib/kamfw/ap.sh
# 依赖控制,文件共享
# 自动提取模块.local到kam共享目录，采用硬链接方式
# 为保证模块卸载时候不会有残留文件，uninstall.sh文件不要删
import __customize__
# --> .local/bin ~~> /data/adb/kam/bin
# --> .local/lib ~~> /data/adb/kam/lib

# i18n
import i18n
import lang
import rich

require_app "com.termux" \ # app
    "termux not found!" \  # err
    "url https://f-droid.org/en/packages/com.termux/"
    # if err:
    #  launch url "https://f-droid.org/en/packages/com.termux/"

# 任务一：模块使用指南
set_i18n "USAGE_GUIDE" \
    "zh" "快速开始 / Quick start

下载与安装
下载发行版: https://github.com/KernelSU-Modules-Repo/asl/releases

安装 Termux（如果未安装）

运行：

su
rurima

dep # 检查依赖
pull # 拉取镜像

示例：

cd /data
mkdir asl && cd asl
使用镜像站: https://images.linuxcontainers.org/
pull alpine:edge ./alpine
run ./alpine

注意：
修改 /etc/resolv.conf（要删除旧文件并创建新文件，你可以使用 MT Manager 或其它工具，或使用命令行）
写入 DNS 服务器配置，之后即可访问互联网。

如何卸载？
./alpine/.rurienv 已被设置为不可修改属性；使用 chattr -i ./alpine/.rurienv 移除此属性。" \
    "en" "Quick start / 快速开始

Download & install
Download releases: https://github.com/KernelSU-Modules-Repo/asl/releases

Install Termux (if not installed)

Run:

su
rurima

dep # check dependencies
pull # pull image

Example:

cd /data
mkdir asl && cd asl
# Use images from: https://images.linuxcontainers.org/
pull alpine:edge ./alpine
run ./alpine

Note:
Modify /etc/resolv.conf (To remove old files and create new ones, you can use MT Manager or other tools, or do it via the command line.)
Write DNS server configuration and you will now be able to access the internet.

How do I uninstall it?
./alpine/.rurienv It has been set to an unmodifiable attribute; remove it using chattr -i ./alpine/.rurienv."

divider "#"
print "$(i18n "INSTALL_START")"

newline 1

print "$(i18n "PERM_FIX")"

# Ensure main binary permission is strict
if [ -f "$MODPATH/system/xbin/rurima" ]; then
    set_perm "$MODPATH/system/xbin/rurima" root root 700
    print "  $(i18n 'PERM_SET_FILE') system/xbin/rurima"
fi

divider "#"

# Print end-user usage guide (detailed)
print "$(i18n "USAGE_GUIDE")"

# import launcher

# launch url "https://github.com/UserName/repo"
# launch ...

# import rich --> 这里有更多，比如 ask函数 confirm函数

##################################
# 备忘文档 -- 可删除               #
# You can delete this section    #
##################################
# This script is sourced by the module installer script after all files are extracted
# and default permissions/secontext are applied.
#
# Useful for:
# - Checking device compatibility (ARCH, API)
# - Setting special permissions
# - Customizing installation based on user environment
#
# ---------------------------------------------------------------------------------------
# AVAILABLE VARIABLES
# ---------------------------------------------------------------------------------------
# (KernelSU-only) KSU (bool):           true if running in KernelSU environment
# (KernelSU-only) KSU_VER (string):     KernelSU version string (e.g. v0.9.5)
# (KernelSU-only) KSU_VER_CODE (int):   KernelSU version code (userspace)
# (KernelSU-only) KSU_KERNEL_VER_CODE (int): KernelSU version code (kernel space)
# NOTE: KernelSU variables are only provided by KernelSU (not guaranteed on stock Magisk).
# Guard usage example:
#    if [ "$KSU" = "true" ]; then
#        # KernelSU-only logic
#    else
#        # Fallback for Magisk/APatch or other environments
#    fi
#
# KernelPatch/KernelSU/APatch related variables
# (KernelPatch-only) KERNELPATCH (bool):   true if running in KernelPatch environment
# (KernelPatch-only) KERNEL_VERSION (hex): Kernel version inherited from KernelPatch (e.g. 50a01 -> 5.10.1)
# (KernelPatch-only) KERNELPATCH_VERSION (hex): KernelPatch version identifier (e.g. a05 -> 0.10.5)
# (KernelPatch-only) SUPERKEY (string):    Value provided by KernelPatch for invoking kpatch/supercall
# NOTE: The KernelPatch variables above are provided by KernelPatch and may NOT exist on a stock Magisk installation.
#       If your module must work on both, check for their presence before using them:
#         if [ -n "$KERNELPATCH" ] && [ "$KERNELPATCH" = "true" ]; then
#           # KernelPatch-specific handling
#         fi
#
# APatch related variables
# (APatch-only) APATCH (bool):        true if running in APatch environment
# (APatch-only) APATCH_VER_CODE (int): APatch current version code (e.g. 10672)
# (APatch-only) APATCH_VER (string):  APatch version string (e.g. "10672")
# NOTE: The APatch variables above are specific to APatch (a Magisk fork). They are NOT guaranteed to exist on stock Magisk.
#       Guard your scripts like:
#         if [ "$APATCH" = "true" ]; then
#           # APatch-specific logic
#         fi
#
# Common environment variables (present across environments)
# BOOTMODE (bool):      always true in KernelSU and APatch (recovery / boot mode)
# MODPATH (path):       Path where module files are installed (e.g. /data/adb/modules/{{prop.id}})
# TMPDIR (path):        Path to temporary directory
# ZIPFILE (path):       Path to the installation ZIP
# ARCH (string):        Device architecture: arm, arm64, x86, x64
# IS64BIT (bool):       true if ARCH is arm64 or x64
# API (int):            Android API level (e.g. 33 for Android 13)
#
# WARNING:
# - In APatch, MAGISK_VER_CODE is typically 27000 and MAGISK_VER is 27.0 (so some Magisk-related checks behave differently).
# - Many KernelPatch/APatch features are not present on stock Magisk. When writing portable installation code,
#   explicitly check for variable presence and provide sensible fallbacks:
#     if [ -n "$APATCH" ] && [ "$APATCH" = "true" ]; then
#         # APatch-only handling
#     else
#         # Stock Magisk fallback handling (or skip)
#     fi
#
# ---------------------------------------------------------------------------------------
# AVAILABLE FUNCTIONS
# ---------------------------------------------------------------------------------------
# ui_print <msg>
#     Print message to console. Avoid 'echo'.
#
# abort <msg>
#     Print error message and terminate installation.
#
# set_perm <target> <owner> <group> <permission> [context]
#     Set permissions for a file.
#     Default context: "u:object_r:system_file:s0"
#
# set_perm_recursive <dir> <owner> <group> <dirperm> <fileperm> [context]
#     Recursively set permissions for a directory.
#     Default context: "u:object_r:system_file:s0"
#
# ---------------------------------------------------------------------------------------
# KERNELSU FEATURES
# ---------------------------------------------------------------------------------------
#
# REMOVE (Whiteout):
# List directories/files to be "removed" from the system (overlaid with whiteout).
# KernelSU executes: mknod <TARGET> c 0 0
#
# REMOVE="
# /system/app/BloatwareApp
# /system/priv-app/AnotherApp
# "
#
# REPLACE (Opaque):
# List directories to be replaced by an empty directory (or your module's version).
# KernelSU executes: setfattr -n trusted.overlay.opaque -v y <TARGET>
#
# REPLACE="
# /system/app/YouTube
# "
#
