{ pkgs, ...}:
let
  nide = builtins.fetchTarball "https://github.com/jluttine/NiDE/archive/master.tar.gz";
in {
  imports = [
    "${nide}/nix/configuration.nix"
  ];
  config = {
    services.xserver.desktopManager.nide = {
      enable = true;
      installPackages = true;
    };
    nix.extraOptions = ''
      tarball-ttl = 0
    '';
  };
}