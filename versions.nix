{
  lib
  , stdenvNoCC
  , callPackage
  , fetchurl
  , zigSystem
  , zigHook
}:

with lib;
with builtins;

let
  zig = k: v: { installDocs ? false }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "zig";
      version = v.version;

      src = fetchurl {
        url = v.${zigSystem}.tarball;
        sha256 = v.${zigSystem}.shasum;
      };

      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        mkdir -p $out/{bin,lib}
        cp -r lib/* $out/lib
        install -Dm755  zig $out/bin/zig
        install -m644 LICENSE $out/LICENSE
      '' + optionalString (installDocs) ''
        mkdir -p $out/doc
        if [[ -d docs ]]; then
          cp -r docs $out/doc
        else
          cp -r doc $out/doc
        fi
      '';

      passthru = let
        machVer = removeSuffix "-mach" k;
      in {
        date = v.date;
        notes = v.notes;
        stdDocs = v.stdDocs;
        docs = v.docs;
        machVersion = if toInt (versions.major machVer) < 2000 then "v${k}" else "main";
        machDocs = v.machDocs;
        machNominated = v.machNominated;
        size = res.size;
        src = v.src;
        hook = callPackage zigHook {
          zig = finalAttrs.finalPackage;
        };
      };

      meta = {
        homepage = "https://ziglang.org/";
        description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
        license = licenses.mit;
        platforms = platforms.unix;
        maintainers = []; # needed by the setup hook
      };
    });
in filterAttrs (n: v: v != null)
    (mapAttrs (k: v: if v ? ${zigSystem} then callPackage (zig k v) {} else null)
      (fromJSON (readFile ./versions.json)))
