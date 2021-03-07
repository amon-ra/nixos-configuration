{ lib, config, ... }:
with lib;
{

  options.localConfiguration.extraServices.sshd = mkOption {
    type = types.bool;
    default = false;
  };

  config = let
    cfg = config.localConfiguration.extraServices;
  in mkIf cfg.sshd {

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      ports = [22];
      passwordAuthentication = true;
    };
    networking.firewall.enable = true;
    networking.firewall.allowPing = true;
    networking.firewall.allowedTCPPorts = [ 10022 ];
    programs.mosh = {
      enable = true;
    };

  };

}
