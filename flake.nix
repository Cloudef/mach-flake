{
  description = "mach engine flake";
  inputs.zig2nix.url = "github:Cloudef/zig2nix";

  outputs = { zig2nix, ... }: with builtins; let
    flake-utils = zig2nix.inputs.flake-utils;
    outputs = (flake-utils.lib.eachDefaultSystem (system: let
      #! Structures.

      bootstrapZigEnv = let
        zig-env = zig2nix.zig-env.${system};
      in (zig-env {}).pkgs.callPackage zig-env;

      # Mach nominated Zig versions.
      # <https://machengine.org/about/nominated-zig/>
      zigv = let
        zig-env = zig2nix.zig-env.${system};
        callPackage = (zig-env {}).pkgs.callPackage;
      in import ./src/versions.nix {
        inherit (zig-env {}) zigHook;
        zigBin = callPackage "${zig2nix}/src/zig/bin.nix";
        zigSrc = callPackage "${zig2nix}/src/zig/src.nix";
      };

      autofix-for-zig = zig: pkgs.writeShellApplication {
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

      #:! Helper function for building and running Mach projects.
      #:! For more options see zig-env from <https://github.com/Cloudef/zig2nix>
      mach-env = {
        # Zig version to use. Normally there is no need to change this.
        zig ? zigv.latest,
        ...
      } @attrs: let
        env = bootstrapZigEnv (attrs // { inherit zig; });

        #! mach nativeBuildInputs for a target
        machNativeBuildInputs = [];

        #! mach buildInputs for a target
        machBuildInputsForTarget = target: [];

        #! mach zigWrapperLibs for a target
        machWrapperLibsForTarget = target: with env.binaryPkgsForTarget target; []
        ++ env.pkgs.lib.optionals ((env.target target).os == "linux")  [
          vulkan-loader libGL
          xorg.libX11 xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrender
          xorg.libXrandr xorg.libXinerama xorg.libXcursor xorg.xorgproto
          wayland-scanner wayland libxkbcommon libdecor
          alsa-lib pulseaudio
        ];

        #! All mach dependencies required for building, linking and running
        machDeps = machNativeBuildInputs
          ++ (machBuildInputsForTarget system)
          ++ (machWrapperLibsForTarget system);

        # Package a mach project
        machPackage = env.pkgs.callPackage (env.pkgs.callPackage ./src/package.nix {
          inherit (env) target;
          inherit machNativeBuildInputs machBuildInputsForTarget machWrapperLibsForTarget;
          zigPackage = env.package;
        });
      in (env // {
        #! --- Outputs of mach-env {} function.
        #!     access: (mach-env {}).thing

        inherit machNativeBuildInputs machBuildInputsForTarget machWrapperLibsForTarget machDeps;

        #! Flake app helper (without root dir restriction).
        app-no-root = deps: script: env.app-no-root (deps ++ machDeps) script;

        #! Flake app helper.
        app = deps: script: env.app (deps ++ machDeps) script;

        #! Creates dev shell.
        mkShell = {
          nativeBuildInputs ? [],
          ...
        } @attrs: env.mkShell (attrs // {
          nativeBuildInputs = nativeBuildInputs ++ machDeps;
        });

        #! Packages mach project.
        #! For more information see the flake at <https://github.com/Cloudef/zig2nix>
        package = machPackage;

        #! Update Mach deps in build.zig.zon
        #! Handy helper if you decide to update mach-flake
        #! This does not update your build.zig.zon2json-lock file
        updateMachDeps = let
          mach = (env.fromZON ./templates/engine/build.zig.zon).dependencies.mach;
        in with pkgs; env.app [ gnused jq env.zig2nix ] ''
          replace() {
            while {
              read -r url;
              read -r hash;
            } do
              sed -i -e "s;$url;$2;" -e "s;$hash;$3;" build.zig.zon
            done < <(zig2nix zon2json build.zig.zon | jq -r ".dependencies.\"$1\" | .url, .hash")
          }
          replace mach "${mach.url}" "${mach.hash}"
          '';

        #! QOI - The “Quite OK Image Format” for fast, lossless image compression
        #! Packages the `qoiconv` binary.
        #! <https://github.com/phoboslab/qoi/tree/master>
        extraPkgs.qoi = env.pkgs.callPackage ./packages/qoi.nix {};

        #! Autofix tool
        #! https://github.com/ziglang/zig/issues/17584
        extraPkgs.autofix = autofix-for-zig zig;
      });

      # Default mach env used for tests and automation
      test-env = mach-env {};
      test-app = test-env.app-bare;
      pkgs = test-env.pkgs;

      test = removeAttrs (pkgs.callPackage src/test.nix {
        inherit test-app;
        zig-env = test-env;
      }) [ "override" "overrideDerivation" "overrideAttrs" ];

      mach = removeAttrs (pkgs.callPackage src/mach.nix {
        inherit test-app;
        inherit (test-env) zig zig2nix;
      }) [ "override" "overrideDerivation" "overrideAttrs" ];

      flake-outputs = pkgs.callPackage (import ./src/outputs.nix) {
        inherit zigv mach-env;
      };
    in with pkgs.lib; {
      #! --- Architecture dependent flake outputs.
      #!     access: `mach.outputs.thing.${system}`

      #! Helper function for building and running Mach projects.
      inherit mach-env;

      #! Expose mach nominated zig versions and extra packages.
      #! <https://machengine.org/about/nominated-zig/>
      packages = (mapAttrs' (k: v: nameValuePair ("zig-mach-" + k) v) zigv) // test-env.extraPkgs;

      # Generates flake apps for all the zig versions.
      apps = flake-outputs.apps // {
        default = flake-outputs.apps.latest;

        # Backwards compatibility
        zon2json = flake-outputs.apps.zon2json-latest;
        zon2json-lock = flake-outputs.apps.zon2json-lock-latest;
        zon2nix = flake-outputs.apps.zon2nix-latest;

        # nix run .#update-versions
        update-versions = test-app [ pkgs.jq test-env.zig2nix ] ''
          tmp="$(mktemp)"
          trap 'rm -f "$tmp"' EXIT
          curl -sSL https://machengine.org/zig/index.json |\
            jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))' |\
            sed 's/mach-//;s/-mach//' |\
            zig2nix versions - > "$tmp"
          cp -f "$tmp" src/versions.nix
        '';

        # nix run .#readme
        readme = let
          project = "Mach Engine Flake";
        in with pkgs; test-app [ gawk gnused test-env.zig2nix jq ] (replaceStrings ["`"] ["\\`"] ''
        zonrev() {
          zig2nix zon2json templates/"$1"/build.zig.zon | jq -e --arg k "$2" -r '.dependencies."\($k)".url' |\
            sed 's,^.*/\([0-9a-f]*\).*,\1,'
        }
        cat <<EOF
        # ${project}

        Flake that allows you to get started with Mach engine quickly.

        https://machengine.org/

        * Cachix: `cachix use mach-flake`

        ---

        [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

        * Mach Zig: `${zigv.latest.info.zigVersion} @ ${zigv.latest.info.machNominated}`
        * Mach Engine: `$(zonrev engine mach)`

        ### Mach Engine

        ```bash
        nix flake init -t github:Cloudef/mach-flake#engine
        nix run .
        # for more options check the flake.nix file
        ```

        ### Mach Core

        ```bash
        nix flake init -t github:Cloudef/mach-flake#core
        nix run .
        # for more options check the flake.nix file
        ```

        ### Using Mach nominated Zig directly

        ```bash
        nix run github:Cloudef/mach-flake -- version
        nix run github:Cloudef/mach-flake#2024_11_0 -- version
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
      } // (mapAttrs' (name: value: nameValuePair ("test-" + name) value) test)
        // (mapAttrs' (name: value: nameValuePair ("mach-" + name) value) mach);

      #! Develop shell for building and running Mach projects.
      #! nix develop .#zig_version
      #! example: nix develop .#latest
      #! example: nix develop .#2024_11_0
      devShells = flake-outputs.devShells // {
        default = flake-outputs.devShells.latest;
      };
    }));

    welcome-template = description: prelude: ''
      # ${description}
      ${prelude}

      ## Build & Run

      ```
      nix run .
      ```

      See flake.nix for more options.
      '';
  in outputs // rec {
    #! --- Generic flake outputs.
    #!     access: `mach.outputs.thing`

    #! Mach engine project template
    #! nix flake init -t templates#engine
    templates.engine = rec {
      path = ./templates/engine;
      description = "Mach engine project";
      welcomeText = welcome-template description ''
        - Mach engine: https://machengine.org/engine/
        '';
    };

    #! Mach core project template
    #! nix flake init -t templates#core
    templates.core = rec {
      path = ./templates/core;
      description = "Mach core project";
      welcomeText = welcome-template description ''
        - Mach core: https://machengine.org/core/
        '';
    };

    # nix flake init -t templates
    templates.default = templates.engine;
  };
}
