{
  description = "mach engine flake";
  inputs.zig2nix.url = "github:Cloudef/zig2nix";

  outputs = { zig2nix, ... }: with builtins; let
    flake-utils = zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      #! Structures.

      zig-env = zig2nix.zig-env.${system};
      _pkgs = (zig-env {}).pkgs;

      # Mach nominated Zig versions.
      # <https://machengine.org/about/nominated-zig/>
      zigv = import ./versions.nix {
        inherit system;
        pkgs = _pkgs;
      };

      #: Helper function for building and running Mach projects.
      mach-env = {
        # Overrideable nixpkgs.
        pkgs ? _pkgs,
        # Zig version to use. Normally there is no need to change this.
        zig ? zigv.mach-latest,
        # Additional runtime deps to inject into the helpers.
        customRuntimeDeps ? [],
        # Additional runtime libs to inject to the helpers.
        # Gets included in LD_LIBRARY_PATH and DYLD_LIBRARY_PATH.
        customRuntimeLibs ? [],
        # Custom prelude in the flake app helper.
        customAppHook ? "",
        # Custom prelude in the flake shell helper.
        customDevShellHook ? "",
        # Enable Vulkan support.
        enableVulkan ? true,
        # Enable Wayland support.
        # Disabled by default because mach-core example currently panics with:
        # error(mach): glfw: error.FeatureUnavailable: Wayland: The platform does not provide the window position
        enableWayland ? false,
        # Enable X11 support.
        enableX11 ? true,
      }: let
        env = zig-env {
          # https://nixos.wiki/wiki/Nix_Language_Quirks#Default_values_are_not_bound_in_.40_syntax
          inherit pkgs zig;
          inherit customRuntimeDeps customRuntimeLibs;
          inherit customAppHook customDevShellHook;
          inherit enableVulkan enableWayland enableX11;
        };
      in (env // {
        #! --- Outputs of mach-env {} function.
        #!     access: (mach-env {}).thing

        #! QOI - The “Quite OK Image Format” for fast, lossless image compression
        #! Packages the `qoiconv` binary.
        #! <https://github.com/phoboslab/qoi/tree/master>
        extraPkgs.qoi = import ./packages/qoi.nix { inherit pkgs; };

        #! Packages mach project.
        #! NOTE: You must first generate build.zig.zon2json-lock using zon2json-lock.
        #!       It is recommended to commit the build.zig.zon2json-lock to your repo.
        #!
        #! Additional attributes:
        #!    zigTarget: Specify target for zig compiler, defaults to nix host.
        #!    zigDisableWrap: makeWrapper will not be used. Might be useful if distributing outside nix.
        #!    zigWrapperArgs: Additional arguments to makeWrapper.
        #!    zigBuildZon: Path to build.zig.zon file, defaults to build.zig.zon.
        #!    zigBuildZonLock: Path to build.zig.zon2json-lock file, defaults to build.zig.zon2json-lock.
        #!
        #! <https://github.com/NixOS/nixpkgs/blob/master/doc/hooks/zig.section.md>
        package = with pkgs; attrs: let
          target = attrs.zigTarget or env.lib.nixTargetToZigTarget (env.lib.elaborate pkgs.stdenvNoCC.targetPlatform).parsed;
          mach-binaries = fromJSON (readFile ./mach-binaries.json);
          dawn-version = mach-binaries."dawn-${target}".ver;
          dawn-binary = fetchurl {
            url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${dawn-version}/libdawn_${target}_release-fast.a.gz";
            hash = mach-binaries."dawn-${target}".lib;
          };
          dawn-headers = fetchurl {
            url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${dawn-version}/headers.json.gz";
            hash = mach-binaries."dawn-${target}".hdr;
          };
        in env.package (attrs // {
          # https://github.com/hexops/mach-core/blob/main/build_examples.zig
          NO_ENSURE_SUBMODULES = "true";
          NO_ENSURE_GIT = "true";
          # https://github.com/hexops/mach-gpu-dawn/blob/main/build.zig
          postPatch = ''
            mkdir -p zig-cache/mach/gpu-dawn/${dawn-version}/${target}/release-fast
            (
              cd zig-cache/mach/gpu-dawn/${dawn-version}
              ${pkgs.gzip}/bin/gzip -d -c ${dawn-binary} > ${target}/release-fast/libdawn.a
              ${pkgs.gzip}/bin/gzip -d -c ${dawn-headers} > ${target}/release-fast/headers.json
              while read -r key; do
                mkdir -p "$(dirname "$key")"
                path="$(realpath $key)"
                ${pkgs.jq}/bin/jq -r --arg k "$key" '."\($k)"' ${target}/release-fast/headers.json > "$path"
              done < <(${pkgs.jq}/bin/jq -r 'to_entries | .[] | .key' ${target}/release-fast/headers.json)
            )
            '' + lib.optionalString (attrs ? postPatch) attrs.postPatch;
        });

        # TODO: utility for updating mach deps in build.zig.zon
        #       useful if downstream does `flake update`
      });

      # Default mach env used by this flake
      env = mach-env {};
      app = env.app-bare;
    in rec {
      #! --- Architecture dependent flake outputs.
      #!     access: `mach.outputs.thing.${system}`

      #! Helper function for building and running Mach projects.
      inherit mach-env;

      #! Expose mach nominated zig versions and extra packages.
      #! <https://machengine.org/about/nominated-zig/>
      packages = {
        inherit (zig2nix.outputs.packages.${system}) zon2json zon2json-lock zon2nix;
        zig = zigv;
      } // env.extraPkgs;

      #! Run a Mach nominated version of a Zig compiler inside a `mach-env`.
      #! nix run#zig."mach-nominated-version"
      #! example: nix run#zig.mach-latest
      apps.zig = mapAttrs (k: v: (mach-env {zig = v;}).app-no-root [] ''zig "$@"'') zigv;

      #! Run a latest Mach nominated version of a Zig compiler inside a `mach-env`.
      #! nix run
      apps.default = apps.zig.mach-latest;

      #! zon2json: Converts zon files to json
      apps.zon2json = zig2nix.outputs.apps.${system}.zon2json;

      #! zon2json-lock: Converts build.zig.zon to a build.zig.zon2json lock file
      apps.zon2json-lock = zig2nix.outputs.apps.${system}.zon2json-lock;

      #! zon2nix: Converts build.zig.zon and build.zig.zon2json-lock to nix deriviation
      apps.zon2nix = zig2nix.outputs.apps.${system}.zon2nix;

      #! Develop shell for building and running Mach projects.
      #! nix develop#zig."mach-nominated-version"
      #! example: nix develop#zig.mach-latest
      devShells.zig = mapAttrs (k: v: (mach-env {zig = v;}).shell) zigv;

      #! Develop shell for building and running Mach projects.
      #! Uses `mach-latest` nominated Zig version.
      #! nix develop
      devShells.default = devShells.zig.mach-latest;

      # nix run .#update-versions
      apps.update-versions = with env.pkgs; app [ curl jq ] ''
        curl https://machengine.org/zig/index.json | jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))'
        '';

      # nix run .#update-templates
      apps.update-templates = with env.pkgs; app [ coreutils gnused git env.zig jq packages.zon2json ] ''
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

        read -r rev _ < <(git ls-remote https://github.com/hexops/mach.git HEAD)
        old_url="$(zon2json templates/engine/build.zig.zon | jq '.dependencies.mach.url')"
        if [[ "$old_url" != "https://pkg.machengine.org/mach/$rev.tar.gz" ]]; then
          generate mach-engine-project mach "$rev" > templates/engine/build.zig.zon
        fi

        sed "s/SED_REPLACE_REV/$flake_rev/" templates/flake.nix > templates/engine/flake.nix
        (cd templates/engine; nix run --override-input mach ../.. .#zon2json-lock)

        read -r rev _ < <(git ls-remote https://github.com/hexops/mach-core.git HEAD)
        old_url="$(zon2json templates/core/build.zig.zon | jq '.dependencies."mach_core".url')"
        if [[ "$old_url" != "https://pkg.machengine.org/mach-core/$rev.tar.gz" ]]; then
          cp templates/core/build.zig.zon2json-lock "$tmpdir/core-lock"
          rm -rf templates/core
          git clone https://github.com/hexops/mach-core-starter-project.git templates/core
          rm -rf templates/core/.git
          generate mach-core-project mach-core "$rev" > templates/core/build.zig.zon
          mv "$tmpdir/core-lock" templates/core/build.zig.zon2json-lock
          git add templates/core/build.zig.zon2json-lock
        fi

        sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
        sed -i "s/SED_REPLACE_REV/$flake_rev/" templates/core/flake.nix
        (cd templates/core; nix run --override-input mach ../.. .#zon2json-lock)
        '';

      # nix run .#update-mach-binaries
      apps.update-mach-binaries = with env.pkgs; app [ coreutils gnused gnugrep jq ] ''
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT

        extract_dawn_versions() {
          while read -r dawn_rev; do
            curl -sL "https://raw.githubusercontent.com/hexops/mach-gpu-dawn/$dawn_rev/build.zig" |\
              grep -o 'binary_version:.*"' | sed 's/.*=[ ]*"\([a-z0-9-]*\)"/\1/'
          done
        }

        generate_json() {
          extract_dawn_versions | sort -u | while read -r ver; do
            curl -sL "https://github.com/hexops/mach-gpu-dawn/releases/download/$ver/headers.json.gz" -o "$tmpdir/dawn-headers.gz"
            for triple in aarch64-linux-musl x86_64-linux-musl aarch64-linux-gnu x86_64-linux-gnu aarch64-macos-none x86_64-macos-none; do
              curl -sL "https://github.com/hexops/mach-gpu-dawn/releases/download/$ver/libdawn_''${triple}_release-fast.a.gz" -o "$tmpdir/dawn-lib.gz"
              cat <<EOF
        {
          "dawn-$triple": {
            "ver": "$ver",
            "lib": "$(nix hash file "$tmpdir/dawn-lib.gz")",
            "hdr": "$(nix hash file "$tmpdir/dawn-headers.gz")"
          }
        }
        EOF
            done
          done | jq -s add
        }

        generate_json < <(
          jq -r '.[] | select(.name == "mach_gpu_dawn") | .url' templates/*/build.zig.zon2json-lock |\
          sed 's,.*/\([a-z0-9]*\).*,\1,' | sort -u)
        '';

      # nix run .#test
      apps.test = app [] ''
        (cd templates/engine; nix run --override-input mach ../.. .#test)
        (cd templates/engine; nix run --override-input mach ../.. .#zon2json)
        (cd templates/engine; nix build --override-input mach ../.. .)
        rm -f templates/engine/result
        rm -rf templates/engine/zig-out
        rm -rf templates/engine/zig-cache
        (cd templates/core; nix run --override-input mach ../.. .#test)
        (cd templates/core; nix run --override-input mach ../.. .#zon2json)
        (cd templates/core; nix build --override-input mach ../.. .)
        rm -f templates/core/result
        rm -rf templates/core/zig-out
        rm -rf templates/core/zig-cache
        '';

      # nix run .#readme
      apps.readme = let
        project = "Mach Engine Flake";
      in with env.pkgs; app [ gawk packages.zon2json jq ] (replaceStrings ["`"] ["\\`"] ''
      cat <<EOF
      # ${project}

      Flake that allows you to get started with Mach engine quickly.

      https://machengine.org/

      ---

      [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

      * Mach Zig: `${env.zig.version} @ ${env.zig.machNominated}`
      * Mach Engine: `$(zon2json templates/engine/build.zig.zon | jq -r '.dependencies | .mach.url')`
      * Mach Core: `$(zon2json templates/core/build.zig.zon | jq -r '.dependencies | .mach_core.url')`

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

      ## Shell for building and running a Mach project

      ```bash
      nix develop github:Cloudef/mach-flake
      ```

      ## Crude documentation

      Below is auto-generated dump of important outputs in this flake.

      ```nix
      $(awk -f doc.awk flake.nix | sed "s/```/---/g")
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
      #! --- Generic flake outputs.
      #!     access: `mach.outputs.thing`

      #: Mach engine project template
      #: nix flake init -t templates#engine
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

      #: Mach core project template
      #: nix flake init -t templates#core
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
