{
  description = "Qoder IDE Flake - 现代化的 Nix 项目入口";

  # 输入源 (Inputs)
  # 这里定义了我们依赖的上游仓库，主要是 Nixpkgs
  inputs = {
    # 锁定使用 unstable 分支，因为 Qoder 可能依赖较新的库
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # 输出集 (Outputs)
  # 这里定义了当我们运行 `nix run` 或 `nix build` 时会发生什么
  outputs = { self, nixpkgs }:
    let
      # 目标系统架构
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # 定义软件包 'default'
      # 当你运行 `nix build` 时，Nix 会构建这个包
      packages.${system}.default = pkgs.callPackage ./default.nix { };

      # 定义应用 'default'
      # 当你运行 `nix run` 时，Nix 会直接启动这个程序
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/qoder";
      };
    };
}
