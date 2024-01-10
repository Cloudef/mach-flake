{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=515e30c15cc6bd87e67ec8ec8a610a5d06f8df83";
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
