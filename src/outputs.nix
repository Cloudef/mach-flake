{
  lib
  , zigv
  , mach-env
}:

with lib;
with builtins;

{
  apps = mergeAttrsList (attrValues (mapAttrs (k: zig: let
    env = mach-env { inherit zig; };
  in {
    "${k}" = env.app-no-root [] ''zig "$@"'';
    "zig2nix-${k}" = env.app-no-root [] ''zig2nix "$@"'';

    # Backwards compatiblity
    "zon2json-${k}" = env.app-no-root [] ''zig2nix zon2json "$@"'';
    "zon2json-lock-${k}" = env.app-no-root [] ''zig2nix zon2lock "$@"'';
    "zon2nix-${k}" = env.app-no-root [] ''zig2nix zon2nix "$@"'';
  }) zigv));

  devShells = mergeAttrsList (attrValues (mapAttrs (k: zig: let
    env = mach-env { inherit zig; };
  in {
    "${k}" = env.mkShell {};
  }) zigv));
}
