{ system      ? builtins.currentSystem
, allPackages ? import ../../top-level/all-packages.nix
, platform    ? null
, config      ? {}
}:

let
  fetch = { file, sha256 }: import <nix/fetchurl.nix> {
    url = "https://dl.dropboxusercontent.com/u/361503/${file}";
    inherit sha256;
    executable = true;
  };

  bootstrapFiles = {
    sh    = fetch { file = "sh";    sha256 = "1amnaql1rc6fdsxyav7hmhj8ylf4ccmgsl7v23x4sgw94pkipz78"; };
    bzip2 = fetch { file = "bzip2"; sha256 = "1f4npmrhx37jnv90by8b39727cam3n811lvglsc6da9xm80g2f5l"; };
    mkdir = fetch { file = "mkdir"; sha256 = "0x9jqf4rmkykbpkybp40x4d0v0dq99i0r5yk8096mjn1m7s7xa0p"; };
    cpio  = fetch { file = "cpio";  sha256 = "1a5s8bs14jhhmgrf4cwn92iq8sbz40qhjzj7y35ri84prp9clkc3"; };
  };
in rec {
  allPackages = import ../../top-level/all-packages.nix;

  commonPreHook = ''
    export NIX_ENFORCE_PURITY=1
    export NIX_IGNORE_LD_THROUGH_GCC=1
    export NIX_DONT_SET_RPATH=1
    export NIX_NO_SELF_RPATH=1
    stripAllFlags=" " # the Darwin "strip" command doesn't know "-s"
    xargsFlags=" "
    export MACOSX_DEPLOYMENT_TARGET=10.8
    export SDKROOT=
    export CMAKE_OSX_ARCHITECTURES=x86_64
    export NIX_CFLAGS_COMPILE+=" --sysroot=/var/empty -Wno-multichar -Wno-deprecated-declarations"
  '';

  # libSystem and its transitive dependencies. Get used to this; it's a recurring theme in darwin land
  libSystemClosure = [
    "/usr/lib/libSystem.dylib"
    "/usr/lib/libSystem.B.dylib"
    "/usr/lib/libobjc.A.dylib"
    "/usr/lib/libobjc.dylib"
    "/usr/lib/libauto.dylib"
    "/usr/lib/libc++abi.dylib"
    "/usr/lib/libc++.1.dylib"
    "/usr/lib/libDiagnosticMessagesClient.dylib"
    "/usr/lib/system"
  ];

  # The one dependency of /bin/sh :(
  binShClosure = [ "/usr/lib/libncurses.5.4.dylib" ];

  bootstrapTools = derivation {
    name = "bootstrap-tools";

    builder = bootstrapFiles.sh; # Not a filename! Attribute 'sh' on bootstrapFiles

    args = [ ./unpack-bootstrap-tools.sh ];

    tarball = fetch { file = "bootstrap-tools.5.cpio.bz2"; sha256 = "0j06zlhfcphxlz3s7wmcqc7jlaykwqi06caw6fjb479k0ikxhj7l"; };

    inherit system;

    mkdir = bootstrapFiles.mkdir;
    bzip2 = bootstrapFiles.bzip2;
    cpio  = bootstrapFiles.cpio;

    # What are these doing?
    langC  = true;
    langCC = true;

    __impureHostDeps           = libSystemClosure;
    __propagatedImpureHostDeps = binShClosure ++ libSystemClosure;
  };

  bootstrapPreHook = "export LD_DYLD_PATH=${bootstrapTools}/lib/dyld";

  stageFun = {cc, extraAttrs ? {}, overrides ? (pkgs: {}), extraPath ? [], extraPreHook ? "", extraBuildInputs ? []}:
    let
      thisStdenv = import ../generic {
        inherit system config extraBuildInputs;
        name = "stdenv-darwin-boot";
        preHook =
          ''
            # Don't patch #!/interpreter because it leads to retained
            # dependencies on the bootstrapTools in the final stdenv.
            dontPatchShebangs=1
            ${commonPreHook}
            ${extraPreHook}
          '';
        shell        = "${bootstrapTools}/bin/sh";
        initialPath  = [bootstrapTools] ++ extraPath;
        fetchurlBoot = import ../../build-support/fetchurl {
          stdenv = stage0.stdenv;
          curl   = bootstrapTools;
        };
        inherit cc;

        # The stdenvs themselves don't use mkDerivation, so I need to specify this here
        __stdenvImpureHostDeps = binShClosure ++ libSystemClosure;

        # Do we need this platform inheritance?
        extraAttrs = extraAttrs // { inherit platform; };
        overrides  = pkgs: (overrides pkgs) // { fetchurl = thisStdenv.fetchurlBoot; };
      };

      thisPkgs = allPackages {
        inherit system platform;
        bootStdenv = thisStdenv;
      };
    in { stdenv = thisStdenv; pkgs = thisPkgs; };

  stage0 = stageFun {
    cc = "/no-such-path";
    extraBuildInputs = [ bootstrapTools ];
  };

  stage1 = stageFun {
    cc = import ../../build-support/clang-wrapper {
      nativeTools  = true;
      nativePrefix = bootstrapTools;
      nativeLibc   = true;
      stdenv       = stage0.stdenv;
      libcxx       = bootstrapTools;
      libcxxabi    = bootstrapTools;
      shell        = "${bootstrapTools}/bin/bash";
      clang        = { name = "clang-9.9.9"; outPath = bootstrapTools; };
    } // { libc = bootstrapTools; };

    extraPreHook     = bootstrapPreHook;
    extraBuildInputs = [ bootstrapTools ];
    overrides        = pkgs: { binutils = bootstrapTools; };
  };

  stage2 = stageFun {
    inherit (stage1.stdenv) cc;
    extraPath        = [ stage1.pkgs.xz ];
    extraPreHook     = bootstrapPreHook;
    extraBuildInputs = [ bootstrapTools ];
    overrides        = pkgs: { binutils = stage1.pkgs.binutils; };
  };

  stage3 = with stage2; stageFun {
    # TODO: just make pkgs.clang do this right
    cc = import ../../build-support/clang-wrapper {
      inherit stdenv;
      nativeTools  = false;
      nativeLibc   = true;
      inherit (pkgs) libcxx libcxxabi coreutils;
      inherit (pkgs.llvmPackages) clang;
      binutils  = pkgs.darwin.cctools;
      shell     = "${pkgs.bash}/bin/bash";
    } // { libc = pkgs.darwin.libSystem; };

    extraPath        = [ pkgs.xz ];
    extraBuildInputs = [ pkgs.darwin.libSystem pkgs.darwin.corefoundation ];
    extraPreHook     = "export LD_DYLD_PATH=${pkgs.darwin.dyld}/lib/dyld";
    overrides = pkgs: { binutils = stage2.pkgs.binutils; };
  };

  stage4 = with stage3; import ../generic rec {
    inherit system config;

    preHook = ''
      ${commonPreHook}
      export LD_DYLD_PATH=${pkgs.darwin.dyld}/lib/dyld
    '';

    extraBuildInputs = [ pkgs.darwin.libSystem pkgs.darwin.corefoundation ];

    initialPath = import ../common-path.nix { inherit pkgs; };

    shell = "${pkgs.bash}/bin/bash";

    cc = import ../../build-support/clang-wrapper {
      inherit stdenv;
      nativeTools  = false;
      nativeLibc   = true;
      inherit (pkgs) libcxx libcxxabi coreutils;
      inherit (pkgs.llvmPackages) clang;
      binutils  = pkgs.darwin.cctools;
      shell     = "${pkgs.bash}/bin/bash";
    } // { libc = pkgs.darwin.libSystem; };

    inherit (stdenv) fetchurlBoot;

    extraAttrs = {
      inherit platform bootstrapTools;
      libc         = pkgs.darwin.libSystem;
      shellPackage = pkgs.bash;
    };

    overrides = pkgs: {
      clang = cc;
      inherit cc;
      inherit (stage3.pkgs)
        gzip bzip2 xz bash binutils coreutils diffutils findutils gawk
        glibc gnumake gnused gnutar gnugrep gnupatch patchelf
        attr acl paxctl zlib;
    };
  };

  stdenvDarwin = stage4;
}
