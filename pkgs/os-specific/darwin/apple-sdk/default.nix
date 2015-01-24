{ stdenv, fetchurl, xar, gzip, cpio }:

let
  pkg = { name, sha256 }: stdenv.mkDerivation {
    inherit name;

    src = fetchurl {
      url = "http://swcdn.apple.com/content/downloads/00/14/031-07556/i7hoqm3awowxdy48l34uel4qvwhdq8lgam/${name}.pkg";
      inherit sha256;
    };

    buildInputs = [ xar gzip cpio ];

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    unpackPhase = ''
      xar -x -f $src
    '';

    installPhase = ''
      start="$(pwd)"
      mkdir -p $out
      cd $out
      cat $start/Payload | gzip -d | cpio -idm

      mv usr/* .
      rmdir usr

      mv System/* .
      rmdir System
    '';

    meta = with stdenv.lib; {
      description = "Apple SDK ${name}";
      maintainers = with maintainers; [ copumpkin ];
      platforms   = platforms.darwin;
    };
  };

  # We already build most of the contents of this, so I doubt we'll need it. dsymutil might be
  # the one exception, but we don't use that right now. Leaving it here in case someone does.
  tools = pkg { name = "CLTools_Executables"; sha256 = "1rqrgip9pwr9d6p1hkd027lzxpymr1qm54jjnkldjjb8m4nps7bp"; };

  # I'd rather not "export" this, since they're somewhat monolithic and encourage bad habits.
  # Also, the include directory inside here should be captured (almost?) entirely by our more
  # precise Apple package structure, so with any luck it's unnecessary.
  sdk = pkg { name = "DevSDK_OSX109"; sha256 = "0x6r61h78r5cxk9dbw6fnjpn6ydi4kcajvllpczx3mi52crlkm4x"; };

  framework = name: deps: stdenv.mkDerivation {
    name = "apple-framework-${name}";

    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      linkFramework() {
        local path="$1"
        local dest="$out/Library/Frameworks/$path"
        local name="$(basename "$path" .framework)"
        local current="$(readlink "/System/Library/Frameworks/$path/Versions/Current")"

        mkdir -p "$dest"
        pushd "$dest" >/dev/null

        ln -s "${sdk}/Library/Frameworks/$path/Versions/$current/Headers"
        ln -s -L "/System/Library/Frameworks/$path/Versions/$current/$name"
        ln -s -L "/System/Library/Frameworks/$path/Versions/$current/Resources"

        if [ -f "/System/Library/Frameworks/$path/module.map" ]; then
          ln -s "/System/Library/Frameworks/$path/module.map"
        fi

        pushd "${sdk}/Library/Frameworks/$path/Versions/$current" >/dev/null
        local children=$(echo Frameworks/*.framework)
        popd >/dev/null

        for child in $children; do
          childpath="$path/Versions/$current/$child"
          linkFramework "$childpath"
        done

        if [ -d "$dest/Versions/$current" ]; then
          mv $dest/Versions/$current/* .
        fi

        popd >/dev/null
      }

      linkFramework "${name}.framework"
    '';

    propagatedBuildInputs = deps;

    # Not going to bother being more precise than this...
    __propagatedImpureHostDeps = [ "/System/Library/Frameworks/${name}.framework/Versions" ];

    meta = with stdenv.lib; {
      description = "Apple SDK framework ${name}";
      maintainers = with maintainers; [ copumpkin ];
      platforms   = platforms.darwin;
    };
  };
in rec {
  libs = {
    xpc = stdenv.mkDerivation {
      name   = "apple-lib-xpc";
      phases = [ "installPhase" "fixupPhase" ];

      installPhase = ''
        mkdir -p $out/include
        pushd $out/include >/dev/null
        ln -s "${sdk}/include/xpc"
        popd >/dev/null
      '';
    };
  };

  # This could be a more direct knot, but the presence of missing frameworks makes it more painful to do that way
  frameworks = stdenv.lib.mapAttrs framework (import ./frameworks.nix { inherit frameworks libs; });
}
