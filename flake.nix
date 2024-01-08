{
  description = "mach engine flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, ... }:
  (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.outputs.legacyPackages.${system};
      app-no-root = deps: script: {
        type = "app";
        program = toString (pkgs.writeShellApplication {
          name = "app";
          runtimeInputs = [] ++ deps;
          text = ''
            # shellcheck disable=SC2059
            error() { printf -- "error: $1" "''${@:1}" 1>&2; exit 1; }
            export ZIG_BTRFS_WORKAROUND=1
            ${script}
            '';
        }) + "/bin/app";
      };
      app = deps: script: app-no-root deps ''
        [[ -f ./flake.nix ]] || error 'Run this from the project root'
        ${script}
        '';
    in rec {
      # zig for mach version
      zigv = import ./versions.nix { inherit system pkgs; };

      # nix run
      apps.zig = builtins.mapAttrs (k: v: app-no-root [v] ''zig "$@"'') zigv;

      # nix develop
      devShells = builtins.mapAttrs (k: v: pkgs.mkShell {
        buildInputs = [v];
        shellHook = "export ZIG_BTRFS_WORKAROUND=1";
      }) zigv;

      # nix run .#update-versions
      apps.update-versions = with pkgs; app [ curl jq ] ''
        curl https://machengine.org/zig/index.json | jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))'
        '';

      # nix run .#update-templates
      apps.update-templates = let
        zig = zigv.mach-latest;
      in with pkgs; app [ coreutils gnused git zig ] ''
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

        flake_rev="$(git rev-parse HEAD)"

        git ls-remote https://github.com/hexops/mach.git HEAD | while read -r rev _; do
          mkdir -p templates/engine
          generate mach-engine-project mach "$rev" > templates/engine/build.zig.zon
          sed "s/SED_REPLACE_REV/$flake_rev/" templates/flake.nix > templates/engine/flake.nix
        done

        git ls-remote https://github.com/hexops/mach-core.git HEAD | while read -r rev _; do
          rm -rf templates/core
          git clone https://github.com/hexops/mach-core-starter-project.git templates/core
          rm -rf templates/core/.git
          generate mach-core-project mach-core "$rev" > templates/core/build.zig.zon
          sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
          sed -i "s/SED_REPLACE_REV/$flake_rev/" templates/core/flake.nix
        done
        '';

      apps.test = app [] ''
        (cd templates/engine; nix run --override-input mach ../..  .#test)
        (cd templates/core; nix run --override-input mach ../..  .#test)
        '';

      # nix run .#readme
      apps.readme = let
        project = "Mach Engine Flake";
      in app [] (builtins.replaceStrings ["`"] ["\\`"] ''
      cat <<EOF
      # ${project}

      Flake that allows you to get started with Mach engine quickly.

      https://machengine.org/

      ---

      [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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
        drv = pkgs.writeShellScriptBin "repl" ''
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
