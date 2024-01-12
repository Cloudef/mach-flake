{ env, stdenvNoCC, fetchurl, gzip, jq }:

{
   zigTarget ? null
   , zigPreferMusl ? false
   , ...
} @attrs:

with builtins;

let
   target = env.lib.resolveTarget zigTarget stdenvNoCC zigPreferMusl;
   mach-binaries = fromJSON (readFile ./mach-binaries.json);
   dawn-version = mach-binaries."dawn-${target}".ver;
   dawn-binary = fetchurl {
      url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${dawn-version}/libdawn_${target}_release-fast.a.gz";
      hash = mach-binaries."dawn-${target}".lib;
   };
   dawn-headers = fetchurl {
      url = "https://github.com/hexops/mach-gpu-dawn/releases/download/${dawn-version}/headers.json.gz";
      hash = mach-binaries."dawn-${target}".hdr;
   };
in env.package (
   attrs // {
   # https://github.com/hexops/mach-core/blob/main/build_examples.zig
   NO_ENSURE_SUBMODULES = "true";
   NO_ENSURE_GIT = "true";
   # https://github.com/hexops/mach-gpu-dawn/blob/main/build.zig
   postPatch = ''
      mkdir -p zig-cache/mach/gpu-dawn/${dawn-version}/${target}/release-fast
      (
         cd zig-cache/mach/gpu-dawn/${dawn-version}
         ${gzip}/bin/gzip -d -c ${dawn-binary} > ${target}/release-fast/libdawn.a
         ${gzip}/bin/gzip -d -c ${dawn-headers} > ${target}/release-fast/headers.json
         while read -r key; do
            mkdir -p "$(dirname "$key")"
            path="$(realpath $key)"
            ${jq}/bin/jq -r --arg k "$key" '."\($k)"' ${target}/release-fast/headers.json > "$path"
         done < <(${jq}/bin/jq -r 'to_entries | .[] | .key' ${target}/release-fast/headers.json)
      )
      ${attrs.postPatch or ""}
      '';
})
