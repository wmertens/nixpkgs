let
  pkgs = import <nixpkgs> {};
in with pkgs; {
  build = buildEnv {
    name = "standard-build";
    paths = [
      nix-exec
      gitFull
      subversion
      emacs24Macport
      # texLive
      ocaml
      coq_HEAD
      tmux
      expect
      lua
      luajit
      nginx
      apacheHttpd
      redis
      postgresql
      mysql55
      iperf
      watch
      weechat
    ];
    ignoreCollisions = true;
  };
}
