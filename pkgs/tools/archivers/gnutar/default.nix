{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "gnutar-${version}";
  version = "1.27.1";

  src = fetchurl {
    url = "mirror://gnu/tar/tar-${version}.tar.bz2";
    sha256 = "1iip0fk0wqhxb0jcwphz43r4fxkx1y7mznnhmlvr618jhp7b63wv";
  };

  configureFlags = if stdenv.isDarwin then [
    "ac_cv_func_fchmodat=no"
    "ac_cv_func_fchownat=no"
    "ac_cv_func_fstatat=no"
    "ac_cv_func_mkdirat=no"
    "ac_cv_func_openat=no"
    "ac_cv_func_unlinkat=no"
    "ac_cv_func_faccessat=no"
    "ac_cv_func_linkat=no"
    "ac_cv_func_readlinkat=no"
    "ac_cv_func_renameat=no"
    "ac_cv_func_symlinkat=no"
  ] else [];

  # May have some issues with root compilation because the bootstrap tool
  # cannot be used as a login shell for now.
  FORCE_UNSAFE_CONFIGURE = stdenv.lib.optionalString (stdenv.system == "armv7l-linux" || stdenv.isSunOS) "1";

  meta = {
    homepage = http://www.gnu.org/software/tar/;
    description = "GNU implementation of the `tar' archiver";

    longDescription = ''
      The Tar program provides the ability to create tar archives, as
      well as various other kinds of manipulation.  For example, you
      can use Tar on previously created archives to extract files, to
      store additional files, or to update or list files which were
      already stored.

      Initially, tar archives were used to store files conveniently on
      magnetic tape.  The name "Tar" comes from this use; it stands
      for tape archiver.  Despite the utility's name, Tar can direct
      its output to available devices, files, or other programs (using
      pipes), it can even access remote devices or files (as
      archives).
    '';

    license = stdenv.lib.licenses.gpl3Plus;

    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
