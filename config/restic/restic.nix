{ lib, config, pkgs, ... }:
with lib;
{

  options.localConfiguration.extraServices.restic = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    backups = mkOption {
        description = "restic options";
    };
  };

  config = let
    cfg = config.localConfiguration.extraServices.restic;
  in mkIf cfg.enable {
      services.restic.backups = cfg.backups;
    # restic.backups.pcpjam = {
    #   repository = "rclone:backup1:/backups/pcpjam";
    #   passwordFile = "/home/juanra/.config/restic.conf";
    #   paths = [ "/home/juanra" ];
    #   extraBackupArgs = [ "--exclude='Downloads tmp .env env2 env3 .cache node_modules logs .cache'" ];
    # };

  };

}  