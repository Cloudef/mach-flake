{
  description = "mach-core-project flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    mach.url = "github:Cloudef/mach-flake?rev=48119d403712523ab59b0cc5450050add288cb43";
  };

  outputs = { flake-utils, nixpkgs, mach, ... }:
  (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.outputs.legacyPackages.${system};
      lib = pkgs.lib;

      # Change `mach-latest` here if you want to target different mach version.
      # The correct zig version will be used.
      # You may have to update your dependencies in build.zig.zon as well.
      # See <https://machengine.org/about/nominated-zig/> for more information.
      zig = mach.outputs.zigv.${system}."mach-latest";

      # enable x11?
      enable_x11 = true;

      # enable wayland?
      # mach-core example currently panics
      # error(mach): glfw: error.FeatureUnavailable: Wayland: The platform does not provide the window position
      # so we disable wayland by default
      enable_wayland = false;

      # Solving platform specific spaghetti below
      _linux_deps = with pkgs; [ vulkan-loader ]
        ++ lib.optionals (enable_x11) [ xorg.libX11 ]
        ++ lib.optionals (enable_wayland) [ wayland libxkbcommon ];
      _linux_extra = ''
        export ZIG_BTRFS_WORKAROUND=1
        export LD_LIBRARY_PATH="${pkgs.vulkan-loader}/lib:$LD_LIBRARY_PATH"
        '' + lib.optionalString (enable_x11) ''export LD_LIBRARY_PATH="${pkgs.xorg.libX11}/lib:$LD_LIBRARY_PATH"''
           + lib.optionalString (enable_wayland) ''export LD_LIBRARY_PATH="${pkgs.wayland}/lib:${pkgs.libxkbcommon}/lib:$LD_LIBRARY_PATH"'';

      _deps = [ zig ] ++ lib.optionals (pkgs.stdenv.isLinux) _linux_deps;
      _extra = lib.optionalString (pkgs.stdenv.isLinux) _linux_extra;

      # Flake app helper
      app = deps: script: {
        type = "app";
        program = toString (pkgs.writeShellApplication {
          name = "app";
          runtimeInputs = _deps ++ deps;
          text = ''
            # shellcheck disable=SC2059
            error() { printf -- "error: $1" "''${@:1}" 1>&2; exit 1; }
            [[ -f ./flake.nix ]] || error 'Run this from the project root'
            ${_extra}
            ${script}
            '';
        }) + "/bin/app";
      };
    in {
      # nix run .#
      apps.default = app [] "zig build run -- \"$@\"";

      # nix run .#test
      apps.test = app [] "zig build test -- \"$@\"";

      # nix run .#docs
      apps.docs = app [] "zig build docs -- \"$@\"";

      # nix develop
      devShells.default = pkgs.mkShell {
        buildInputs = _deps;
        shellHook = _extra;
      };
    }));
}
