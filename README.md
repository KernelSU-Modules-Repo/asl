[![Release](https://img.shields.io/github/v/release/KernelSU-Modules-Repo/asl?label=release&color=blue&style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![License](https://img.shields.io/github/license/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/blob/main/LICENSE) [![Last commit](https://img.shields.io/github/last-commit/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/commits/main) [![Issues](https://img.shields.io/github/issues/KernelSU-Modules-Repo/asl?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/issues)

[![Stars](https://img.shields.io/github/stars/KernelSU-Modules-Repo/asl?style=social)](https://github.com/KernelSU-Modules-Repo/asl/stargazers) [![Downloads](https://img.shields.io/github/downloads/KernelSU-Modules-Repo/asl/total?style=flat-square)](https://github.com/KernelSU-Modules-Repo/asl/releases) [![Sponsor](https://img.shields.io/badge/Sponsor-GitHub-brightgreen?style=flat-square)](https://github.com/sponsors/LIghtJUNction)

---
# ![Screenshot](Screenshot_2025-12-08-01-18-25-97_84d3000e3f4017145260f7618db1d683.jpg)

---
# Note
- 出于简洁性考虑，最新版本已经不再内置zsh zim框架 并强制依赖于termux
- 你可以下载旧版，旧版使用zsh，新版仅包含rurima/ruri
---
How to build & install？ / 如何下载 & 安装？
============================================
- Termux :
1. Clone the repository:
   ```bash
   git clone https://github.com/KernelSU-Modules-Repo/asl.git
   ```

2. Navigate to the cloned directory:
   ```bash
   cd asl
   ```

3. Build the module:
   ```bash
   kam build
   ```

4. Install the module:
   ```bash
   kam install
   ```

> Kam(v0.5.17+)：
   ```bash
   kam install KernelSU-Modules-Repo/asl
   ```

What is this? / 这是干什么的？
============================================

这是一个来自 asl 的 fork（实际上改的不像样子了，逻辑上比原模块简单~~不少~~，体积大幅减少，因为依赖了termux）
                            — 文档聚焦于 Kam 的构建钩子系统（hooks）。  

This is a fork from asl (actually quite different from the original, logically much simpler than the original module, and significantly smaller in size, because it depends on termux) — the documentation focuses on Kam's build hook system.  

---
Cyber Amber | 赛博琥珀(🤔
- This module is from the official kernel-su module repository and is the first project to use developer private keys for automated signing.

- In addition to automated signing, there's also automated changelog updates, automated version number updates, automated Rurima dependency updates, automated Zim module updates, and even interactive installation to the device after packaging (I haven't added this hook script yet, but it'll be soon).


- What is a developer's private key?
Developer private key obtained from the developers repository

- Release attestation
(json) As long as immutable publishing is enabled, there will be

- Developer private key signing, automated signing by KAM.

- The signature file has the .sig extension and can be verified with my public key.


Quick start / 快速开始
--------------------------------------------

### Download & install / 下载与安装
- Download releases: https://github.com/KernelSU-Modules-Repo/asl/releases  

- download termux

- su

- rurima

- rurima dep # check dependencies

- rurima pull # pull image

example

- cd /data

- mkdir asl && cd asl

- https://images.linuxcontainers.org/

- rurima pull alpine:edge ./alpine

- rurima r ./alpine

- note!

- modify /etc/resolv.conf
(To remove old files and create new ones, you can use MT Manager or other tools, or you can do it via the command line.)
- Write some DNS server configuration

- You will now be able to access the internet.

- How do I uninstall it?

- ./alpine/.rurienv It has been set to an unmodifiable attribute; remove it using `chattr -i ./alpine/.rurienv`.


--------------------------------------------

### Action secrets / GitHub Actions（CI）
- `KAM_PRIVATE_KEY`: Add this secret (PEM content) to your repository to enable CI signing.
- Keep secrets secure — do not commit private keys to the repository.

Overview / 概述
--------------------------------------------
Kam hooks let you run custom scripts at different stages of the build lifecycle. Hooks are small scripts placed under `hooks/pre-build/` or `hooks/post-build/` and executed via `kam build`.

Kam 钩子允许你在构建流程不同阶段运行自定义脚本（`hooks/pre-build/`, `hooks/post-build/`），便于在构建前后进行同步、签名、上传等操作。
}

Licensing / 许可与引用
--------------------------------------------
This project is a fork of [asl](https://github.com/RuriOSS/asl). Keep attributions and follow the original license (see `LICENSE`).

---
