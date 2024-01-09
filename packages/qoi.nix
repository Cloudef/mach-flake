{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, fetchFromGitHub ? pkgs.fetchFromGitHub, fetchurl ? pkgs.fetchurl }:

let
  stb_image = fetchurl {
    url = "https://raw.githubusercontent.com/nothings/stb/5736b15f7ea0ffb08dd38af21067c314d6a3aae9/stb_image.h";
    hash = "sha256-OOCMHFq4hpro1gXdrvqFrT/qJKKWT9Y6CZwMD3nHC8w=";
  };
  stb_image_write = fetchurl {
    url = "https://raw.githubusercontent.com/nothings/stb/5736b15f7ea0ffb08dd38af21067c314d6a3aae9/stb_image_write.h";
    hash = "sha256-y9XwrXqc9EaK/7NjVKHSM4A08sEkc88ajjIFPLaRSgU=";
  };
in stdenv.mkDerivation {
  pname = "qoiconv";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "phoboslab";
    repo = "qoi";
    rev = "827a7e4418ca75553e4396ca4e8c508c9dc07048";
    hash = "sha256-R91bf2gfc7PTgkhWhJ0GOSuQPcGZgRXgKUK6Iqzezgs=";
  };

  makeFlags = [ "conv" ];

  patchPhase = ''
    ln -s ${stb_image} stb_image.h
    ln -s ${stb_image_write} stb_image_write.h
    '';

  installPhase = ''
    install -Dm744 qoiconv $out/bin/qoiconv
    '';

  meta = with lib; {
    description = "The “Quite OK Image Format” for fast, lossless image compression";
    homepage = "https://github.com/phoboslab/qoi";
    license = licenses.mit;
  };
}
