# Qoder IDE on NixOS (unofficial)

[中文](#简介) | [English](#introduction)

---

## 简介
这是一个为 **Qoder IDE** 编写的非官方 Nix 打包脚本。

它可以让你在 **NixOS**（或任何安装了 Nix 的 Linux 系统）上轻松运行 Qoder IDE。不再有 `libgbm` 缺失的烦恼，也不再有权限报错！

### 🚀 快速开始

#### 方法 1：直接运行 (无需下载代码)
如果你的电脑开启了 Flakes 功能，只需一行代码：
```bash
nix run github:yourusername/qoder-nix -- --no-sandbox
```

#### 方法 2：本地运行
如果你下载了本仓库的代码：
```bash
# 运行
nix run . -- --no-sandbox

# 或者构建并安装
nix build
./result/bin/qoder --no-sandbox
```

### 📂 文件说明
- `flake.nix`: **项目的现代入口**。定义了依赖（inputs）和输出（outputs）。当你使用 `nix run` 命令时，Nix 就是从这里开始读取的。
- `default.nix`: **构建配方**。包含了如何下载 .deb 包、如何解压、以及最重要的——如何修补二进制文件（Auto Patchelf）以适应 NixOS 环境。如果你想学习如何打包闭源软件，或者是为其他 .deb 软件打包，请阅读此文件的注释。

---

## Introduction
This is an unofficial Nix derivation for running **Qoder IDE**.

It allows you to run Qoder IDE effortlessly on **NixOS** (or any Linux with Nix). No more missing `libgbm` errors, no more permission issues!

### 🚀 Quick Start

#### Method 1: Instant Run (Zero Setup)
If you have Flakes enabled:
```bash
nix run github:yourusername/qoder-nix -- --no-sandbox
```

#### Method 2: Local Run
If you have cloned this repository:
```bash
# Run instantly
nix run . -- --no-sandbox

# Or build manually
nix build
./result/bin/qoder --no-sandbox
```

### 📂 Project Structure
- `flake.nix`: **The modern entry point**. Defines dependencies (inputs) and build targets (outputs). This is what `nix run` reads.
- `default.nix`: **The build recipe**. It contains the logic for downloading the `.deb`, unpacking it, and patching the binaries (Auto Patchelf) for NixOS. Read the comments in this file if you want to learn how to package preparatory software for Nix.
