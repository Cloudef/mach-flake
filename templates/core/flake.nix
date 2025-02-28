{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=5d5236941ad5a805a3242956fcd042c17a6d39d6";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
      system-triple = env.lib.zigTripleFromString system;
    in with builtins; with env.lib; with env.pkgs.lib; rec {
      # nix build .#target.{zig-target}
      # e.g. nix build .#target.x86_64-linux-gnu
      packages.target = genAttrs allTargetTriples (target: env.packageForTarget target {
        src = cleanSource ./.;

        nativeBuildInputs = with env.pkgs; [];
        buildInputs = with env.pkgsForTarget target; [];

        # Smaller binaries and avoids shipping glibc.
        # XXX: Disabled for now due to builds failing.
        zigPreferMusl = false;

        # This disables LD_LIBRARY_PATH mangling, binary patching etc...
        # The package won't be usable inside nix.
        zigDisableWrap = true;

        zigBuildFlags = [ "-Doptimize=ReleaseSmall" ];
      });

      # nix build .
      packages.default = packages.target.${system-triple}.override {
        # Prefer nix friendly settings.
        zigPreferMusl = false;
        zigDisableWrap = false;
      };

      # For bundling with nix bundle for running outside of nix
      # example: https://github.com/ralismark/nix-appimage
      apps.bundle.target = genAttrs allTargetTriples (target: let
        pkg = packages.target.${target};
      in {
        type = "app";
        program = "${pkg}/bin/myapp";
      });

      # default bundle
      apps.bundle.default = apps.bundle.target.${system-triple};

      # nix run .
      apps.default = env.app [] "zig build run -- \"$@\"";

      # nix run .#test
      apps.test = env.app [] "zig build test -- \"$@\"";

      # nix run .#build
      apps.build = env.app [] "zig build \"$@\"";

      # nix run .#updateMachDeps
      apps.updateMachDeps = env.updateMachDeps;

      # nix run .#zon2json
      apps.zon2json = env.app [env.zon2json] "zon2json \"$@\"";

      # nix run .#zon2json-lock
      apps.zon2json-lock = env.app [env.zon2json-lock] "zon2json-lock \"$@\"";

      # nix run .#zon2nix
      apps.zon2nix = env.app [env.zon2nix] "zon2nix \"$@\"";

      # nix develop
      devShells.default = env.mkShell {};
    }));
}
