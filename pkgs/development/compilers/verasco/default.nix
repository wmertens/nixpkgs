{ stdenv, fetchurl, coq, ocaml, ocamlPackages }:

stdenv.mkDerivation rec {
  name    = "verasco-${version}";
  version = "1.0";

  src = fetchurl {
    url    = "http://compcert.inria.fr/verasco/release/verasco-${version}.tgz";
    sha256 = "1570hbv88sf4ds9g1inns2bln3ljlly1i180m53cghsjns26i25v";
  };

  buildInputs = [ coq ocaml ocamlPackages.menhir ocamlPackages.zarith ];

  configurePhase = ''
    substituteInPlace ./configure --replace '{toolprefix}gcc' '{toolprefix}cc'
    ./configure -prefix $out -toolprefix ${stdenv.gcc}/bin/ '' +
    (if stdenv.isDarwin then "ia32-macosx" else "ia32-linux");

  meta = with stdenv.lib; {
    description = "Verasco is a static analyzer for the CompCert subset of ISO C 1999";
    homepage    = "http://compcert.inria.fr/verasco/";
    license     = licenses.inria;
    platforms   = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ jwiegley ];
  };
}
