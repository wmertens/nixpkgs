{ stdenv, fetchgit }:

stdenv.mkDerivation {
  name = "objconv-1.0";

  src = fetchgit {
    url = "https://github.com/vertis/objconv";
    rev = "refs/heads/master";
    sha256 = "a2fa55121baaa151fd38e3217ca4ff6cfa9c888690d88d3c069bdfaaf25ac2af";
  };

  buildPhase = "clang++ -o objconv -O2 src/*.cpp";

  installPhase = "mkdir -p $out/bin && mv objconv $out/bin";
}
