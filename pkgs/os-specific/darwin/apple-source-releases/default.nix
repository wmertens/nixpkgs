{ stdenv, fetchurl, pkgs }:

let
  fetchapplesource = { name, version, sha256 }: fetchurl {
    url = "http://www.opensource.apple.com/tarballs/${name}/${name}-${version}.tar.gz";
    inherit sha256;
  };

  callPackage = pkgs.newScope (packages // pkgs.darwin // { inherit fetchapplesource; });

  packages = {
    adv_cmds        = callPackage ./adv_cmds {};
    architecture    = callPackage ./architecture {};
    bootstrap_cmds  = callPackage ./bootstrap_cmds {};
    CarbonHeaders   = callPackage ./CarbonHeaders {};
    CF              = callPackage ./CF {};
    CommonCrypto    = callPackage ./CommonCrypto {};
    configd         = callPackage ./configd {};
    copyfile        = callPackage ./copyfile {};
    CoreOSMakefiles = callPackage ./CoreOSMakefiles {};
    Csu             = callPackage ./Csu {};
    dtrace          = callPackage ./dtrace {};
    dyld            = callPackage ./dyld {};
    eap8021x        = callPackage ./eap8021x {};
    IOKit           = callPackage ./IOKit {};
    launchd         = callPackage ./launchd {};
    libauto         = callPackage ./libauto {};
    Libc            = callPackage ./Libc {};
    Libc_old        = callPackage ./Libc/825_40_1.nix {};
    libclosure      = callPackage ./libclosure {};
    libdispatch     = callPackage ./libdispatch {};
    libiconv        = callPackage ./libiconv {};
    Libinfo         = callPackage ./Libinfo {};
    Libm            = callPackage ./Libm {};
    Libnotify       = callPackage ./Libnotify {};
    libpthread      = callPackage ./libpthread {};
    libresolv       = callPackage ./libresolv {};
    Libsystem       = callPackage ./Libsystem {};
    libunwind       = callPackage ./libunwind {};
    mDNSResponder   = callPackage ./mDNSResponder {};
    objc4           = callPackage ./objc4 {};
    objc4_pure      = callPackage ./objc4/pure.nix {};
    ppp             = callPackage ./ppp {};
    removefile      = callPackage ./removefile {};
    Security        = callPackage ./Security {};
    xnu             = callPackage ./xnu {};
  };
in packages
