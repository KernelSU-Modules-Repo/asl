# What is this?

this is a fork from [asl](https://github.com/RuriOSS/asl)

![screenshot](Screenshot_2025-12-08-01-18-25-97_84d3000e3f4017145260f7618db1d683.jpg)


# How to use?

- download termux 

- su

- rurima

- dep 

- help


# How to build

- cargo install kam

- cd asl

- kam build

output here：

dist/id.zip


# How to sign？

- kam secret import main /path/to/xxx.pem

- kam sign /path/to/module.zip


# How to verify？

- download *zip *sig

- kam verify *zip --key my-pub-key.pem

-----BEGIN PUBLIC KEY-----
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEYeQgxFckNt9d19zqNjiJJvL+inPJXPdK
K20ZjQBmNuLcnWe7dwYoKVfkVpMlqgF+gN1ADDzlRktiC83c4V7Zl/BT/AEVxRcA
F5Pi+iJLXNDSxSpGCIxb8ixY7BP/KJo8
-----END PUBLIC KEY-----

[check](https://github.com/KernelSU-Modules-Repo/developers/issues/11)

# How to release

kam build -r


# Action secrets 

KAM_PRIVATE_KEY

- ksu+developer-private-key.


# Kam Build Hooks

Hooks allow you to run custom scripts at different stages of the build process. Kam provides a flexible hook system with shared utilities and environment variables.

## Naming Convention

To distinguish between template-provided hooks and project-specific hooks, Kam uses the following naming convention for hook files in `hooks/pre-build/` and `hooks/post-build/`:

- `N.UPPERCASE.xxx` (e.g., `0.EXAMPLE.sh`, `2.BUILD_WEBUI.sh`) — Template-provided hooks (included in templates).
- `N.lowercase.xxx` (e.g., `1.custom-script.sh`) — Project-level custom hooks added in your project.

Hooks are executed in order by their numeric prefix. Template hooks are typically included by templates and executed unless overridden by a project-level custom hook with the same numeric prefix.

## Built-in Hooks

### `1.SYNC_MODULE_FILES.sh` / `1.SYNC_MODULE_FILES.ps1`

This pre-build hook automatically syncs the `[prop]` section from `kam.toml` to the `module.prop` file in your module directory and generates `update.json` in the project root.

**Purpose**: Since `kam.toml` is a superset of `module.prop`, this hook ensures that `module.prop` is always up-to-date before the build starts. It also generates a basic `update.json` used for update information (version, versionCode, zipUrl, changelog) which is useful for release and update tooling.

**Location**: The generated `module.prop` will be placed at `src/<module_id>/module.prop`. The generated `update.json` will be placed at the project root: `update.json`.

**Properties synced / generated**:
- `id`
- `name`
- `version`
- `versionCode`
- `author`
- `description`
- `updateJson` (if set)

This hook runs automatically before every build and is included in the standard module templates (`kam_template`, `meta_template`).

## Execution behavior

Kam executes hook files by directly invoking the file and defers to the operating system (or the file itself, via shebang or file associations) to determine how it runs. The hook runner intentionally does not attempt to pick or call interpreters based on the platform or file extension. Ensure your scripts are runnable on the target environment (for example: add `#!/bin/sh` and `chmod +x` for Unix-like systems, or run shell scripts via WSL/Git Bash on Windows).

## Environment Variables
[ACTION](https://docs.github.com/zh/actions/reference/workflows-and-actions/variables)

When hooks are executed, Kam injects the following environment variables, which you can use in your scripts:

| Variable | Description |
|----------|-------------|
| `KAM_PROJECT_ROOT` | Absolute path to the project root directory. |
| `KAM_HOOKS_ROOT` | Absolute path to the hooks directory. Useful for sourcing shared scripts. |
| `KAM_MODULE_ROOT` | Absolute path to the module source directory (e.g. `src/<id>`). |
| `KAM_WEB_ROOT` | Absolute path to the module webroot directory (`<module_root>/webroot`). |
| `KAM_DIST_DIR` | Absolute path to the build output directory (e.g. `dist`). Useful for uploading artifacts. |
| `KAM_MODULE_ID` | The module ID defined in `kam.toml`. |
| `KAM_MODULE_VERSION` | The module version. |
| `KAM_MODULE_VERSION_CODE` | The module version code. |
| `KAM_MODULE_NAME` | The module name. |
| `KAM_MODULE_AUTHOR` | The module author. |
| `KAM_MODULE_DESCRIPTION` | The module description. |
| `KAM_MODULE_UPDATE_JSON` | The module updateJson URL (if set). |
| `KAM_STAGE` | Current build stage: `pre-build` or `post-build`. |
| `KAM_DEBUG` | Set to `1` to enable debug output in hooks. |
| `KAM_SIGN_ENABLED` | Set to `1` when build invoked with `-s/--sign`. Useful to trigger automatic signing in hooks. |
| `KAM_IMMUTABLE_RELEASE` | Set to `1` when build invoked with `-i/--immutable-release`. Hooks can use this to opt into immutable release behavior. |
| `KAM_PRE_RELEASE` | Set to `1` when build invoked with `-P/--pre-release`. Hooks can use this to change release handling (e.g., skip uploads). |

Example sign command output (shows timestamp attempt and graceful network failure):

```bash
  kam sign update.json --sigstore --timestamp
Private key password:
✓ Signed 'update.json' -> dist/update.json.sig
! Failed to obtain TSA timestamp: TSA request error: error sending request for url (https://tsa.sigstore.dev/api/v1/timestamp). Skipping timestamp.
```

Default post-build hook behaviors:

Note: `kam init` persists the resolved template variables used to render templates into `.kam/template-vars.env` in the project root (for legacy compatibility `template-vars.env` in the project root may also be present). During `kam build`, Kam will load these files (in addition to `.env`) and inject the derived `KAM_*` and `KAM_TMPL_*` variables into hook environments. If you wish to override any value, set it in your project `.env` (or `~/.kam/...`); `.env` takes precedence.

Note: Kam also exports additional environment variables derived from the generated `kam.toml` and from templates:

- `KAM_PROP_*`: Canonical `prop.*` fields are exported with a `KAM_PROP_` prefix. Example variables created for most modules include:
  - `KAM_PROP_ID`: module ID
  - `KAM_PROP_NAME`: module name
  - `KAM_PROP_VERSION`: module version
  - `KAM_PROP_VERSION_CODE`: module version code
  - `KAM_PROP_AUTHOR`: module author
  - `KAM_PROP_DESCRIPTION`: module description

- `KAM_TMPL_<NAME>`: Variables defined by a template in `[kam.tmpl.variables]` are exported as `KAM_TMPL_<NAME>` (upper-cased). The same variables are also available for template rendering as `{{ <name> }}`.

- `KAM_<PATH>`: All flattened keys from the `kam.toml` are exported as environment variables using the pattern `KAM_<PATH>`, where dot (`.`) and dash (`-`) are replaced with underscores (`_`) and the key is upper-cased. For example:
  - `prop.id` -> `KAM_PROP_ID`
  - `mmrl.repo.repository` -> `KAM_MMRL_REPO_REPOSITORY`
  - `kam.build.hooks_dir` -> `KAM_KAM_BUILD_HOOKS_DIR`

These variables are added to each hook's environment to make information from `kam.toml` available to hooks without having to re-parse the file.

Default post-build hook behaviors:

 - `8000.SIGN_IF_ENABLE.sh`: If `KAM_SIGN_ENABLED=1`, this hook will run `kam sign` against artifacts in the `dist/` directory. By default it uses `--sigstore --timestamp`. You can disable Sigstore with `KAM_SIGN_SIGSTORE=0` in your environment or `.env` file.
- `9000.UPLOAD_IF_ENABLED.sh`: If `KAM_RELEASE_ENABLED=1`, this hook creates a GitHub Release using the assets in `dist/` and will include signatures (`*.sig`, `*.tsr`, `*.sigstore.json`) automatically if `KAM_SIGN_ENABLE=1` is set. Use `KAM_PRE_RELEASE=1` to create a pre-release. If `KAM_IMMUTABLE_RELEASE=1` is set and the release tag already exists, the upload will be skipped to avoid modifying an immutable release.

| `KAM_SIGN_ENABLED` | Set to `1` when build invoked with `-s/--sign`. Useful to trigger automatic signing in hooks. |
| `KAM_IMMUTABLE_RELEASE` | Set to `1` when build invoked with `-i/--immutable-release`. Hooks can use this to opt into immutable release behavior. |
| `KAM_PRE_RELEASE` | Set to `1` when build invoked with `-P/--pre-release`. Hooks can use this to change release handling (e.g., skip uploads). |

钩子允许你在构建过程中的不同阶段运行自定义脚本。Kam 提供灵活的钩子系统，附带共享的工具和预定义的环境变量，便于在钩子脚本中使用。

### 命名约定

为了区分由模板提供的钩子和项目层面自定义的钩子，Kam 在 `hooks/pre-build/` 和 `hooks/post-build/` 中采用如下命名约定：

- `N.UPPERCASE.xxx`（例如：`0.EXAMPLE.sh`、`2.BUILD_WEBUI.sh`）—— 模板提供的钩子（由模板包含并随模板分发）。
- `N.lowercase.xxx`（例如：`1.custom-script.sh`）—— 项目层面自定义钩子（由模块作者在项目中添加）。

钩子文件按照数值前缀进行顺序执行（例如 `0.*`、`1.*`、`2.*` 等）。若项目中定义了与模板中相同数字前缀的自定义钩子，则会覆盖模板钩子。

### 内置钩子

该构建前（pre-build）钩子会把 `kam.toml` 中的 `[prop]` 部分同步到模块目录的 `module.prop`，并在项目根目录生成 `update.json` 文件。

- 目的：`kam.toml` 是 `module.prop` 的超集。此钩子确保构建前 `module.prop` 是最新的，同时生成的 `update.json` 可供发布/更新工具使用（包含 version、versionCode、zipUrl 与 changelog 等信息）。
- 生成位置：`module.prop` 位于 `src/<module_id>/module.prop`；`update.json` 生成到项目根目录 `update.json`。
- 同步 / 生成字段：
  - `id`
  - `name`
  - `version`
  - `versionCode`

此钩子随标准模板（如 `kam_template`、`meta_template`）包含，并在每次构建前自动运行。

### 执行行为

Kam 在执行钩子时会直接调用钩子文件，由操作系统或文件本身（通过 shebang 或文件关联）决定如何运行。钩子执行器不会基于平台或文件扩展名自动选择解释器。请确保脚本在目标环境中可执行（例如在类 Unix 系统上添加 `#!/bin/sh` 并设置可执行权限 `chmod +x`，在 Windows 上通过 WSL/Git Bash 等工具运行 shell 脚本）。

### 环境变量

执行钩子时，Kam 会注入下列环境变量，供脚本使用：

| 变量 | 说明 |
|------|------|
| `KAM_PROJECT_ROOT` | 项目根目录绝对路径。 |
| `KAM_HOOKS_ROOT` | 钩子目录绝对路径（通常用于引入共享脚本）。 |
| `KAM_MODULE_ROOT` | 模块源码目录绝对路径（例如：`src/<id>`）。 |
| `KAM_WEB_ROOT` | 模块 webroot 目录绝对路径（例如：`<module_root>/webroot`）。 |
| `KAM_DIST_DIR` | 构建输出目录绝对路径（例如：`dist`）。 |
| `KAM_MODULE_ID` | `kam.toml` 中定义的模块 ID。 |
| `KAM_MODULE_VERSION` | 模块版本号。 |
| `KAM_MODULE_VERSION_CODE` | 模块 versionCode。 |
| `KAM_MODULE_NAME` | 模块名称。 |
| `KAM_MODULE_AUTHOR` | 模块作者名。 |
| `KAM_MODULE_DESCRIPTION` | 模块的描述字段（description）。 |
| `KAM_MODULE_UPDATE_JSON` | 若设置，会包含 update JSON 的 URL。 |
| `KAM_STAGE` | 当前构建阶段：`pre-build` 或 `post-build`。 |
| `KAM_DEBUG` | 若设为 `1`，钩子会输出调试信息。 |
| `KAM_SIGN_ENABLED` | 若为 `1` 则表示 build 时带有 `-s/--sign`，钩子可据此触发签名步骤。 |
| `KAM_IMMUTABLE_RELEASE` | 若为 `1` 则表示 build 时带有 `-i/--immutable-release`，钩子可据此选择不可变发布相关行为。 |
| `KAM_PRE_RELEASE` | 若为 `1` 则表示 build 时带有 `-P/--pre-release`，钩子可据此调整发布流程（例如跳过发布）。 |
