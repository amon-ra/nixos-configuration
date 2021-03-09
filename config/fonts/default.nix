{ config, pkgs, ... }:

{ 
  console.font = "lat9w-16";
  # consoleKeyMap = "colemak/en-latin9";

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      unifont
      ubuntu_font_family
      noto-fonts
      symbola
      nerdfonts
      xorg.fontbh100dpi

    ];
    # fontconfig = {
    #   enable = true;
    #   dpi = 96;
    #   defaultFonts = {
    #     serif = [ "Sarasa Gothic J" ];
    #     sansSerif = [ "Sarasa Gothic J" ];
    #     monospace = [
    #       "Iosevka FT"
    #       "Iosevka Nerd Font"
    #       "Sarasa Mono J"
    #     ];
    #     emoji = [ "Twitter Color Emoji" ];
    #   };
    # };    
  };
  
}