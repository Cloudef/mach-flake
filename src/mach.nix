{
  lib
  , test-app
  , mach-binary-triples
  , zon2json
  , file
  , curl
  , jq
  , coreutils
  , gnused
  , gnugrep
  , git
  , zig
}:

with builtins;
with lib;

{
  # nix run .#mach.update-zig-versions
  update-zig-versions = test-app [ curl jq ] ''
    curl -sSL https://machengine.org/zig/index.json | jq 'with_entries(select(.key|(startswith("mach-") or endswith("-mach"))))'
    '';

  # nix run .#mach.update-binaries
  update-binaries = let
    base-url = "https://github.com/hexops/mach-gpu-dawn/releases/download";
  in test-app [ coreutils gnused gnugrep jq ] ''
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
        for triple in ${concatStringsSep " " mach-binary-triples}; do
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

  # nix run .#mach.update-flakes
  update-flakes = test-app [ git gnused ] ''
    if [[ "''${1-}" != "force" ]] && [[ "$(git log --format=%B -n 1 HEAD)" == "Update templates rev" ]]; then
      echo "Template revisions are up-to-date"
      exit 0
    fi
    flake_rev="$(git rev-parse HEAD)"
    sed "s/SED_REPLACE_REV/$flake_rev/" templates/flake.nix > templates/engine/flake.nix
    sed 's/mach-engine-project/mach-core-project/g' templates/flake.nix > templates/core/flake.nix
    sed -i "s/SED_REPLACE_REV/$flake_rev/" templates/core/flake.nix
    '';

  # nix run .#mach.update
  update = test-app [ coreutils gnused git zig jq zon2json ] ''
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

    old_url="$(zon2json templates/core/build.zig.zon | jq -er '.dependencies.mach.url')"
    if [[ "$old_url" != "https://pkg.machengine.org/mach/$rev.tar.gz" ]]; then
      cp templates/core/build.zig.zon2json-lock "$tmpdir/core-lock"
      rm -rf templates/core
      git clone https://github.com/hexops/mach-core-starter-project.git templates/core
      rm -rf templates/core/.git
      generate mach-core-project mach "$rev" > templates/core/build.zig.zon
      mv "$tmpdir/core-lock" templates/core/build.zig.zon2json-lock
      git add templates/core/build.zig.zon2json-lock
      mach_update=1
    fi

    if [[ $mach_update == 0 ]]; then
      echo "Templates are up-to-date"
      exit 0
    fi

    nix run .#mach.update-zig-versions > versions.json
    nix run .#mach.update-flakes -- force
    for var in engine core; do
      (cd templates/"$var"; nix run --override-input mach ../.. .#zon2json-lock)
      # Call using nix run because update-versions may change the mach nominated zig version
      nix run .#autofix -- templates/"$var"
    done

    nix run .#mach.update-binaries > mach-binaries.json
    nix run .#readme > README.md
    '';
}
