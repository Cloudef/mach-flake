{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=8d183901dca8079a86779f9e575026f91e35ae66";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
      doubles = env.pkgs.lib.systems.doubles.all ++ [ "aarch64-ios" ];

      # Map some doubles to become Mach compatible targets
      resolve-target = double: {
        # Nix defaults to x86_64-windows-msvc
        x86_64-windows = "x86_64-windows-gnu";
      }."${double}" or double;
    in with builtins; with env.pkgs.lib; rec {
      # nix build .#target.{nix-target}
      # e.g. nix build .#target.x86_64-linux
      packages.target = genAttrs doubles (double: let
        target = resolve-target double;
      in env.packageForTarget target ({
        src = ./.;

        nativeBuildInputs = with env.pkgs; [];
        buildInputs = with env.pkgsForTarget target; [];

        # Smaller binaries and avoids shipping glibc.
        zigPreferMusl = true;

        # This disables LD_LIBRARY_PATH mangling, binary patching etc...
        # The package won't be usable inside nix.
        zigDisableWrap = true;

        zigBuildFlags = [ "-Doptimize=ReleaseSmall" ];
      }));

      # nix build .
      packages.default = packages.target.${system}.override {
        # Prefer nix friendly settings.
        zigPreferMusl = false;
        zigDisableWrap = false;
      };

      # For bundling with nix bundle for running outside of nix
      # example: https://github.com/ralismark/nix-appimage
      apps.bundle.target = genAttrs doubles (double: let
        pkg = packages.target.${double};
      in {
        type = "app";
        program = "${pkg}/bin/myapp";
      });

      # default bundle
      apps.bundle.default = apps.bundle.target.${system};

      # nix run .
      apps.default = env.app [] "zig build run -- \"$@\"";

      # nix run .#build
      apps.build = env.app [] "zig build \"$@\"";

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
