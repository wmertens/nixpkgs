{ stdenv, fetchapplesource, ed, unifdef, Libc_old }:

stdenv.mkDerivation rec {
  version = "997.90.3";
  name    = "Libc-${version}";

  src = fetchapplesource {
    inherit version;
    name   = "Libc";
    sha256 = "1jz5bx9l4q484vn28c6n9b28psja3rpxiqbj6zwrwvlndzmq1yz5";
  };

  phases = [ "unpackPhase" "installPhase" ];

  buildInputs = [ ed unifdef ];

  # TODO: asl.h actually comes from syslog project now
  installPhase = ''
    export SRCROOT=$PWD
    export DSTROOT=$out
    export PUBLIC_HEADERS_FOLDER_PATH=include
    export PRIVATE_HEADERS_FOLDER_PATH=include
    bash xcodescripts/headers.sh

    # Ugh Apple stopped releasing this stuff so we need an older one...
    cp    ${Libc_old}/include/spawn.h    $out/include
    cp    ${Libc_old}/include/setjmp.h   $out/include
    cp    ${Libc_old}/include/ucontext.h $out/include
    cp    ${Libc_old}/include/pthread*.h $out/include
    cp    ${Libc_old}/include/sched.h    $out/include
    cp -R ${Libc_old}/include/malloc     $out/include

    mkdir -p $out/include/libkern
    cp ${Libc_old}/include/asl.h                    $out/include
    cp ${Libc_old}/include/libproc.h                $out/include
    cp ${Libc_old}/include/libkern/OSAtomic.h       $out/include/libkern
    cp ${Libc_old}/include/libkern/OSCacheControl.h $out/include/libkern
  '';
}
