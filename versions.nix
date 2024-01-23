{
  lib
  , callPackage
  , zigSystem
  , zigHook
  , zigNix
}:

with builtins;
with lib;

mapAttrs (k: v: (callPackage zigNix {
  inherit zigHook zigSystem;
  inherit (v) version;
  release = v;
}) // {
  inherit (v) machNominated machDocs;
}) (fromJSON (readFile ./versions.json))
