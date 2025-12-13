# Kam Build Hooks (forked from asl)
[![Release](https://img.shields.io/github/v/release/KernelSU-Modules-Repo/asl?label=release&color=blue&style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![License](https://img.shields.io/github/license/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/blob/main/LICENSE) [![Last commit](https://img.shields.io/github/last-commit/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/commits/main) [![Issues](https://img.shields.io/github/issues/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/issues)

[![Stars](https://img.shields.io/github/stars/KernelSU-Modules-Repo/asl?style=social)](https://github.com/KernelSU-Modules-Repo/asl/stargazers) [![Downloads](https://img.shields.io/github/downloads/KernelSU-Modules-Repo/asl/total?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-brightgreen?style=flat-square)](https://github.com/sponsors/LIghtJUNction)

What is this? / 这是干什么的？
============================================

这是一个来自 asl 的 fork — 文档聚焦于 Kam 的构建钩子系统（hooks）。  
This repo documents the Kam build hook system — how to structure, write, and run pre-/post-build hooks for Kam modules.

---

Quick start / 快速开始
--------------------------------------------

### Download & install / 下载与安装
- Download releases: https://github.com/KernelSU-Modules-Repo/asl/releases  

- download termux

- su

- rurima

- dep # check dependencies

- pull # pull image


### Build / 构建
- Install the Kam CLI (if needed):
  - `cargo install kam`
- Build from the project root:
  - `cd asl`
  - `kam build`
- Output artifacts are placed under `dist/` (e.g., `dist/asl.zip`).
- Example: sign and release:
  - `kam build -s -r`

Flags / 常用参数
- `-s` / `--sign` — enable signing (artifact signing, sets `KAM_SIGN_ENABLED`).
- `-r` / `--release` — create a GitHub Release using `dist/*`.
- `-P` / `--pre-release` — mark release as a pre-release.
- `-i`, `--interactive` — Run build interactively; ask for confirmation when performing potentially destructive actions (e.g., re-uploading or overwriting releases).

注意：
- `-i` / `--interactive` 会在执行破坏性操作前交互式询问确认（适合本地使用）。
- 在 CI 中通常不要使用 `-i`，以避免构建被交互提示阻塞。

### Sign / 签名
- Import your private key:
  - `kam secret import main /path/to/xxx.pem`
- Sign `update.json` or artifacts:
  - `kam sign update.json --sigstore --timestamp`
  - `kam sign dist/asl.zip --sigstore --timestamp`  

### Verify / 验证
- Download `module.zip` and signature (`module.zip.sig`).
- Verify with public key:
  - `kam verify module.zip --key my-pub-key.pem`

我的公钥（可去developer仓库验证）:
```
-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEYeQgxFckNt9d19zqNjiJJvL+inPJXPdK
K20ZjQBmNuLcnWe7dwYoKVfkVpMlqgF+gN1ADDzlRktiC83c4V7Zl/BT/AEVxRcA
F5Pi+iJLXNDSxSpGCIxb8ixY7BP/KJo8
-----END PUBLIC KEY-----
```

(更多示例请参阅 Repos / Releases)

### Release / 发布
- Create a GitHub Release:
  - `kam build -r` (add `-s` to sign before releasing)
- Use `-P` for pre-release.  
- `-i` / `--interactive` controls whether the build asks for confirmation before performing potentially destructive actions (useful locally).  Do not rely on `KAM_IMMUTABLE_RELEASE` — it was removed in favor of interactive handling.

### Action secrets / GitHub Actions（CI）
- `KAM_PRIVATE_KEY`: Add this secret (PEM content) to your repository to enable CI signing.
- Keep secrets secure — do not commit private keys to the repository.

---

Table of Contents | 目录
- [Quick start / 快速开始](#quick-start--快速开始)
  - [Download & install / 下载与安装](#download--install--下载与安装)
  - [Build / 构建](#build--构建)
  - [Sign / 签名](#sign--签名)
  - [Verify / 验证](#verify--验证)
  - [Release / 发布](#release--发布)
  - [Action secrets / GitHub Actions（CI）](#action-secrets--github-actionsci)
- [Overview / 概述](#overview--概述)
- [Why / 返回：为什么使用钩子](#why--为什么使用钩子)
- [Naming convention / 命名约定](#naming-convention--命名约定)
- [Built-in hooks / 内置钩子](#built-in-hooks--内置钩子)
- [Execution behavior / 执行行为](#execution-behavior--执行行为)
- [Environment variables / 环境变量](#environment-variables--环境变量)
- [Examples / 示例](#examples--示例)
- [Template variables & precedence / 模板变量与优先级](#template-variables--precedence--模板变量与优先级)
- [Troubleshooting / 常见问题](#troubleshooting--常见问题)
- [Contributing / 贡献](#contributing--贡献)
- [Licensing / 许可与引用](#licensing--许可与引用)

---

Overview / 概述
--------------------------------------------
Kam hooks let you run custom scripts at different stages of the build lifecycle. Hooks are small scripts placed under `hooks/pre-build/` or `hooks/post-build/` and executed via `kam build`.

Kam 钩子允许你在构建流程不同阶段运行自定义脚本（`hooks/pre-build/`, `hooks/post-build/`），便于在构建前后进行同步、签名、上传等操作。

Why / 为什么使用钩子
--------------------------------------------
- Automate the Web UI build (planned): fetch and update dependencies, cross-compile, support interactive builds (confirmed via -i / --interactive), sign artifacts, and push releases — to make local builds and iteration easier.自动化构建WEBUI(后续计划)，拉取依赖更新依赖, 交叉编译， 交互式构建 ，签名 ，推送 .便于本地构建便于迭代.

- Automate tasks (sync files, generate metadata, sign artifacts, upload releases).  
  自动化任务（同步文件、生成元数据、签名产物、上传 Release）。
- Share common utilities via `KAM_HOOKS_ROOT`.  
  通过 `KAM_HOOKS_ROOT` 复用共享脚本和工具。
- Keep build-time steps within the repo for auditability.  
  将构建过程放入仓库提升审计与可维护性。

- Putting all of these hooks into one action will make that action bloated and difficult to maintain — it becomes harder to debug, enhance, and iterate. 如果将这些钩子写入action, action将变得极为臃肿，不便于调试，改进，迭代。

Naming convention / 命名约定
--------------------------------------------
Kam uses numeric prefixes on hook files to determine order:
- `N.UPPERCASE.xxx` — Template provided hooks (e.g. `0.EXAMPLE.sh`).
- `N.lowercase.xxx` — Project-specific hooks (e.g. `1.myhook.sh`) — overrides template hooks with the same numeric prefix.

Built-in hooks / 内置钩子
--------------------------------------------
### `1.SYNC_MODULE_FILES.sh` / `1.SYNC_MODULE_FILES.ps1`
- Syncs `[prop]` fields from `kam.toml` to `src/<module_id>/module.prop`.
- Generates `update.json` at the project root (used by release & update automation).
- Properties commonly synced:
  - `id`, `name`, `version`, `versionCode`, `author`, `description`, `updateJson` (if set).
- This runs automatically before builds and is included in standard templates (e.g. `kam_template`, `meta_template`).

Default Post-build hooks:
- `8000.SIGN_IF_ENABLE.sh`: If `KAM_SIGN_ENABLED=1`, runs `kam sign` for artifacts (`dist/`). Default flags: `--sigstore --timestamp`. Sigstore can be disabled with `KAM_SIGN_SIGSTORE=0`.
- `9000.UPLOAD_IF_ENABLED.sh`: If `KAM_RELEASE_ENABLED=1`, creates a GitHub Release with artifacts in `dist/`. Signatures are included when signing is enabled. If a tag already exists, upload behavior may be skipped or require confirmation depending on Kam's interactive behavior (see `-i` / `--interactive`).

Execution behavior / 执行行为
--------------------------------------------
- Kam executes hooks by invoking the file directly and defers to OS / shebang for the interpreter (e.g. `#!/bin/sh`).
- Ensure scripts are executable in Unix-like environments: `chmod +x hooks/…`.
- On Windows, use `.ps1` scripts or run shell scripts under WSL/Git Bash.
- `KAM_STAGE` indicates the current stage: `pre-build` or `post-build`.

Environment variables / 环境变量
--------------------------------------------
Kam injects a set of environment variables into hooks to expose build and template metadata without re-parsing `kam.toml`.

| Variable | Description (EN) | 描述（中文） |
|----------|-------------------|--------------|
| `KAM_PROJECT_ROOT` | Absolute path to the project root. | 项目根目录绝对路径。 |
| `KAM_HOOKS_ROOT` | Absolute path to the hooks directory. | 钩子目录绝对路径。 |
| `KAM_MODULE_ROOT` | Absolute path to module source directory (`src/<id>`). | 模块源码绝对路径。 |
| `KAM_WEB_ROOT` | Absolute path to webroot (`<module_root>/webroot`). | 模块 webroot 目录。 |
| `KAM_DIST_DIR` | Absolute path to build output (`dist/`). | 构建产物目录（`dist`）。 |
| `KAM_MODULE_ID` | Module ID from `kam.toml`. | 模块 ID。 |
| `KAM_MODULE_VERSION` | Module version. | 模块版本。 |
| `KAM_MODULE_VERSION_CODE` | Module versionCode. | 模块版本号（versionCode）。 |
| `KAM_MODULE_NAME` | Module name. | 模块名称。 |
| `KAM_MODULE_AUTHOR` | Module author. | 模块作者。 |
| `KAM_MODULE_DESCRIPTION` | Module description. | 模块简介或描述。 |
| `KAM_MODULE_UPDATE_JSON` | Update JSON URL (if set). | 更新 JSON 的 URL（如有）。 |
| `KAM_STAGE` | Stage: `pre-build` or `post-build`. | 构建阶段：`pre-build` 或 `post-build`。 |
| `KAM_DEBUG` | `1` to enable debug output. | 设置为 `1` 开启调试输出。 |
| `KAM_SIGN_ENABLED` | `1` when build invoked with `-s/--sign`. | 构建时若带 `-s` 表示启用签名。 |
| `KAM_PRE_RELEASE` | `1` when build invoked with `-P/--pre-release`. | 预发布控制变量（`-P`）。 |
| `KAM_RELEASE_ENABLED` | `1` if release/upload hooks should run. | 是否启用 Release 上传钩子。 |

Additional exported variables:
- `KAM_PROP_*` — exports `prop.*` keys (e.g., `prop.id` -> `KAM_PROP_ID`).
- `KAM_TMPL_<NAME>` — template variables defined under `[kam.tmpl.variables]`.
- `KAM_<PATH>` — flattened `kam.toml` keys, dot/dash -> underscores, uppercased (e.g., `mmrl.repo.repository` -> `KAM_MMRL_REPO_REPOSITORY`).

Examples / 示例
--------------------------------------------
Simple pre-build hook (shell):
```bash
#!/bin/sh
# hooks/pre-build/1.echo.sh
echo "Stage: $KAM_STAGE"
echo "Module: $KAM_MODULE_ID@$KAM_MODULE_VERSION"
```

PowerShell example:
```powershell
# hooks/pre-build/1.example.ps1
Write-Output "KAM_MODULE_ID: $env:KAM_MODULE_ID"
```

Sample `update.json`:
```json
{
  "version": "1.0.0",
  "versionCode": 1,
  "zipUrl": "https://example.com/releases/module-1.0.0.zip",
  "changelog": "Initial release"
}
```

Template variables & precedence / 模板变量与优先级
--------------------------------------------
- `kam init` persists resolved template variables to `.kam/template-vars.env` (legacy `template-vars.env` may also exist).
- During `kam build`, Kam loads `.kam/template-vars.env` and `.env`, injecting `KAM_*` and `KAM_TMPL_*` variables into hook environments.
- Override order: values in `.env` take precedence over `.kam/template-vars.env`.

Troubleshooting / 常见问题
--------------------------------------------
- Hooks not running? Check shebang and permissions: `chmod +x hooks/…` and ensure there’s an appropriate shebang (e.g., `#!/bin/sh`).
- Windows: Use PowerShell (`.ps1`) or run shell scripts under WSL/Git Bash.
- `kam sign` fails due to TSA/network issues: `kam` will continue, but timestamps may be missing — enable `KAM_DEBUG=1` to troubleshoot.
- Interactive builds (`-i`, `--interactive`) ask for confirmation on potentially destructive actions (e.g., overwriting an existing release). Avoid `-i` in CI to prevent blocking builds, or provide non-interactive flags and secrets.

CI / GitHub Actions example (示例)
--------------------------------------------
Example workflow using `kam` to build, sign, and release:
```yaml
name: Build & Release
on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - name: Install kam
        run: cargo install kam --force
      - name: Build & Release
        env:
          KAM_PRIVATE_KEY: ${{ secrets.KAM_PRIVATE_KEY }}
          KAM_RELEASE_ENABLED: 1
        run: |
          # Non-interactive builds: don't use -i / --interactive in CI
          kam build -s -r
```

Contributing / 贡献
--------------------------------------------
- Add hooks in `hooks/pre-build/` or `hooks/post-build/` and ensure they’re executable.
- Prefer small, testable scripts and avoid large side effects.
- Document shared scripts under `hooks/shared/` and use `KAM_HOOKS_ROOT` to source them when needed.

Licensing / 许可与引用
--------------------------------------------
This project is a fork of [asl](https://github.com/RuriOSS/asl). Keep attributions and follow the original license (see `LICENSE`).

---
