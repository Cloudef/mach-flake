{
  test-app
  , zig2nix
  , jq
  , coreutils
  , gnused
  , git
  , zig
}:

{
  # nix run .#mach-update-flakes
  update-flakes = test-app [ git gnused ] ''
    if [[ "''${1-}" != "force" ]] && [[ "$(git log --format=%B -n 1 HEAD)" == "Update templates rev" ]]; then
      echo "Template revisions are up-to-date"
      exit 0
    fi
    flake_rev="$(git rev-parse HEAD)"
    sed "s#@SED_REPLACE_REV@#$flake_rev#" templates/flake.nix > templates/engine/flake.nix
    sed -i "s#@SED_ZIG_BIN@#mach-app#" templates/engine/flake.nix
    sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
    sed -i "s#@SED_REPLACE_REV@#$flake_rev#" templates/core/flake.nix
    sed -i "s#@SED_ZIG_BIN@#mach-core-app#" templates/core/flake.nix
    '';

  # nix run .#mach-update
  update = test-app [ coreutils gnused git zig jq zig2nix ] ''
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
    old_url="$(zig2nix zon2json templates/engine/build.zig.zon | jq -er '.dependencies.mach.url')"
    if [[ "$old_url" != "https://pkg.machengine.org/mach/$rev.tar.gz" ]]; then
      git clone https://github.com/hexops/mach.git "$tmpdir"/mach

      rm -rf templates/engine/src
      cp -rf "$tmpdir"/mach/examples/custom-renderer templates/engine/src
      git add templates/engine/src
      generate mach-engine-project mach "$rev" > templates/engine/build.zig.zon

      rm -rf templates/core/src
      cp -rf "$tmpdir"/mach/examples/core-triangle templates/core/src
      git add templates/core/src
      generate mach-core-project mach "$rev" > templates/core/build.zig.zon

      mach_update=1
    fi

    if [[ $mach_update == 0 ]]; then
      echo "Templates are up-to-date"
      exit 0
    fi

    nix run .#update-versions
    nix run .#mach-update-flakes -- force
    for var in engine core; do
      (cd templates/"$var"; nix run --override-input mach ../.. .#zig2nix -- zon2lock)
      # Call using nix run because update-versions may change the mach nominated zig version
      nix run .#autofix -- templates/"$var"
    done

    nix run .#readme > README.md
    '';
}
