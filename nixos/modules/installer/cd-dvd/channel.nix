# Provide an initial copy of the NixOS channel so that the user
# doesn't need to run "nix-channel --update" first.

{ config, lib, pkgs, ... }:

with lib;

let

  statics = config.nixpkgs.config.statics;

  # We need a copy of the Nix expressions for Nixpkgs and NixOS on the
  # CD.  These are installed into the "nixos" channel of the root
  # user, as expected by nixos-rebuild/nixos-install.
  channelSources = pkgs.runCommand "nixos-${config.system.nixosVersion}"
    { expr = readFile ../../../lib/channel-expr.nix; }
    ''
      mkdir -p $out/nixos
      cp -prd ${pkgs.path} $out/nixos/nixpkgs
      ln -s nixpkgs/nixos $out/nixos/nixos
      chmod -R u+w $out/nixos
      rm -rf $out/nixos/nixpkgs/.git
      echo -n ${config.system.nixosVersion} > $out/nixos/nixpkgs/.version
      echo -n "" > $out/nixos/nixpkgs/.version-suffix
      echo "$expr" > $out/nixos/default.nix
    '';

in

{
  # Provide the NixOS/Nixpkgs sources in /etc/nixos.  This is required
  # for nixos-install.
  boot.postBootCommands = mkAfter
    ''
      if ! [ -e ${statics.nixos-var-lib-dir}/did-channel-init ]; then
        echo "unpacking the NixOS/Nixpkgs sources..."
        mkdir -p ${statics.nix-profiles-dir}/per-user/root
        ${config.nix.package}/bin/nix-env -p ${statics.nix-profiles-dir}/per-user/root/channels \
          -i ${channelSources} --quiet --option use-substitutes false
        mkdir -m 0700 -p /root/.nix-defexpr
        ln -s ${statics.nix-profiles-dir}/per-user/root/channels /root/.nix-defexpr/channels
        mkdir -m 0755 -p ${statics.nixos-var-lib-dir}
        touch ${statics.nixos-var-lib-dir}/did-channel-init
      fi
    '';
}
