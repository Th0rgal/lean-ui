{
  description = "lean-ui — 100% Lean 4 GPU-accelerated Wayland + Vulkan UI framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          lakeGuard = pkgs.writeShellScriptBin "lake" ''
            echo "error: raw 'lake' is forbidden by lean-ui AGENTS.md; use 'turbo-lean' instead." >&2
            exit 1
          '';
          elanGuard = pkgs.writeShellScriptBin "elan" ''
            echo "error: raw 'elan' is forbidden by lean-ui AGENTS.md; use the pinned toolchain via 'turbo-lean'." >&2
            exit 1
          '';
        in {
          default = pkgs.mkShell {
            buildInputs = [
              lakeGuard
              elanGuard
              pkgs.clang
              pkgs.lld
              pkgs.pkg-config
              pkgs.wayland
              pkgs.libxkbcommon
              pkgs.vulkan-loader
              pkgs.vulkan-headers
              pkgs.glslang
              pkgs.harfbuzz
              pkgs.freetype
              pkgs.fontconfig
            ];
            TURBO_LEAN_EMIT_C = "1";
            CC = "clang";
          };
        });
    };
}
