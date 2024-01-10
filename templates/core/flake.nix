{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=70ddceb163173d4b33633465f7de248c5a2c7e14";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
    in {
      # nix build
      # <https://github.com/NixOS/nixpkgs/blob/master/doc/hooks/zig.section.md>
      packages.default = env.pkgs.stdenvNoCC.mkDerivation {
        pname = "mach-core-project";
        version = "0.1.0";
        nativeBuildInputs = [env.zig.hook];
        src = ./.;
      };

      # nix run .#
      apps.default = env.app [] "zig build run -- \"$@\"";

      # nix run .#test
      apps.test = env.app [] "zig build test -- \"$@\"";

      # nix run .#docs
      apps.docs = env.app [] "zig build docs -- \"$@\"";

      # nix develop
      devShells.default = env.shell;
    }));
}
