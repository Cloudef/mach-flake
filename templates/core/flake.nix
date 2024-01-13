{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=79d35bf10e1e267b9596b347f6c107ea18f145ac";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
    in rec {
      # nix package .
      packages.default = env.package {
        src = ./.;
      };

      # For bundling with nix bundle for running outside of nix
      # example: https://github.com/ralismark/nix-appimage
      apps.bundle = let
        pkg = packages.default.override {
          # This disables LD_LIBRARY_PATH mangling.
          # vulkan-loader, x11, wayland, etc... won't be included in the bundle.
          zigDisableWrap = true;

          # Smaller binaries and avoids shipping glibc.
          zigPreferMusl = true;
        };
      in {
        type = "app";
        program = "${pkg}/bin/myapp";
      };

      # nix run .
      apps.default = env.app [] "zig build run -- \"$@\"";

      # nix run .#test
      apps.test = env.app [] "zig build test -- \"$@\"";

      # nix run .#docs
      apps.docs = env.app [] "zig build docs -- \"$@\"";

      # nix run .#update-mach-deps
      apps.update-mach-deps = env.update-mach-deps;

      # nix run .#zon2json
      apps.zon2json = env.app [env.zon2json] "zon2json \"$@\"";

      # nix run .#zon2json-lock
      apps.zon2json-lock = env.app [env.zon2json-lock] "zon2json-lock \"$@\"";

      # nix run .#zon2nix
      apps.zon2nix = env.app [env.zon2nix] "zon2nix \"$@\"";

      # nix develop
      devShells.default = env.shell;
    }));
}
