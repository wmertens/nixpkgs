{ stdenv, fetchapplesource }:

stdenv.mkDerivation rec {
  version = "522.92.1";
  name    = "mDNSResponder-${version}";

  src = fetchapplesource {
    inherit version;
    name   = "mDNSResponder";
    sha256 = "1cp87qda1s7brriv413i71yggm8yqfwv64vknrnqv24fcb8hzbmy";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include
    cp mDNSShared/dns_sd.h $out/include
  '';
}
