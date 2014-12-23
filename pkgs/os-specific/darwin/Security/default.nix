{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "57031.1.35";
  name    = "Security-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/Security/${name}.tar.gz";
    sha256 = "0aamxscaggyymw97134rl4s0qjj3jfr69g88r4cjs9nvgwqdgan3";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/System/Library/Frameworks/Security.framework/Headers
    cp Security/sec/Security/*.h $out/System/Library/Frameworks/Security.framework/Headers/
    cp Security/libsecurity_cssm/lib/*.h $out/System/Library/Frameworks/Security.framework/Headers/
    mkdir -p $out/nix-support
    cat >$out/nix-support/setup-hook <<EOF
    export NIX_CFLAGS_COMPILE+=" -F$out/System/Library/Frameworks"
    EOF
  '';
}
