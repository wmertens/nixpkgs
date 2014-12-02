{ stdenv, fetchurl, launchd, Security }:

stdenv.mkDerivation rec {
  version = "596.15";
  name    = "configd-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/configd/${name}.tar.gz";
    sha256 = "01zgmbk67lwl3xg41pn2ykrs3va2drwjicbvfa49kpmwzf8saf2x";
  };

  phases = [ "unpackPhase" "installPhase" ];

  buildInputs = [ launchd ];

  propagatedBuildInputs = [ Security ];

  installPhase = ''
    mkdir -p $out/include
    cp dnsinfo/*.h $out/include/
    mkdir -p $out/System/Library/Frameworks/SystemConfiguration.framework/Headers
    cp SystemConfiguration.fproj/*.h $out/System/Library/Frameworks/SystemConfiguration.framework/Headers/
    mkdir -p $out/nix-support
    cat >$out/nix-support/setup-hook <<EOF
    export NIX_CFLAGS_COMPILE+=" -F$out/System/Library/Frameworks"
    EOF
  '';
}
