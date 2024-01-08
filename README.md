# Mach Engine Flake

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
