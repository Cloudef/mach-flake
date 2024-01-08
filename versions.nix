{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, stdenv ? pkgs.stdenvNoCC, system ? builtins.currentSystem }:

with lib;
with builtins;

let
  zig-system = concatStringsSep "-" (map (x: if x == "darwin" then "macos" else x) (splitString "-" system));
in filterAttrs (n: v: v != null) (mapAttrs (k: v: let
  res = v."${zig-system}" or null;
in if res == null then null else stdenv.mkDerivation {
  pname = "zig";
  version = v.version;

  src = pkgs.fetchurl {
    url = res.tarball;
    sha256 = res.shasum;
  };

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -r lib/* $out/lib
    install -Dm755  zig $out/bin/zig
    install -m644 LICENSE $out/LICENSE
  '';

  passthru = let
    machVer = lib.removeSuffix "-mach" k;
  in {
    date = v.date;
    stdDocs = v.stdDocs;
    docs = v.docs;
    machVersion = if lib.toInt (lib.versions.major machVer) < 2000 then "v${k}" else "main";
    machDocs = v.machDocs;
    machNominated = v.machNominated;
    size = res.size;
    src = v.src;
  };

  meta = with lib; {
    homepage = "https://ziglang.org/";
    description = "General-purpose programming language and toolchain for maintaining robust, optimal, and reusable software";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}) (fromJSON (readFile ./versions.json)))
