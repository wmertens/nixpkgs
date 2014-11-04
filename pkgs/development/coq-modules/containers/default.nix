{stdenv, fetchurl, coq}:

stdenv.mkDerivation {

  name = "coq-containers-${coq.coq-version}";

  src = fetchurl {
    url = http://www.lix.polytechnique.fr/coq/pylons/contribs/files/Containers/v8.4/Containers.tar.gz;
    sha256 = "1rk7xvplg8x40bs42w4ar196zk8fp9kaddsbzsgjmdkmdgw5zfqx";
  };

  buildInputs = [ coq.ocaml coq.camlp5 ];
  propagatedBuildInputs = [ coq ];

  installFlags = "COQLIB=$(out)/lib/coq/${coq.coq-version}/";

  meta = with stdenv.lib; {
    homepage = http://coq.inria.fr/pylons/pylons/contribs/view/Containers/v8.4;
    description = "A typeclass-based Coq library of finite sets/maps";
    maintainers = with maintainers; [ vbgl jwiegley ];
    platforms = coq.meta.platforms;
  };

}
