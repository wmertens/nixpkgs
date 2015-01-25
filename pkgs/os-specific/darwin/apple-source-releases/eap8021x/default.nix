{ stdenv, fetchapplesource }:

stdenv.mkDerivation rec {
  version = "180";
  name    = "eap8021x-${version}";

  src = fetchapplesource {
    inherit version;
    name   = "eap8021x";
    sha256 = "1ynkq8zmhgqhpkdg2syj085lzya0fz55d3423hvf9kcgpbjcd9ic";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/Library/Frameworks/EAP8021X.framework/Headers

    cp EAP8021X.fproj/EAPClientProperties.h $out/Library/Frameworks/EAP8021X.framework/Headers
  '';
}