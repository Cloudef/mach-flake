{
  description = "mach engine flake";
  inputs.zig2nix.url = "github:Cloudef/zig2nix";

  outputs = { zig2nix, ... }: with builtins; let
    flake-utils = zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      #! Structures.

      zig-env = zig2nix.zig-env.${system};
      pkgs = (zig-env {}).pkgs;

      # Mach nominated Zig versions.
      # <https://machengine.org/about/nominated-zig/>
      zigv = pkgs.callPackage ./versions.nix {
        zigSystem = (zig-env {}).lib.zigDoubleFromString system;
        zigHook = (zig-env {}).zig-hook;
      };

      #: Helper function for building and running Mach projects.
      #: For more options see zig-env from <https://github.com/Cloudef/zig2nix>
      mach-env = {
        # Zig version to use. Normally there is no need to change this.
        zig ? zigv.mach-latest,
        # Enable Vulkan support.
        enableVulkan ? true,
        # Enable OpenGL support.
        enableOpenGL ? true,
        # Enable Wayland support.
        # Disabled by default because mach-core example currently panics with:
        # error(mach): glfw: error.FeatureUnavailable: Wayland: The platform does not provide the window position
        enableWayland ? false,
        # Enable X11 support.
        enableX11 ? true,
        ...
      } @attrs: let
        env = pkgs.callPackage zig-env (attrs // {
          inherit zig enableVulkan enableOpenGL enableWayland enableX11;
        });
      in (env // {
        #! --- Outputs of mach-env {} function.
        #!     access: (mach-env {}).thing

        #! Autofix tool
        #! https://github.com/ziglang/zig/issues/17584
        autofix = pkgs.writeShellApplication {
          name = "zig-autofix";
          runtimeInputs = with pkgs; [ zig gnused gnugrep ];
          text = ''
            if [[ ! -d "$1" ]]; then
              printf 'error: no such directory: %s\n' "$@"
              exit 1
            fi

            cd "$@"
            has_wontfix=0

            while {
                IFS=$':' read -r file line col msg;
            } do
              if [[ "$msg" ]]; then
                case "$msg" in
                  *"local variable is never mutated")
                    printf 'autofix: %s\n' "$file:$line:$col:$msg" 1>&2
                    sed -i "''${line}s/var/const/" "$file"
                    ;;
                  *)
                    printf 'wontfix: %s\n' "$file:$line:$col:$msg" 1>&2
                    has_wontfix=1
                    ;;
                esac
              fi
            done < <(zig build 2>&1 | grep "error:")

            exit $has_wontfix
            '';
        };

        #! QOI - The “Quite OK Image Format” for fast, lossless image compression
        #! Packages the `qoiconv` binary.
        #! <https://github.com/phoboslab/qoi/tree/master>
        extraPkgs.qoi = pkgs.callPackage ./packages/qoi.nix {};

        #: Package for specific target supported by nix.
        #: You can still compile to other platforms by using package and specifying zigTarget.
        #: When compiling to non-nix supported targets, you can't rely on pkgsForTarget, but rather have to provide all the pkgs yourself.
        #: NOTE: Even though target is supported by nix, cross-compiling to it might not be, in that case you should get an error.
        packageForTarget = target: (env.pkgsForTarget target).callPackage (pkgs.callPackage ./package.nix { inherit env target; });

        #! Packages mach project.
        #! NOTE: You must first generate build.zig.zon2json-lock using zon2json-lock.
        #!       It is recommended to commit the build.zig.zon2json-lock to your repo.
        #!
        #! Additional attributes:
        #!    zigTarget: Specify target for zig compiler, defaults to nix host.
        #!    zigInheritStdenv:
        #!       By default if zigTarget is specified, nixpkgs stdenv compatible environment is not used.
        #!       Set this to true, if you want to specify zigTarget, but still use the derived stdenv compatible environment.
        #!    zigPreferMusl: Prefer musl libc without specifying the target.
        #!    zigDisableWrap: makeWrapper will not be used. Might be useful if distributing outside nix.
        #!    zigWrapperArgs: Additional arguments to makeWrapper.
        #!    zigBuildZon: Path to build.zig.zon file, defaults to build.zig.zon.
        #!    zigBuildZonLock: Path to build.zig.zon2json-lock file, defaults to build.zig.zon2json-lock.
        #!
        #! <https://github.com/NixOS/nixpkgs/blob/master/doc/hooks/zig.section.md>
        package = packageForTarget system;

        #! Update Mach deps in build.zig.zon
        #! Handly helper if you decide to update mach-flake
        #! This does not update your build.zig.zon2json-lock file
        update-mach-deps = let
          mach = (env.lib.readBuildZigZon ./templates/engine/build.zig.zon).dependencies.mach;
          core = (env.lib.readBuildZigZon ./templates/core/build.zig.zon).dependencies.mach_core;
        in with pkgs; env.app [ gnused jq zig2nix.outputs.packages.${system}.zon2json ] ''
          replace() {
            while {
              read -r url;
              read -r hash;
            } do
              sed -i -e "s;$url;$2;" -e "s;$hash;$3;" build.zig.zon
            done < <(zon2json build.zig.zon | jq -r ".dependencies.\"$1\" | .url, .hash")
          }
          replace mach "${mach.url}" "${mach.hash}"
          replace mach_core "${core.url}" "${core.hash}"
          '';
      });

      # Default mach env used by this flake
      env = mach-env {};
      app = env.app-bare;

      mach-binary-triples = [
        "aarch64-linux-musl" "x86_64-linux-musl"
        "aarch64-linux-gnu" "x86_64-linux-gnu"
        "aarch64-macos-none" "x86_64-macos-none"
        "x86_64-windows-gnu"
      ];

      # nix compatible doubles, macos becomes darwin and so on
      mach-binary-doubles = with env.lib; with env.pkgs.lib; let
        # Currently cross-compiling to these is broken
        # https://github.com/ziglang/zig/issues/18571
        filtered = [ "aarch64-darwin" "x86_64-darwin" ];
      in subtractLists filtered (unique (map
        (t: systems.parse.doubleFromSystem (mkZigSystemFromString t)) mach-binary-triples));
    in rec {
      #! --- Architecture dependent flake outputs.
      #!     access: `mach.outputs.thing.${system}`

      #! Helper function for building and running Mach projects.
      inherit mach-env;

      #! Expose mach nominated zig versions and extra packages.
      #! <https://machengine.org/about/nominated-zig/>
      packages = {
        inherit (zig2nix.outputs.packages.${system}) zon2json zon2json-lock zon2nix;
        inherit (env) autofix;
        zig = zigv;
      } // env.extraPkgs;

      #! Run a Mach nominated version of a Zig compiler inside a `mach-env`.
      #! nix run#zig."mach-nominated-version"
      #! example: nix run#zig.mach-latest
      apps.zig = mapAttrs (k: v: (mach-env {zig = v;}).app-no-root [] ''zig "$@"'') zigv;

      #! Run a latest Mach nominated version of a Zig compiler inside a `mach-env`.
      #! nix run
      apps.default = apps.zig.mach-latest;

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
        curl -sSL https://machengine.org/zig/index.json | jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))'
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

        mach_update=0

        read -r rev _ < <(git ls-remote https://github.com/hexops/mach.git HEAD)
        old_url="$(zon2json templates/engine/build.zig.zon | jq -er '.dependencies.mach.url')"
        if [[ "$old_url" != "https://pkg.machengine.org/mach/$rev.tar.gz" ]]; then
          generate mach-engine-project mach "$rev" > templates/engine/build.zig.zon
          mach_update=1
        fi

        read -r rev _ < <(git ls-remote https://github.com/hexops/mach-core.git HEAD)
        old_url="$(zon2json templates/core/build.zig.zon | jq -er '.dependencies.mach_core.url')"
        if [[ "$old_url" != "https://pkg.machengine.org/mach-core/$rev.tar.gz" ]]; then
          cp templates/core/build.zig.zon2json-lock "$tmpdir/core-lock"
          rm -rf templates/core
          git clone https://github.com/hexops/mach-core-starter-project.git templates/core
          rm -rf templates/core/.git
          generate mach-core-project mach-core "$rev" > templates/core/build.zig.zon
          mv "$tmpdir/core-lock" templates/core/build.zig.zon2json-lock
          git add templates/core/build.zig.zon2json-lock
          mach_update=1
        fi

        if [[ $mach_update == 0 ]]; then
          echo "Templates are up-to-date"
          exit 0
        fi

        nix run .#update-versions > versions.json
        nix run .#update-templates-flake -- force
        for var in engine core; do
          (cd templates/"$var"; nix run --override-input mach ../.. .#zon2json-lock)
          # Call using nix run because update-versions may change the mach nominated zig version
          nix run .#autofix -- templates/"$var"
        done

        nix run .#update-mach-binaries > mach-binaries.json
        nix run .#readme > README.md
        '';

      # nix run .#update-templates-flake
      apps.update-templates-flake = with env.pkgs; app [ git gnused ] ''
        if [[ "''${1-}" != "force" ]] && [[ "$(git log --format=%B -n 1 HEAD)" == "Update templates rev" ]]; then
          echo "Template revisions are up-to-date"
          exit 0
        fi
        flake_rev="$(git rev-parse HEAD)"
        sed "s/SED_REPLACE_REV/$flake_rev/" templates/flake.nix > templates/engine/flake.nix
        sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
        sed -i "s/SED_REPLACE_REV/$flake_rev/" templates/core/flake.nix
        '';

      # nix run .#update-mach-binaries
      apps.update-mach-binaries = with env.pkgs; let
        base-url = "https://github.com/hexops/mach-gpu-dawn/releases/download";
      in app [ coreutils gnused gnugrep jq ] ''
        tmpdir="$(mktemp -d)"
        trap 'rm -rf "$tmpdir"' EXIT

        extract_dawn_versions() {
          while read -r dawn_rev; do
            curl -sSL "https://raw.githubusercontent.com/hexops/mach-gpu-dawn/$dawn_rev/build.zig" |\
              grep -o 'binary_version:.*"' | sed 's/.*=[ ]*"\([a-z0-9-]*\)"/\1/'
          done
        }

        generate_json() {
          extract_dawn_versions | sort -u | while read -r ver; do
            curl -sSL "${base-url}/$ver/headers.json.gz" -o "$tmpdir/dawn-headers.gz"
            for triple in ${lib.concatStringsSep " " mach-binary-triples}; do
              if [[ "$triple" == *-windows-* ]]; then
                curl -sSL "${base-url}/$ver/dawn_''${triple}_release-fast.lib.gz" -o "$tmpdir/dawn-lib.gz"
              else
                curl -sSL "${base-url}/$ver/libdawn_''${triple}_release-fast.a.gz" -o "$tmpdir/dawn-lib.gz"
              fi
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
          done | jq -es add
        }

        generate_json < <(
          jq -er '.[] | select(.name == "mach_gpu_dawn") | .url' templates/*/build.zig.zon2json-lock |\
          sed 's,.*/\([0-9a-f]*\).*,\1,' | sort -u)
        '';

      # nix run .#test
      apps.test = with env.pkgs; app [ file ] ''
        for var in engine core; do
          printf -- 'run .#test (%s)\n' "$var"
          (cd templates/"$var"; nix run --override-input mach ../.. .#test)
          printf -- 'run .#zon2json (%s)\n' "$var"
          (cd templates/"$var"; nix run --override-input mach ../.. .#zon2json; printf '\n')
          printf -- 'build . (%s)\n' "$var"
          (cd templates/"$var"; nix build --override-input mach ../.. .)
          if [[ "$var" == engine ]]; then
            for double in ${lib.concatStringsSep " " mach-binary-doubles}; do
              printf -- 'build .#target.%s (%s)\n' "$double" "$var"
              (cd templates/"$var"; nix build --override-input mach ../.. .#target."$double"; file result/bin/myapp*)
            done
          fi
          rm -f templates/"$var"/result
          rm -rf templates/"$var"/zig-out
          rm -rf templates/"$var"/zig-cache
        done
        '';

      # nix run .#readme
      apps.readme = let
        project = "Mach Engine Flake";
      in with env.pkgs; app [ gawk gnused packages.zon2json jq ] (replaceStrings ["`"] ["\\`"] ''
      zonrev() {
        zon2json templates/"$1"/build.zig.zon | jq -e --arg k "$2" -r '.dependencies."\($k)".url' |\
          sed 's,^.*/\([0-9a-f]*\).*,\1,'
      }
      cat <<EOF
      # ${project}

      Flake that allows you to get started with Mach engine quickly.

      https://machengine.org/

      ---

      [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

      * Mach Zig: `${env.zig.version} @ ${env.zig.machNominated}`
      * Mach Engine: `$(zonrev engine mach)`
      * Mach Core: `$(zonrev core mach_core)`

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
