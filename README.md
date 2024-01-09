# Mach Engine Flake

Flake that allows you to get started with Mach engine quickly.

https://machengine.org/

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

* Mach Zig: `0.12.0-dev.1092+68ed78775 @ not-offically-nominated`
* Mach Engine: `6a76564ae76f56700619195e35b2832982e10ece`
* Mach Core: `90c927e20d045035152d9b0b421ea45db7e5569c`

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
