# qoder-nix

[![NixOS](https://img.shields.io/badge/NixOS-ready-blue?logo=nixos)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[中文](#简介) | [English](#introduction)

---

## 简介
这是一个为 **Qoder IDE** 编写的非官方 Nix 打包脚本。

它可以让你在 **NixOS**（或任何安装了 Nix 的 Linux 系统）上轻松运行 Qoder IDE。不再有 `libgbm` 缺失的烦恼，也不再有权限报错！

### 🚀 快速开始

#### 方法 1：直接运行 (无需下载代码)
```bash
nix run github:yourusername/qoder-nix -- --no-sandbox
```

#### 方法 2：添加到 NixOS 配置
如果你想把 `qoder` 永久安装到系统里，可以使用 Overlay：
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    qoder-nix.url = "github:yourusername/qoder-nix";
  };

  outputs = { self, nixpkgs, qoder-nix }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ qoder-nix.overlays.default ];
          environment.systemPackages = [ pkgs.qoder ];
        })
      ];
    };
  };
}
```

### 📂 文件说明
- `flake.nix`: **项目的现代入口**。定义了依赖（inputs）、输出（outputs）和开发环境（devShells）。
- `package.nix`: **构建配方**（原 default.nix）。包含了如何下载 .deb 包、如何解压、以及最重要的——如何修补二进制文件（Auto Patchelf）以适应 NixOS 环境。

---

## Introduction
This is an unofficial Nix derivation for running **Qoder IDE**.

It allows you to run Qoder IDE effortlessly on **NixOS** (or any Linux with Nix). No more missing `libgbm` errors, no more permission issues!

### 🚀 Quick Start

#### Method 1: Instant Run
```bash
nix run github:yourusername/qoder-nix -- --no-sandbox
```

#### Method 2: NixOS Installation (Overlay)
Add to your `flake.nix` to install permanently:
```nix
{
  inputs = {
    qoder-nix.url = "github:yourusername/qoder-nix";
  };
  # ... using the overlay ...
  nixpkgs.overlays = [ qoder-nix.overlays.default ];
  environment.systemPackages = [ pkgs.qoder ];
}
```

### 📂 Project Structure
- `flake.nix`: **The modern entry point**. Defines dependencies (inputs), build targets (outputs), and development shells.
- `package.nix`: **The build recipe**. It contains the logic for downloading the `.deb`, unpacking it, and patching the binaries (Auto Patchelf) for NixOS.

## License
MIT License - see [LICENSE](LICENSE) for details.

## Disclaimer
This is an unofficial package. Qoder is a product of its respective owners.
