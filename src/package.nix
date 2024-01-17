{
   resolveTargetSystem
   , packageForTarget
   , target
   , fetchurl
   , gzip
   , jq
}:

{
   stdenvNoCC
   , zigTarget ? null
   , zigPreferMusl ? false
   , ...
} @attrs:

with builtins;

let
   system = resolveTargetSystem {
      target = zigTarget;
      platform = stdenvNoCC.targetPlatform;
      musl = zigPreferMusl;
   };

   mach-binaries = fromJSON (readFile ../mach-binaries.json);

   dawn-binary = let
      target = "${system.zig.cpu}-${system.zig.versionlessKernel}-${system.zig.abi}";
      ver = mach-binaries."dawn-${target}".ver or (throw "dawn binaries not available for ${target}");
      lib = let
         base-url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${ver}";
      in fetchurl {
         url =
            if system.zig.versionlessKernel == "windows" then "${base-url}/dawn_${target}_release-fast.lib.gz"
            else "${base-url}/libdawn_${target}_release-fast.a.gz";
         hash = mach-binaries."dawn-${target}".lib;
      };
      hdr = fetchurl {
         url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${ver}/headers.json.gz";
         hash = mach-binaries."dawn-${target}".hdr;
      };
   in stdenvNoCC.mkDerivation {
      name = "mach-gpu-dawn";
      version = ver;
      srcs = [ lib hdr ];
      nativeBuildInputs = [ gzip jq ];
      phases = [ "installPhase" ];
      installPhase = ''
         mkdir -p $out/${ver}/${target}/release-fast
         (
            cd $out/${ver}
            gzip -d -c ${lib} > ${target}/release-fast/libdawn.a
            gzip -d -c ${hdr} > ${target}/release-fast/headers.json
            while read -r key; do
               mkdir -p "$(dirname "$key")"
               path="$(realpath $key)"
               jq -er --arg k "$key" '."\($k)"' ${target}/release-fast/headers.json > "$path"
            done < <(jq -er 'to_entries | .[] | .key' ${target}/release-fast/headers.json)
         )
         '';
   };
in packageForTarget target (
   attrs // {
   # https://github.com/hexops/mach-core/blob/main/build_examples.zig
   NO_ENSURE_SUBMODULES = "true";
   NO_ENSURE_GIT = "true";
   # https://github.com/hexops/mach-gpu-dawn/blob/main/build.zig
   postPatch = ''
      mkdir -p zig-cache/mach
      ln -s ${dawn-binary} zig-cache/mach/gpu-dawn
      ${attrs.postPatch or ""}
      '';
})
