# 这就是核心构建文件 (The Core Build Construction)
{pkgs ? import <nixpkgs> {config.allowUnfree = true;}}:
pkgs.stdenv.mkDerivation rec {
  pname = "qoder";
  version = "1.0.0";

  # 1. 软件源 (Source)
  # WARNING: 官方使用的是 "latest" 链接。如果官方发布了新版本，
  # 这个文件的 sha256 就会改变，导致构建失败 (Hash Mismatch)。
  # 解决方法：运行 `nix-prefetch-url ...` 获取新哈希并更新此处。
  src = pkgs.fetchurl {
    url = "https://download.qoder.com/release/latest/qoder_amd64.deb";
    sha256 = "sha256-5Zkdwk5dnW6k90ncmaXHJEcNYCHJLYESS0P6CNVgqVk=";
  };

  # 2. 构建工具 (Build Tools)
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook # 自动链接库
    makeWrapper # 包装程序
    binutils # 用于 ar 命令
  ];

  # 3. 运行依赖 (Runtime Dependencies)
  # 这里的库会被 autoPatchelfHook 链接到二进制文件中。
  buildInputs = with pkgs; [
    # 基础 UI 库
    gtk3
    cairo
    pango
    gdk-pixbuf
    glib

    # 系统服务与底层库
    alsa-lib
    at-spi2-atk
    at-spi2-core
    dbus
    expat
    libuuid
    nspr
    nss
    systemd # 包含 libudev

    # 桌面集成
    libnotify # 通知
    libsecret # 密钥环

    # 显卡与 Wayland 支持
    libdrm
    libglvnd
    mesa
    wayland
    libxkbcommon

    # X11 支持
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    xorg.libxkbfile
  ];

  # 4. 解压阶段 (Unpack Phase)
  # 手动解压以绕过 dpkg 的 SUID 权限检查
  unpackPhase = ''
    ar x $src
    tar -x --no-same-owner --no-same-permissions -f data.tar.xz
  '';

  # 5. 安装阶段 (Install Phase)
  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/

    # 确保 bin 存在并创建符号链接
    mkdir -p $out/bin
    if [ -f $out/share/qoder/qoder ]; then
      ln -s $out/share/qoder/qoder $out/bin/qoder
    else
      echo "Error: Main executable not found!"
      exit 1
    fi
  '';

  # 6. 后处理 (Post Fixup)
  # 强制注入 runtime library path，解决动态加载库 (如 libgbm) 找不到的问题
  postFixup = ''
    wrapProgram $out/share/qoder/qoder \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.mesa pkgs.libglvnd]}"

    # Fix desktop file path
    substituteInPlace $out/share/applications/qoder.desktop \
      --replace "/usr/share/qoder/qoder" "$out/bin/qoder"
  '';

  meta = with pkgs.lib; {
    description = "Qoder IDE - Agentic Coding IDE";
    homepage = "https://qoder.com";
    # 这是一个闭源商业软件，必须标记为 unfree
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
