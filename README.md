# Mach Engine Flake

Flake that allows you to get started with Mach engine quickly.

https://machengine.org/

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

* Mach Zig: `0.12.0-dev.1092+68ed78775 @ not-offically-nominated`
* Mach Engine: `https://pkg.machengine.org/mach/3b180a58d55a8af3b8e3f6d87c9ff6f8d082c62c.tar.gz`
* Mach Core: `https://pkg.machengine.org/mach-core/90c927e20d045035152d9b0b421ea45db7e5569c.tar.gz`

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
#! Structures.

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
}: {};

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

#! --- Architecture dependent flake outputs.
#!     access: `mach.outputs.thing.${system}`

#! Helper function for building and running Mach projects.
inherit mach-env;

#! Expose mach nominated zig versions and extra packages.
#! <https://machengine.org/about/nominated-zig/>
packages = {

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
  
  ---
  nix run .
  ---
  
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
  
  ---
  nix run .
  ---
  
  See flake.nix for more options.
  '';
};
```
