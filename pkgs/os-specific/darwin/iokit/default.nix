{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "1050.1.21";
  name    = "IOKitUser-${version}";

  src = fetchurl {
    url    = "http://opensource.apple.com/tarballs/IOKitUser/${name}.tar.gz";
    sha256 = "1azin6w7cnzl0iv8kd2qzgwcp6a45zy64y5z1i6jysjcl6xmlw22";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include/IOKit
    cp *.h $out/include/IOKit
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ joelteon ];
    platforms   = platforms.darwin;
    license     = licenses.apsl20;
  };
}
