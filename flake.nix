{
  description = "Qoder IDE Flake - Modern Nix packaging for Qoder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          default = pkgs.callPackage ./package.nix { };
          qoder = pkgs.callPackage ./package.nix { };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/qoder";
        };

        # 开发者环境 (Dev Shell)
        # 用法: nix develop
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            git
            curl
          ];
          shellHook = ''
            echo "Qoder Nix Development Environment"
          '';
        };
      }
    ) // {
      # Overlay 允许其他用户方便地将 qoder 集成到他们的系统配置中
      overlays.default = final: prev: {
        qoder = final.callPackage ./package.nix { };
      };
    };
}
