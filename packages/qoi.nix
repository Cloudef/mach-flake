{
  pkgs ? import <nixpkgs> {}
  , stdenv ? pkgs.stdenv
  , lib ? pkgs.lib
  , fetchFromGitHub ? pkgs.fetchFromGitHub
}:

let
  rev = "827a7e4418ca75553e4396ca4e8c508c9dc07048";
in stdenv.mkDerivation {
  pname = "qoiconv";
  version = rev;

  src = fetchFromGitHub {
    inherit rev;
    owner = "phoboslab";
    repo = "qoi";
    hash = "sha256-R91bf2gfc7PTgkhWhJ0GOSuQPcGZgRXgKUK6Iqzezgs=";
  };

  makeFlags = [ "CFLAGS=-I${pkgs.stb}/include/stb" "conv" ];

  installPhase = ''
    install -Dm755 qoiconv $out/bin/qoiconv
    '';

  meta = with lib; {
    description = "The “Quite OK Image Format” for fast, lossless image compression";
    homepage = "https://github.com/phoboslab/qoi";
    license = licenses.mit;
  };
}
