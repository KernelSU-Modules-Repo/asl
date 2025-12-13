# Kam Build Hooks (forked from asl)
[![Release](https://img.shields.io/github/v/release/KernelSU-Modules-Repo/asl?label=release&color=blue&style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![License](https://img.shields.io/github/license/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/blob/main/LICENSE) [![Last commit](https://img.shields.io/github/last-commit/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/commits/main) [![Issues](https://img.shields.io/github/issues/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/issues) 

[![Stars](https://img.shields.io/github/stars/KernelSU-Modules-Repo/asl?style=social)](https://github.com/KernelSU-Modules-Repo/asl/stargazers) [![Downloads](https://img.shields.io/github/downloads/KernelSU-Modules-Repo/asl/total?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-brightgreen?style=flat-square)](https://github.com/sponsors/LIghtJUNction)
# What is this?

这是一个来自 asl 的 fork — 文档聚焦于 Kam 的构建钩子系统（hooks）。  
This repository documents the Kam build hook system: how to structure, write, and run pre-/post-build hooks.

---
![screenshot](Screenshot_2025-12-08-01-18-25-97_84d3000e3f4017145260f7618db1d683.jpg)


## Quick start / 快速开始

### Download & install / 下载与安装（示例）
- Download the latest release from the Releases page:
  - https://github.com/KernelSU-Modules-Repo/asl/releases
- Example (using `rurima`):  
  - `rurima install https://github.com/KernelSU-Modules-Repo/asl/releases/latest/download/asl.zip`
- On Android (Termux + root) — 示例：
  - Install Termux (F-Droid / Play Store), open a shell, and if required, switch to root: `su`
  - `rurima install /path/to/asl.zip` or `rurima install asl`
- For other installation methods (Magisk / KernelSU), follow your manager's workflow.

### Build / 构建
- Install the `kam` CLI (if not already installed):
  - `cargo install kam`
- Build the module from the repository root:
  - `cd asl`
  - `kam build`
- Output artifacts are placed under `dist/` (e.g. `dist/asl.zip`).
- Example: Sign and create a GitHub release:
  - `kam build -s -r`
  - Useful flags:
    - `-s` — enable signing (`KAM_SIGN_ENABLED`)
    - `-r` — create a GitHub Release
    - `-P` — create a pre-release (set `KAM_PRE_RELEASE=1`)
    - `-i` — create an immutable release (set `KAM_IMMUTABLE_RELEASE=1`)

### Sign / 签名
- Import your private key into `kam`:
  - `kam secret import main /path/to/xxx.pem`
- Sign the update JSON or artifacts:
  - `kam sign update.json --sigstore --timestamp`
  - Or sign specific artifact(s): `kam sign dist/asl.zip --sigstore --timestamp`

### Verify / 验证
- After downloading the artifact and its signature (for example `asl.zip` and `asl.zip.sig`):
  - `kam verify asl.zip --key my-pub-key.pem`
- Example public key (PEM):
-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEYeQgxFckNt9d19zqNjiJJvL+inPJXPdK
K20ZjQBmNuLcnWe7dwYoKVfkVpMlqgF+gN1ADDzlRktiC83c4V7Zl/BT/AEVxRcA
F5Pi+iJLXNDSxSpGCIxb8ixY7BP/KJo8
-----END PUBLIC KEY-----

[check](https://github.com/KernelSU-Modules-Repo/developers/issues/11)

### Release / 发布
- Create a GitHub Release from the CI or locally:
  - `kam build -r` (add `-s` to sign before releasing)
- Use `KAM_PRE_RELEASE=1` for pre-releases, and `KAM_IMMUTABLE_RELEASE=1` to avoid re-uploading an existing tag.

### Action secrets / GitHub Actions（CI）
- `KAM_PRIVATE_KEY`: Add this secret (PEM content) to your repository's secrets to allow CI to sign artifacts or releases.
- Keep keys secure — do not store private keys in code. Rotate keys and restrict access as needed.


Table of Contents | 目录
- [Quick start / 快速开始](#quick-start--快速开始)
  - [Download & install / 下载与安装](#download--install--下载与安装)
  - [Build / 构建](#build--构建)
  - [Sign / 签名](#sign--签名)
  - [Verify / 验证](#verify--验证)
  - [Release / 发布](#release--发布)
  - [Action secrets / GitHub Actions（CI）](#action-secrets--github-actionsci)
- [Overview / 概述](#overview--概述)
- [Why / 为什么使用钩子](#why--为什么使用钩子)
- [Naming convention / 命名约定](#naming-convention--命名约定)
- [Built-in hooks / 内置钩子](#built-in-hooks--内置钩子)
- [Execution behavior / 执行行为](#execution-behavior--执行行为)
- [Environment variables / 环境变量](#environment-variables--环境变量)
- [Examples / 示例](#examples--示例)
- [Template variables & precedence / 模板变量与优先级](#template-variables--precedence--模板变量与优先级)
- [Troubleshooting / 常见问题](#troubleshooting--常见问题)
- [Licensing / 许可与引用](#licensing--许可与引用)

---
# BUILD-SYSTEM

## Overview / 概述
Kam hooks let you run custom scripts at different stages of the build lifecycle. Hooks are small scripts placed under `hooks/pre-build/` or `hooks/post-build/` that Kam executes during `kam build`.

Kam 钩子允许你在构建流程的不同阶段运行自定义脚本。将脚本放入 `hooks/pre-build/` 或 `hooks/post-build/` 下，Kam 会在 `kam build` 时执行这些脚本。

---

## Why / 为什么使用钩子
- Automate repetitive tasks (sync files, generate metadata, sign artifacts, upload releases).  
  自动化重复任务（同步文件、生成元数据、签名产物、上传 Release）。
- Reuse shared scripts across modules via `KAM_HOOKS_ROOT`.  
  通过 `KAM_HOOKS_ROOT` 复用共享脚本。
- Document build-time hooks inside the project tree (easier collaboration).  
  在仓库中定义构建阶段脚本，便于协作与审计。

---

## Naming Convention / 命名约定
Kam uses a numeric prefix to order hooks. Templates may include uppercase-named hooks; projects may provide lowercase overrides.

Kam 使用数字前缀对钩子进行排序。模板提供的钩子通常以大写命名；项目可通过小写命名覆盖同一数字前缀的模板钩子。

Rules — 规则：
- `N.UPPERCASE.xxx` (e.g., `0.EXAMPLE.sh`, `2.BUILD_WEBUI.sh`) — template-provided hooks (distributed with a template).  
  模板提供的钩子（随模板分发）。
- `N.lowercase.xxx` (e.g., `1.custom-script.sh`) — project-level custom hooks (added by module author).  
  项目层面自定义钩子（模块作者添加）。
- Execution order is numeric ascending by the leading `N`. Hooks with the same numeric prefix: project-level hooks override template hooks.  
  钩子以数字升序执行；数字相同时，项目钩子覆盖模板钩子。

Example:
- `hooks/pre-build/0.EXAMPLE.sh` (template)
- `hooks/pre-build/1.sync-module.sh` (project)

---

## Built-in Hooks / 内置钩子

### `1.SYNC_MODULE_FILES.sh` / `1.SYNC_MODULE_FILES.ps1`
- Purpose: Sync `[prop]` from `kam.toml` to `module.prop` and generate `update.json` in project root.  
  目的：将 `kam.toml` 中的 `[prop]` 同步到模块的 `module.prop`，并在项目根生成 `update.json`。
- Location: `src/<module_id>/module.prop` and `update.json` in project root.  
  生成位置：`src/<module_id>/module.prop` 与根目录下的 `update.json`。
- Properties synced:
  - `id`, `name`, `version`, `versionCode`, `author`, `description`, `updateJson` (if set)
  - `id`、`name`、`version`、`versionCode`、`author`、`description`、`updateJson`（如有）
- This runs automatically before builds and is included in standard templates (`kam_template`, `meta_template`).  
  该钩子随标准模板包含并在构建前自动运行。

Default Post-build hooks:
- `8000.SIGN_IF_ENABLE.sh`: If `KAM_SIGN_ENABLED=1`, run `kam sign` on artifacts in `dist/` (default flags: `--sigstore --timestamp`). Set `KAM_SIGN_SIGSTORE=0` to disable Sigstore.  
  如果 `KAM_SIGN_ENABLED=1`，对 `dist/` 目录的产物运行 `kam sign`（默认 `--sigstore --timestamp`）。可用 `KAM_SIGN_SIGSTORE=0` 禁用 Sigstore。
- `9000.UPLOAD_IF_ENABLED.sh`: If `KAM_RELEASE_ENABLED=1`, creates a GitHub Release using `dist/*` assets and includes signatures when signing is enabled. `KAM_PRE_RELEASE=1` creates a pre-release; `KAM_IMMUTABLE_RELEASE=1` prevents overwriting an existing tag.  
  如果 `KAM_RELEASE_ENABLED=1`，使用 `dist/*` 作为 Release 资产并自动包含签名。`KAM_PRE_RELEASE=1` 表示预发行；`KAM_IMMUTABLE_RELEASE=1` 表示不可变发布（若 tag 已存在则跳过上传）。

---

## Execution behavior / 执行行为
- Kam runs hooks by invoking the files directly and defers to the OS (or the file’s shebang) for the runtime used.  
  Kam 通过直接调用文件执行钩子，执行器不会尝试为你选择解释器，请确保脚本在目标环境下可执行。
- Ensure shebang and file permissions in Unix-like environments: `#!/bin/sh` and `chmod +x`. On Windows, run through WSL/Git Bash or provide `.ps1` hooks.  
  请在类 Unix 系统上确保 shebang（例如 `#!/bin/sh`）与执行权限（`chmod +x`）；在 Windows 上可通过 WSL/Git Bash 运行 shell 脚本或使用 PowerShell 脚本（`.ps1`）。
- Hooks run in both pre- and post-stages; the `KAM_STAGE` env var indicates `pre-build` or `post-build`.  
  钩子会在 `pre-build` 或 `post-build` 阶段执行，`KAM_STAGE` 环境变量标识当前阶段。

---

## Environment variables / 环境变量

Kam injects a set of environment variables into hooks to make build and template data available without re-parsing `kam.toml`.

Kam 会注入一组环境变量，避免在钩子中重复解析 `kam.toml`。

Main variables — 关键变量:

| Variable | Description (EN) | 描述（中文） |
|----------|-------------------|--------------|
| `KAM_PROJECT_ROOT` | Absolute project root path. | 项目根目录绝对路径。 |
| `KAM_HOOKS_ROOT` | Absolute hooks directory path (useful for sourcing shared scripts). | 钩子目录绝对路径（便于引入共享脚本）。 |
| `KAM_MODULE_ROOT` | Absolute path to module source directory (e.g. `src/<id>`). | 模块源码目录绝对路径（例如 `src/<id>`）。 |
| `KAM_WEB_ROOT` | Absolute module webroot path (`<module_root>/webroot`). | 模块 webroot 目录绝对路径。 |
| `KAM_DIST_DIR` | Absolute build output directory (e.g. `dist`). | 构建输出目录绝对路径（例如 `dist`）。 |
| `KAM_MODULE_ID` | Module ID from `kam.toml`. | `kam.toml` 中配置的模块 ID。 |
| `KAM_MODULE_VERSION` | Module version. | 模块版本。 |
| `KAM_MODULE_VERSION_CODE` | Module version code. | 模块版本代号（versionCode）。 |
| `KAM_MODULE_NAME` | Module name. | 模块名称。 |
| `KAM_MODULE_AUTHOR` | Module author. | 模块作者。 |
| `KAM_MODULE_DESCRIPTION` | Module description. | 模块描述。 |
| `KAM_MODULE_UPDATE_JSON` | Update JSON URL (if set). | Update JSON 的 URL（如有）。 |
| `KAM_STAGE` | Build stage: `pre-build` or `post-build`. | 构建阶段：`pre-build` 或 `post-build`。 |
| `KAM_DEBUG` | `1` to enable debug output from hooks. | 设置为 `1` 开启调试输出。 |
| `KAM_SIGN_ENABLED` | `1` when built with `-s/--sign`. | `-s/--sign` 构建时设为 `1`，用于触发签名逻辑。 |
| `KAM_IMMUTABLE_RELEASE` | `1` when built with `-i/--immutable-release`. | `-i/--immutable-release` 构建时设为 `1`，用于不可变发布处理。 |
| `KAM_PRE_RELEASE` | `1` when built with `-P/--pre-release`. | `-P/--pre-release` 构建时设为 `1`，用于预发布处理（例如跳过自动上传）。 |
| `KAM_RELEASE_ENABLED` | `1` if release/upload hooks should run. | 若设置为 `1` 表示应运行上传 Release 的钩子。 |

Additional exported variables:
- `KAM_PROP_*` — Prefix for canonical `prop.*` fields.
  - Example: `prop.id` => `KAM_PROP_ID`.
- `KAM_TMPL_<NAME>` — Template variables defined in `[kam.tmpl.variables]`, exported in upper-case.
- `KAM_<PATH>` — Flattened `kam.toml` keys exported as env vars, with dots/dashes replaced by underscores and upper-cased.
  - Example: `mmrl.repo.repository` => `KAM_MMRL_REPO_REPOSITORY`
  - Example: `kam.build.hooks_dir` => `KAM_KAM_BUILD_HOOKS_DIR`

These make data from `kam.toml` and template variables available to hooks without re-parsing the file.

这些变量使得构建时的 `kam.toml` 数据与模板变量可以被钩子直接使用，无需再次解析 `kam.toml`。

---

## Examples / 示例

Simple pre-build hook (shell):
- File: `hooks/pre-build/1.echo.sh`
```bash
#!/bin/sh
# hooks/pre-build/1.echo.sh
echo "Stage: ${KAM_STAGE}"
echo "Module ID: ${KAM_MODULE_ID}"
env | grep '^KAM_' || true
```

Sync / sign example:
```bash
# from repo root
kam sign update.json --sigstore --timestamp
```

Generated `update.json` sample:
```json
{
  "version": "1.0.0",
  "versionCode": 1,
  "zipUrl": "https://example.com/releases/module-1.0.0.zip",
  "changelog": "Initial release"
}
```

PowerShell pre-build example on Windows:
```
powershell
# hooks/pre-build/1.example.ps1
Write-Output "KAM_MODULE_ID: $env:KAM_MODULE_ID"
```

Notes:
- Mark UNIX shells executable: `chmod +x hooks/pre-build/1.echo.sh`.
- On Windows, prefer `.ps1` scripts or run sh scripts via WSL/Git Bash.

---

## Template variables & precedence / 模板变量与优先级

- `kam init` stores resolved template variables used to render templates into `.kam/template-vars.env` inside the project root. (For legacy compatibility, `template-vars.env` may exist.) During `kam build`, Kam loads both `.kam/template-vars.env` and `.env` (project env file), and injects derived `KAM_*` and `KAM_TMPL_*` variables into the hook environment.  
  `kam init` 会把用于渲染模板的变量解析并写入项目 `.kam/template-vars.env`，在构建时 Kam 会加载这个文件及 `.env` 并注入 `KAM_*` 和 `KAM_TMPL_*` 变量到钩子环境中。
- Override order: Environment vars in project `.env` take precedence over `.kam/template-vars.env`.  
  环境变量优先级：项目 `.env` > `.kam/template-vars.env`。

---

## Troubleshooting / 常见问题

- Hooks not running? Check file permission and the shebang: `chmod +x` & `#!/bin/sh` (or appropriate interpreter).  
  若钩子未运行，检查执行权限和 shebang。
- Windows users: Shell scripts without an explicit interpreter won't run by double-click; run via WSL/Git Bash or use `.ps1` hooks.  
  Windows 用户：建议在 WSL/Git Bash 下运行 shell 脚本，或使用 PowerShell 脚本。
- `kam sign` fails due to network/TSA issues: `kam` will gracefully continue, but signatures may lack timestamp or fail. Inspect the hook log and `KAM_DEBUG=1` to see more info.  
  使用 `kam sign` 时若无法访问 TSA（时间戳服务），会跳过时间戳但仍会生成签名。启用 `KAM_DEBUG=1` 可查看详细日志。
- `KAM_IMMUTABLE_RELEASE=1`: If set and release tag already exists, upload step will be skipped to avoid changing existing immutable release.  
  设置 `KAM_IMMUTABLE_RELEASE=1` 时若 Release tag 已存在，将跳过上传以避免修改不可变 release。

---

## Contributing / 贡献
- Add hooks in `hooks/pre-build/` or `hooks/post-build/` and ensure they’re executable.
- Prefer small, testable scripts; avoid relying on large external state.
- Document any shared scripts in `hooks/shared/` and source from `KAM_HOOKS_ROOT` in other scripts.

---

## Licensing / 许可与引用
- This project is a fork of [asl](https://github.com/RuriOSS/asl). Keep attributions and follow original licensing terms.  
  本仓库为 `asl` 的 fork，请保留原始归属并遵循原仓库许可条款。

If you want further improvements (examples, badges, a contributor section, or a short FAQ), tell me which parts to expand and I’ll update the README accordingly.
如果你想进一步扩展（例如增加示例、徽章、贡献者列表或常见问答），告诉我你希望在哪些部分扩展，我会继续美化 README。
