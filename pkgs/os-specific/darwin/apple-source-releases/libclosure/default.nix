{ stdenv, fetchapplesource }:

stdenv.mkDerivation rec {
  version = "63";
  name    = "libclosure-${version}";

  src = fetchapplesource {
    inherit version;
    name   = "libclosure";
    sha256 = "083v5xhihkkajj2yvz0dwgbi0jl2qvzk22p7pqq1zp3ry85xagrx";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include
    cp *.h $out/include/
  '';
}