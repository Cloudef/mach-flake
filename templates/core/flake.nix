{
  description = "mach-core-project flake";

  inputs = {
    mach.url = "github:Cloudef/mach-flake?rev=8f8396b1fc55adec80b8350c6264d922a0813def";
  };

  outputs = { mach, ... }: let
    flake-utils = mach.inputs.zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Mach flake helper
      # Check the flake.nix in mach-flake project for more options:
      # <https://github.com/Cloudef/mach-flake/blob/master/flake.nix>
      env = mach.outputs.mach-env.${system} {};
    in with builtins; with env.pkgs.lib; rec {
      # Produces clean binaries meant to be ship'd outside of nix
      # e.g. nix build .#foreign
      packages.foreign = env.package {
        src = cleanSource ./.;
        zigBuildFlags = [ "-Doptimize=ReleaseSmall" ];

        # Packages required for compiling
        nativeBuildInputs = with env.pkgs; [];

        # Packages required for linking
        buildInputs = with env.pkgs; [];
      };

      # nix build .
      packages.default = packages.foreign.overrideAttrs (attrs: {
        # Executables required for runtime
        # These packages will be added to the PATH
        zigWrapperBins = with env.pkgs; [];

        # Libraries required for runtime
        # These packages will be added to the LD_LIBRARY_PATH
        zigWrapperLibs = with env.pkgs; [];
      });

      # For bundling with nix bundle for running outside of nix
      # example: https://github.com/ralismark/nix-appimage
      apps.bundle = {
        type = "app";
        program = "${packages.foreign}/bin/mach-core-app";
      };

      # nix run .
      apps.default = env.app [] "zig build run -- \"$@\"";

      # nix run .#build
      apps.build = env.app [] "zig build \"$@\"";

      # nix run .#test
      apps.test = env.app [] "zig build test -- \"$@\"";

      # nix run .#updateMachDeps
      apps.updateMachDeps = env.updateMachDeps;

      # nix run .#zig2nix
      apps.zig2nix = env.app [] "zig2nix \"$@\"";

      # nix develop
      devShells.default = env.mkShell {
        # Packages required for compiling, linking and running
        # Libraries added here will be automatically added to the LD_LIBRARY_PATH and PKG_CONFIG_PATH
        nativeBuildInputs = with env.pkgs; [];
      };
    }));
}
