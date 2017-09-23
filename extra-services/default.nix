# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      #./nginx
      ./sshd.nix
      ./emacs.nix
      ./tuhlaajapojat.nix
      ./mythbackend.nix
      ./mythfrontend.nix
      ./salmon.nix
      ./storj.nix
      ./tv.nix
      ./ddclient.nix
      ./printserver.nix
      ./adb.nix
      ./pilvi.nix
      # Generic Nextcloud webapp definition
      ./nextcloud
    ];
}
