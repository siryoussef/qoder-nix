# 这就是核心构建文件 (The Core Build Construction)
# 只要有这个文件，任何安装了 Nix 的 Linux 系统都能跑起来。
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.stdenv.mkDerivation rec {
  pname = "qoder";
  version = "1.0.0";

  # 1. 软件源 (Source)
  # 使用 fetchurl 自动从官网下载，而不是依赖本地文件。
  # 这样别人拿着这个脚本就能跑，不需要手动下载 .deb
  src = pkgs.fetchurl {
    url = "https://download.qoder.com/release/latest/qoder_amd64.deb";
    # SHA256 确保下载文件的安全性
    sha256 = "1gwhvi306h98x9ipf25g6cqph4vf2c643qdlns3sqdc32w9n95f4";
  };

  # 2. 构建工具 (Build Tools)
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook  # 自动外科医生：修正二进制文件里的库路径
    makeWrapper       # 包装大师：给程序穿上环境变量的外套
    binutils          # 工具箱：提供 'ar' 命令用来拆包
  ];

  # 3. 运行依赖 (Runtime Dependencies)
  # Qoder 运行需要的所有库都在这里。
  # autoPatchelfHook 会自动把二进制文件里的 /lib/xxx 替换成这些库的真实路径。
  buildInputs = with pkgs; [
    # 音频视频
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    pango
    
    # 系统底层
    dbus
    expat
    glib
    nspr
    nss
    systemd      # 包含 libudev
    libuuid
    
    # 界面 UI
    gtk3
    gdk-pixbuf
    libnotify    # 弹窗通知
    libsecret    # 密码管理
    
    # 图形驱动相关 (Wayland/OpenGL)
    libdrm
    libglvnd
    mesa
    wayland
    libxkbcommon
    
    # X11 视窗系统全家桶
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
  # 为什么要自己写？因为 dpkg 解压时会尝试保留 root 权限 (suid)，
  # 但 Nix 构建过程没有 root 权限，会报错。
  # 所以我们用 ar + tar 手动解压，并忽略权限。
  unpackPhase = ''
    ar x $src
    tar -x --no-same-owner --no-same-permissions -f data.tar.xz
  '';

  # 5. 安装阶段 (Install Phase)
  # 把解压好的文件搬到 Nix 的输出目录 ($out)
  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/

    # 创建 bin 目录的软链接
    mkdir -p $out/bin
    if [ -f $out/share/qoder/qoder ]; then
      ln -s $out/share/qoder/qoder $out/bin/qoder
    else
      echo "Error: Main executable not found!"
      exit 1
    fi
  '';

  # 6. 后处理阶段 (Post Fixup)
  # 解决 "libgbm.so.1" 找不到的问题。
  # 有些库是程序运行时动态加载的（Plugin），autoPatchelf 检测不到。
  # 我们强制设置 LD_LIBRARY_PATH 告诉程序去哪里找它们。
  postFixup = ''
    wrapProgram $out/share/qoder/qoder \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.mesa pkgs.libglvnd ]}"
  '';

  meta = with pkgs.lib; {
    description = "Qoder IDE - Agentic Coding IDE";
    homepage = "https://qoder.com";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ]; # 你可以把你的名字写在这
  };
}
