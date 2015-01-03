#!/bin/sh -eu
chmod +x ./pure.sb
sandbox-exec -f ./pure.sb nix-build --option use-binary-caches false --cores 4 -A build ./pkgs/stdenv/darwin/make-bootstrap-tools.nix
sandbox-exec -f ./pure.sb nix-build --option use-binary-caches false --cores 4 -A nix-exec
sandbox-exec -f ./pure.sb nix-build --option use-binary-caches false --cores 4 -A gitFull
sandbox-exec -f ./pure.sb nix-build --option use-binary-caches false --cores 4 -A emacs24Macport
