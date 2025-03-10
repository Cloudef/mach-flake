{
  lib
  , zigPackage
  , machNativeBuildInputs
  , machBuildInputsForTarget
  , machWrapperLibsForTarget
  , target
}:

{
  stdenvNoCC
  , zigTarget ? null
  , zigPreferMusl ? false
  , zigWrapperLibs ? []
  , nativeBuildInputs ? []
  , buildInputs ? []
  , ...
} @userAttrs:

with builtins;
with lib;

let
  config =
    if zigPreferMusl then
      replaceStrings ["-gnu"] ["-musl"] stdenvNoCC.targetPlatform.config
    else stdenvNoCC.targetPlatform.config;
  default-target = (target config).zig;
  resolved-target = if zigTarget != null then zigTarget else default-target;
in zigPackage (userAttrs // {
  nativeBuildInputs = nativeBuildInputs ++ machNativeBuildInputs;
  buildInputs = buildInputs ++ (machBuildInputsForTarget resolved-target);
  zigWrapperLibs = zigWrapperLibs ++ (machWrapperLibsForTarget resolved-target);
})
