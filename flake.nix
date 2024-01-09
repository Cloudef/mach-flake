{
  description = "mach engine flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, ... }: with builtins;
  (flake-utils.lib.eachDefaultSystem (system:
    let
      # Mach nominated Zig versions
      # <https://machengine.org/about/nominated-zig/>
      zigv = import ./versions.nix {
        inherit system;
        pkgs = nixpkgs.outputs.legacyPackages.${system};
      };

      # Flake helper for Mach projects
      mach-env = {
        pkgs ? nixpkgs.outputs.legacyPackages.${system},
        zig ? zigv.mach-latest,
        customRuntimeDeps ? [],
        customLdPreload ? [],
        customAppHook ? "",
        customDevShellHook ? "",
        # mach-core example currently panics
        # error(mach): glfw: error.FeatureUnavailable: Wayland: The platform does not provide the window position
        # so we disable wayland by default
        enableWayland ? false,
        enableX11 ? true,
      }: let
        lib = pkgs.lib;
        # Solving platform specific spaghetti below
        _linux_deps = with pkgs; [ vulkan-loader ]
          ++ lib.optionals (enableX11) [ xorg.libX11 ]
          ++ lib.optionals (enableWayland) [ wayland libxkbcommon ];
        _linux_ld_preload = with pkgs; [ vulkan-loader ]
          ++ lib.optionals (enableX11) [ xorg.libX11 ]
          ++ lib.optionals (enableWayland) [ wayland libxkbcommon ];
        _linux_extra = let
          ld_string = (concatStringsSep "/lib:" _linux_ld_preload) + "/lib";
        in ''
          export ZIG_BTRFS_WORKAROUND=1
          export LD_LIBRARY_PATH="${ld_string}:$LD_LIBRARY_PATH"
        '';

        _deps = [ zig ] ++ customRuntimeDeps
          ++ lib.optionals (pkgs.stdenv.isLinux) _linux_deps;
        _extraApp = customAppHook
          + lib.optionalString (pkgs.stdenv.isLinux) _linux_extra;
        _extraShell = customDevShellHook
          + lib.optionalString (pkgs.stdenv.isLinux) _linux_extra;
      in rec {
        # Inherit given pkgs and zig version
        inherit pkgs zig;

        # Flake app helper (without mach-env and allows running from non root dir)
        app-bare-no-root = deps: script: {
          type = "app";
          program = toString (pkgs.writeShellApplication {
            name = "app";
            runtimeInputs = [] ++ deps;
            text = ''
              # shellcheck disable=SC2059
              error() { printf -- "error: $1" "''${@:1}" 1>&2; exit 1; }
              ${script}
              '';
          }) + "/bin/app";
        };

        # Flake app helper (without mach-env)
        app-bare = deps: script: app-bare-no-root deps ''
          [[ -f ./flake.nix ]] || error 'Run this from the project root'
          ${script}
          '';

        # Flake app helper
        app = deps: script: app-bare (deps ++ _deps) ''
          ${_extraApp}
          ${script}
          '';

        # Creates dev shell
        shell = pkgs.mkShell {
          buildInputs = _deps;
          shellHook = _extraShell;
        };

        # TODO: utility for updating mach deps in build.zig.zon
        #       useful if downstream does `flake update`
      };

      # Default mach env used by this flake
      env = mach-env {};
      app = env.app-bare;
    in rec {
      # zig for mach version
      inherit zigv;

      # mach-env
      inherit mach-env;

      # nix run
      apps.zig = mapAttrs (k: v: (mach-env {zig = v;}).app ''zig "$@"'') zigv;

      # nix develop
      devShells.zig = mapAttrs (k: v: (mach-env {zig = v;}).shell) zigv;
      devShells.default = devShells.zig.mach-latest;

      # nix run .#update-versions
      apps.update-versions = with env.pkgs; app [ curl jq ] ''
        curl https://machengine.org/zig/index.json | jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))'
        '';

      # nix run .#update-templates
      apps.update-templates = with env.pkgs; app [ coreutils gnused git env.zig jq ] ''
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT
        generate_zig_zon() {
        cat <<EOF
        .{
            .name = "$1",
            .version = "0.1.0",
            .paths = .{
              "build.zig.zon",
              "build.zig",
              "src",
            },
            .dependencies = .{
              .''${2/-/_} = .{
                .url = "$3",
                .hash = "$4",
              },
            },
        }
        EOF
        }

        generate() {
          url="https://pkg.machengine.org/$2/$3.tar.gz"
          hash=$(cd "$tmpdir"; zig fetch "$url")
          generate_zig_zon "$1" "$2" "$url" "$hash"
        }

        generate_json() {
          while [[ $# -gt 0 ]]; do
            url="https://pkg.machengine.org/$1/$2.tar.gz"
            hash=$(cd "$tmpdir"; zig fetch "$url")
            printf '{"%s":{"url":"%s","hash":"%s","rev":"%s"}}' "$1" "$url" "$hash" "$2"
            shift 2
          done | jq -s add
        }

        flake_rev="$(git rev-parse HEAD)"

        read -r mach_engine_rev _ < <(git ls-remote https://github.com/hexops/mach.git HEAD)
        mkdir -p templates/engine
        generate mach-engine-project mach "$mach_engine_rev" > templates/engine/build.zig.zon
        sed "s/SED_REPLACE_REV/$flake_rev/" templates/flake.nix > templates/engine/flake.nix

        read -r mach_core_rev _ < <(git ls-remote https://github.com/hexops/mach-core.git HEAD)
        rm -rf templates/core
        git clone https://github.com/hexops/mach-core-starter-project.git templates/core
        rm -rf templates/core/.git
        generate mach-core-project mach-core "$mach_core_rev" > templates/core/build.zig.zon
        sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
        sed -i "s/SED_REPLACE_REV/$flake_rev/" templates/core/flake.nix

        generate_json \
          mach "$mach_engine_rev" \
          mach-core "$mach_core_rev" \
          > templates/zig-deps.json
        '';

      # nix run .#test
      apps.test = app [] ''
        (cd templates/engine; nix run --override-input mach ../..  .#test)
        (cd templates/core; nix run --override-input mach ../..  .#test)
        '';

      # nix run .#readme
      apps.readme = let
        project = "Mach Engine Flake";
      in with env.pkgs; app [ jq ] (replaceStrings ["`"] ["\\`"] ''
      cat <<EOF
      # ${project}

      Flake that allows you to get started with Mach engine quickly.

      https://machengine.org/

      ---

      [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

      * Mach Zig: `${env.zig.version} @ ${env.zig.machNominated}`
      * Mach Engine: `$(jq -r '.mach.rev' templates/zig-deps.json)`
      * Mach Core: `$(jq -r '."mach-core".rev' templates/zig-deps.json)`

      ## Mach Engine

      ```bash
      nix flake init -t github:Cloudef/mach-flake#engine
      nix run .
      # for more options check the flake.nix file
      ```

      ## Mach Core

      ```bash
      nix flake init -t github:Cloudef/mach-flake#core
      nix run .
      # for more options check the flake.nix file
      ```

      ## Using Mach nominated Zig directly

      ```bash
      nix run github:Cloudef/mach-flake#zig.mach-latest -- version
      ```
      EOF
      '');

      # for debugging
      apps.repl = flake-utils.lib.mkApp {
        drv = env.pkgs.writeShellScriptBin "repl" ''
          confnix=$(mktemp)
          echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
          trap "rm $confnix" EXIT
          nix repl $confnix
          '';
      };
    })) // rec {
      # nix flake init -t templates#engine
      templates.engine = {
        path = ./templates/engine;
        description = "Mach engine project";
        welcomeText = ''
          # Mach engine project template
          - Mach engine: https://machengine.org/engine/

          ## Build & Run

          ```
          nix run .
          ```

          See flake.nix for more options.
          '';
      };

      # nix flake init -t templates#core
      templates.core = {
        path = ./templates/core;
        description = "Mach core project";
        welcomeText = ''
          # Mach core project template
          - Mach core: https://machengine.org/core/

          ## Build & Run

          ```
          nix run .
          ```

          See flake.nix for more options.
          '';
      };

      # nix flake init -t templates
      templates.default = templates.engine;
    };
}
