{stdenv, fetchurl, perl, ncurses, gmp, makeWrapper, libiconv}:

stdenv.mkDerivation rec {
  version = "7.8.3";

  name = "ghc-${version}-binary";

  src =
    if stdenv.system == "x86_64-darwin" then
      fetchurl {
        url = "http://haskell.org/ghc/dist/${version}/ghc-${version}-x86_64-apple-darwin.tar.bz2";
        sha256 = "1ja0cq5xyjcvjpvjmm4nzhkpmwfs2kjlldbc48lxcs9rmqi7rnay";
      }
    else throw "cannot bootstrap GHC on this platform";

  buildInputs = [perl makeWrapper libiconv];

  postUnpack =
    # Strip is harmful, see also below. It's important that this happens
    # first. The GHC Cabal build system makes use of strip by default and
    # has hardcoded paths to /usr/bin/strip in many places. We replace
    # those below, making them point to our dummy script.
     ''
      mkdir "$TMP/bin"
      for i in strip; do
        echo '#! ${stdenv.shell}' > "$TMP/bin/$i"
        chmod +x "$TMP/bin/$i"
      done
      PATH="$TMP/bin:$PATH"
     '' +
    # We have to patch the GMP paths for the integer-gmp package.
     ''
      find . -name integer-gmp.buildinfo \
          -exec sed -i "s@extra-lib-dirs: @extra-lib-dirs: ${gmp}/lib@" {} \;
     '' +
    # On Linux, use patchelf to modify the executables so that they can
    # find editline/gmp.
    stdenv.lib.optionalString stdenv.isLinux ''
      find . -type f -perm +100 \
          -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${ncurses}/lib:${gmp}/lib" {} \;
      sed -i "s|/usr/bin/perl|perl\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      sed -i "s|/usr/bin/gcc|gcc\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      for prog in ld ar gcc strip ranlib; do
        find . -name "setup-config" -exec sed -i "s@/usr/bin/$prog@$(type -p $prog)@g" {} \;
      done
     '' +

     stdenv.lib.optionalString stdenv.isDarwin ''
       fix () {
         install_name_tool -change \
           /usr/lib/libiconv.2.dylib \
           ${libiconv}/lib/libiconv.dylib \
           $1 \
           || exit 1
       }

       for library in $(find . -type f -name '*.dylib'); do
         fix $library
       done

       for tool in haddock hsc2hs hpc ghc-cabal ghc-pkg ghc-pwd ghc-stage2; do
         fix $(find . -type f -executable -name $tool)
       done

       for file in $(find . -name setup-config); do
         substituteInPlace $file --replace /usr/bin/ranlib $(type -P ranlib)
       done
     '';

  configurePhase = ''
    ./configure --prefix=$out --with-gmp-libraries=${gmp}/lib \
      --with-gmp-includes=${gmp}/include
  '';

  # Stripping combined with patchelf breaks the executables (they die
  # with a segfault or the kernel even refuses the execve). (NIXPKGS-85)
  dontStrip = true;

  # No building is necessary, but calling make without flags ironically
  # calls install-strip ...
  buildPhase = "true";

  postInstall =
      ''
        # Sanity check, can ghc create executables?
        cd $TMP
        mkdir test-ghc; cd test-ghc
        cat > main.hs << EOF
          {-# LANGUAGE TemplateHaskell #-}
          module Main where
          main = putStrLn \$([|"yes"|])
        EOF
        echo sanity check
      '' + stdenv.lib.optionalString stdenv.isDarwin ''
        wrapProgram $out/bin/ghc \
          --add-flags "-optl -Wl,-no_dtrace_dof" \
          --prefix DYLD_LIBRARY_PATH : "${libiconv}/lib"
      '' + ''
        $out/bin/ghc --make main.hs
        echo compilation ok
        [ $(./main) == "yes" ]
      '';

  meta.license = stdenv.lib.licenses.bsd3;
  meta.platforms = ["x86_64-darwin"];
}
