{
  lib
  , test-app
  , zig-env
  , buildPlatform
}:

with builtins;
with lib;

{
  # nix run .#test-package
  package = let
    # These targets are ignored for now as they don't compile
    blacklist =
      [
        "armv6l-linux" "armv7l-linux" "x86_64-freebsd" "riscv64-linux" "powerpc64le-linux" "i686-linux"
        # (zig std) disabled due to miscompilations
        "aarch64-linux"
      ]
      ++ optionals (!buildPlatform.isDarwin) [ "aarch64-darwin" ];
    targets = subtractLists blacklist systems.flakeExposed;
  in test-app [] (concatStrings (map (nix: let
    engine = zig-env.package {
      zigTarget = (zig-env.target nix).zig;
      src = cleanSource ../templates/engine;
      zigBuildFlags = [ "-Doptimize=ReleaseSmall" ];
    };
    core = zig-env.package {
      zigTarget = (zig-env.target nix).zig;
      src = cleanSource ../templates/core;
      zigBuildFlags = [ "-Doptimize=ReleaseSmall" ];
    };
  in ''
    echo "engine (${nix}): ${engine}"
    echo "core (${nix}): ${core}"
  '') targets));

  # nix run .#test-templates
  templates = test-app [] ''
    for var in engine core; do
      nix flake check --keep-going
      printf -- 'run .#zig2nix (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#zig2nix -- help; printf '\n')
      printf -- 'run .#updateMachDeps (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#updateMachDeps; printf '\n')
      printf -- 'run .#test (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#test)
      printf -- 'build . (%s)\n' "$var"
      (cd templates/"$var"; nix build -L --override-input mach ../.. .)
      rm -f templates/"$var"/result
      rm -rf templates/"$var"/zig-out
      rm -rf templates/"$var"/zig-cache
    done
    '';

  # nix run .#test-all
  all = test-app [] ''
    nix flake check --keep-going
    nix run -L .#test-templates
    nix run -L .#test-package
    '';
}
