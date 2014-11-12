{ stdenv, fetchgit, pkgconfig, libsepol, pcre
, enablePython ? false, swig ? null, python ? null
}:

assert enablePython -> swig != null && python != null;

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "libselinux-${version}";
  version = "2.3";
  inherit (libsepol) se_release se_url;

  src = fetchgit {
    url = "https://github.com/SELinuxProject/selinux";
    rev = "refs/tags/libselinux-${version}";
    sha256 = "0vi2k14gh512b2prnn31l0cg78lmqjqrybdgdyibbhcg2s4v5snb";
  };

  preConfigure = "cd libselinux";

  buildInputs = [ pkgconfig libsepol pcre ]
             ++ optionals enablePython [ swig python ];

  postPatch = optionalString enablePython ''
    sed -i -e 's|\$(LIBDIR)/libsepol.a|${libsepol}/lib/libsepol.a|' src/Makefile
  '';

  installFlags = [ "PREFIX=$(out)" "DESTDIR=$(out)" ];
  installTargets = [ "install" ] ++ optional enablePython "install-pywrap";

  # TODO: Figure out why the build incorrectly links libselinux.so
  postInstall = ''
    rm $out/lib/libselinux.so
    ln -s libselinux.so.1 $out/lib/libselinux.so
  '';

  meta = {
    inherit (libsepol.meta) homepage platforms maintainers;
  };
}
