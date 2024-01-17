{
  lib
  , app
  , mach-binary-doubles
  , file
}:

with builtins;
with lib;

{
  # nix run .#test.all
  all = app [ file ] ''
    for var in engine core; do
      printf -- 'run .#test (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#test)
      printf -- 'run .#zon2json (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#zon2json; printf '\n')
      printf -- 'run .#update-mach-deps (%s)\n' "$var"
      (cd templates/"$var"; nix run --override-input mach ../.. .#update-mach-deps; printf '\n')
      printf -- 'build . (%s)\n' "$var"
      (cd templates/"$var"; nix build --override-input mach ../.. .)
      if [[ "$var" == engine ]]; then
        for double in ${concatStringsSep " " mach-binary-doubles}; do
          printf -- 'build .#target.%s (%s)\n' "$double" "$var"
          (cd templates/"$var"; nix build --override-input mach ../.. .#target."$double"; file result/bin/myapp*)
        done
      fi
      rm -f templates/"$var"/result
      rm -rf templates/"$var"/zig-out
      rm -rf templates/"$var"/zig-cache
    done
    '';

  # nix run .#test.repl
  repl = app [] ''
    confnix="$(mktemp)"
    trap 'rm $confnix' EXIT
    echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >"$confnix"
    nix repl "$confnix"
    '';
}
