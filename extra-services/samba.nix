{ lib, config, ... }:
with lib;
{

  options.localConfiguration.extraServices.samba = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      type = types.str;
      default = "WORKGROUP";
    };
    user = mkOption {
      type = types.str;
    };
  };

  config = let
    cfg = config.localConfiguration.extraServices;
  in mkIf cfg.samba {

        services.samba = {
          enable = true;
          securityType = "user";
          extraConfig = ''
          workgroup = ${cfg.samba.domain}
          server string = smbnix
          server role = standalone server
          ;netbios name = smbnix
          ;security = user
          ;#use sendfile = yes
          ;#max protocol = smb2
          ;"hosts allow" = 192.168.0 localhost
          ;"hosts deny" = 0.0.0.0/0
          ;"guest account" = nobody
          ;"map to guest" = bad user
          '';
          shares = {
            private = {
              comment = "nixos shared";
              path = "/home/${cfg.samba.user}";
              ";browseable" = "yes";
              ";valid users" = "NOTUSED";
              public = "no";
              writable = "yes";
              printable = "no";
              ";read only" = "no";
              ";guest ok" = "no";
              "create mask" = "0765";
              ";directory mask" = "0755";
              "force user" = "${cfg.samba.user}";
              "force group" = "${cfg.samba.user}";
            };
          };
        };


        networking.firewall.enable = true;
        networking.firewall.allowPing = true;
        networking.firewall.allowedTCPPorts = [ 445 139 ];
        networking.firewall.allowedUDPPorts = [ 137 138 ];

  };

}

