{ stdenv, cmake, coreutils, fetchurl, libcxx, libunwind, llvm }:

stdenv.mkDerivation rec {
  version = "3.5.0";
  name    = "libcxxabi-${version}";

  src = fetchurl {
    url    = "http://llvm.org/releases/${version}/${name}.src.tar.xz";
    sha256 = "1ndcpw3gfrzh7m1jac2qadhkrqgvb65cns69j9niydyj5mmbxijk";
  };

  NIX_CFLAGS_LINK = if stdenv.isDarwin then "" else "-L${libunwind}/lib";

  buildInputs = [ coreutils cmake ];

  postUnpack = ''
    unpackFile ${libcxx.src}
    unpackFile ${llvm.src}
    export NIX_CFLAGS_COMPILE+="  -I$PWD/include"
    export cmakeFlags="-DLLVM_PATH=$(${coreutils}/bin/readlink -f llvm-*) -DLIBCXXABI_LIBCXX_INCLUDES=$(${coreutils}/bin/readlink -f libcxx-*)/include"
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    export TRIPLE=x86_64-apple-darwin
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    export NIX_CFLAGS_COMPILE+=" -I${libunwind}/include"
  '';

  NIX_SKIP_CXXABI = "true";

  installPhase = if stdenv.isDarwin
    then ''
      for file in lib/*; do
        # this should be done in CMake, but having trouble figuring out
        # the magic combination of necessary CMake variables
        # if you fancy a try, take a look at
        # http://www.cmake.org/Wiki/CMake_RPATH_handling
        install_name_tool -id $out/$file $file
      done
      make install
      install -d 755 $out/include
      install -m 644 $src/include/cxxabi.h $out/include
    ''
    else ''
      install -d -m 755 $out/include $out/lib
      install -m 644 lib/libc++abi.so.1.0 $out/lib
      install -m 644 $src/include/cxxabi.h $out/include
      ln -s libc++abi.so.1.0 $out/lib/libc++abi.so
      ln -s libc++abi.so.1.0 $out/lib/libc++abi.so.1
    '';

  meta = {
    homepage = http://libcxxabi.llvm.org/;
    description = "A new implementation of low level support for a standard C++ library";
    license = "BSD";
    maintainers = stdenv.lib.maintainers.shlevy;
    platforms = stdenv.lib.platforms.unix;
  };
}
