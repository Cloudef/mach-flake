{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=8c3600cd199c171e3e9b5d38a3ecaaaa1012ec3b";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
    in {
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
