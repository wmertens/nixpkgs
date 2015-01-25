{ stdenv, fetchapplesource }:

stdenv.mkDerivation rec {
  version = "339.92.1";
  name    = "libdispatch-${version}";

  src = fetchapplesource {
    inherit version;
    name   = "libdispatch";
    sha256 = "1lc5033cmkwxy3r26gh9plimxshxfcbgw6i0j7mgjlnpk86iy5bk";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include/dispatch $out/include/os

    cp -r dispatch/*.h $out/include/dispatch
    cp -r private/*.h  $out/include/dispatch
    cp -r os/object.h  $out/include/os
  '';
}
