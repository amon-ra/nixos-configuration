{ pkgs, lib, ... }:

let dunstrc = builtins.toFile "dunstrc" (pkgs.lib.readFile ./config/dunstrc);
    background-image = pkgs.fetchurl {
      url = "http://orig01.deviantart.net/1810/f/2012/116/a/4/tranquility_by_andreewallin-d4xjtd0.jpg";
      sha256 = "17jcvy268aqcix7hb8acn9m9x7dh8ymb07w4f7s9apcklimz63bq";
    };
    solarized-theme = pkgs.fetchFromGitHub {
      owner = "anderspapitto";
      repo = "nixos-solarized-slim-theme";
      rev = "2822b7cb7074cf9aa36afa9b5cabd54105b3306c";
      sha256 = "0jp7qq02ly9wiqbgh5yamwd31ah1bbybida7mn1g6qpdijajf247";
    };
in {
  imports = [ ./rofi.nix ./polybar.nix ];
  environment = {
    etc = {
      "dunst/dunstrc"             .source = ./etc/dunstrc;
      "i3/config"                 .source = ./etc/i3;
      "i3/status"                 .source = ./etc/i3status;
      "i3/status-netns"           .source = ./etc/i3status-netns;
      # "X11/xresources"            .source = ./etc/xresources;
    };
    systemPackages = with pkgs; [ dzen2 gnupg ];
  };  
  services.xserver = {
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      
      configFile = "/etc/i3/config";

      extraPackages = [ "i3lock" "i3status" ];
    };
    synaptics = {
        enable = true;
        tapButtons = false;
        twoFingerScroll = true;
      };
  };

  # services.polybar = {
  #     enable = true;
  #     script = "polybar -l=trace main &";
  #     config = (import ./polybar.nix { inherit pkgs theme; });
  #   };

  systemd.services = {
    # compton = simpleXService "compton"
    #   "lightweight compositing manager"
    #   "${pkgs.compton}/bin/compton -cCG --config /etc/compton/noninverted"
    #   ;
    # compton-night =
    #   let base-service = simpleXService "compton-night"
    #         "lightweight compositing manager (night mode)"
    #         "${pkgs.compton}/bin/compton -cCG --config /etc/compton/inverted"
    #         ;
    #   in base-service // {
    #       conflicts = [ "compton.service" ];
    #       wantedBy = [ ];
    #   };
    picom = {
      enable = true;
      experimentalBackends = true;
      refreshRate = 60;
      backend = "glx";
      vSync = true;
      fade = true;
      fadeDelta = 3;
      settings = {
        blur = {
          method = "dual_kawase";
          strength = 5;
          background = false;
          background-frame = false;
          background-fixed = false;
        };
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
      };
    };    
    dunst = simpleXService "dunst"
      "Lightweight libnotify server"
      "exec ${pkgs.dunst}/bin/dunst -config /etc/dunst/dunstrc"
      ;
    feh = simpleXService "feh"
      "Set background"
      ''
        ${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${background-image}
        exec sleep infinity
      ''
      ;
    xbanish = simpleXService "xbanish"
      "xbanish hides the mouse pointer"
      "exec ${pkgs.xbanish}/bin/xbanish"
      ;
    clipit = simpleXService "clipit"
      "clipboard manager"
      "exec ${pkgs.clipit}/bin/clipit"
      ;
    # xrdb = simpleXService "xrdb"
    #   "set X resources"
    #   ''
    #     ${pkgs.xorg.xrdb}/bin/xrdb /etc/X11/xresources
    #     exec sleep infinity
    #   '';
  };  
}
