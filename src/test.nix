{
  lib
  , test-app
  , mach-binary-triples
  , file
}:

with builtins;
with lib;

let
  # These targets are ignored for now as there is zig bug when cross-compiling
  # https://github.com/ziglang/zig/issues/18571
  ignored = [ "aarch64-macos-none" "x86_64-macos-none" "x86_64-linux-musl" "aarch64-linux-musl" ];
  working-triples = subtractLists ignored mach-binary-triples;
in {
  # nix run .#test.all
  all = test-app [ file ] ''
    for var in engine core; do
      printf -- 'run .#test (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#test)
      printf -- 'run .#zon2json (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#zon2json; printf '\n')
      printf -- 'run .#updateMachDeps (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#updateMachDeps; printf '\n')
      printf -- 'build . (%s)\n' "$var"
      (cd templates/"$var"; nix build --override-input mach ../.. .)
      if [[ "$var" == engine ]]; then
        for triple in ${escapeShellArgs working-triples}; do
          printf -- 'build .#target.%s (%s)\n' "$triple" "$var"
          (cd templates/"$var"; nix build --override-input mach ../.. .#target."$triple"; file result/bin/myapp*)
        done
      fi
      rm -f templates/"$var"/result
      rm -rf templates/"$var"/zig-out
      rm -rf templates/"$var"/zig-cache
    done
    '';

  # nix run .#test.repl
  repl = test-app [] ''
    confnix="$(mktemp)"
    trap 'rm $confnix' EXIT
    echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >"$confnix"
    nix repl "$confnix"
    '';
}
