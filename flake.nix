{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          self',
          pkgs,
          lib,
          system,
          ...
        }:
        let
          devDeps = with pkgs; [
            fish
            zola
          ];
          mkDevShell =
            arg1:
            pkgs.mkShell {
              shellHook = ''
                exec env SHELL=${pkgs.fish}/bin/fish zellij --layout ./zellij_layout.kdl
              '';
              LB_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
              nativeBuildInputs = devDeps ++ [ arg1 ];
            };
        in
        {
          devShells.default = self'.devShells.stable;

          devShells.stable = (mkDevShell "");
        };
    };
}
