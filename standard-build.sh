#!/bin/sh -eu

# Mac OS is weird about its sandbox. The .sb file doesn't need to be executable, but it does need
# to be touched in a way that touch doesn't do, otherwise there's some weird caching mechanism that
# stops the OS from noticing the file changed below.
chmod +x ./pure.sb

build () {
  sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A "$@"
}

# This stuff should all work in the sandbox
build build ./pkgs/stdenv/darwin/make-bootstrap-tools.nix
build nix-exec
build gitFull
build subversion
build emacs24Macport
build texLive
build ocaml
build coq_HEAD
build tmux
build expect
build lua
build luajit

build nginx
build apacheHttpd

build redis
build postgresql
build mysql55

build iperf
build watch

sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A weechat

# Broken builds (for now)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A nodejs (wants CoreServices framework)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A openjdk (binary bootstrap references root)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A sbcl (binary bootstrap references root)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A isabelle
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A erlang (missing Carbon framework)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A swiProlog (tries to write to /etc)
