{ lib, config, pkgs, ... }:
with lib;
{

  options.localConfiguration.extraServices.compton = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = let
    cfg = config.localConfiguration.extraServices.compton;
  in mkIf cfg.enable {

    services.compton = {
        enable = true;
        shadow = false;
        inactiveOpacity = "0.85";
        menuOpacity = "1.0";
        fade = true;
        fadeDelta = 3;
    };

  };

}  