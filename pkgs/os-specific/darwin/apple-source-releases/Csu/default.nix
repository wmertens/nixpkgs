{ stdenv, appleDerivation }:

appleDerivation {
  postUnpack = ''
    substituteInPlace $sourceRoot/Makefile \
      --replace "/usr/lib" "/lib" \
      --replace "/usr/local/lib" "/lib" \
      --replace "/usr/bin" "" \
      --replace "/bin/" ""
  '';

  installPhase = ''
    export DSTROOT=$out
    make install
  '';

  meta = with stdenv.lib; {
    description = "Apple's common startup stubs for darwin";
    maintainers = with maintainers; [ copumpkin ];
    platforms   = platforms.darwin;
    license     = licenses.apsl20;
  };
}
