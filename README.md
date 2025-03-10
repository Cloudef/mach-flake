# Mach Engine Flake

Flake that allows you to get started with Mach engine quickly.

https://machengine.org/

* Cachix: `cachix use mach-flake`

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

* Mach Zig: `0.14.0-dev.2577+271452d22 @ 2024-12-30`
* Mach Engine: `aae6ab3afa8b9ff6ec9055209e6356004462b41f`

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
#! Structures.

#:! Helper function for building and running Mach projects.
#:! For more options see zig-env from <https://github.com/Cloudef/zig2nix>
mach-env = {
 # Zig version to use. Normally there is no need to change this.
 zig ? zigv.latest,
 ...
}: { ... };

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

#! --- Outputs of mach-env {} function.
#!     access: (mach-env {}).thing

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

#! --- Architecture dependent flake outputs.
#!     access: `mach.outputs.thing.${system}`

#! Helper function for building and running Mach projects.
inherit mach-env;

#! Expose mach nominated zig versions and extra packages.
#! <https://machengine.org/about/nominated-zig/>
packages = (mapAttrs' (k: v: nameValuePair ("zig-mach-" + k) v) zigv) // test-env.extraPkgs;

#! Develop shell for building and running Mach projects.
#! nix develop .#zig_version
#! example: nix develop .#latest
#! example: nix develop .#2024_11_0
devShells = flake-outputs.devShells // {
 default = flake-outputs.devShells.latest;
};

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
```
