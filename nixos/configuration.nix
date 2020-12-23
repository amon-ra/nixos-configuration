{ config, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./cachix.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''experimental-features = nix-command flakes'';
    trustedUsers = [ "root" "fortuneteller2k" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    autoOptimiseStore = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "mitigations=off"
      "acpi_backlight=vendor"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
    };
  };
 
  time.timeZone = "Asia/Manila";

  networking = {
    hostName = "superfluous";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      wlo1.useDHCP = true;
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services = {
    xserver = {
      enable = true;
      dpi = 96;
      displayManager = {
        gdm.enable = true;
        defaultSession = "none+xmonad";
      };
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          config = (import ./config/xmonad.nix);
        };
      };
      layout = "us";
      libinput.enable = true;
    };
    picom = {
      enable = true;
      experimentalBackends = true;
      backend = "glx";
      vSync = true;
    };
    chrony = {
      enable = true;
      servers = [
        "ntp.pagasa.dost.gov.ph"
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };
    tlp.enable = true;
    openssh.enable = true;
  };

  sound.enable = true;

  hardware = { 
    pulseaudio.enable = true;
    acpilight.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  security = {
    sudo.wheelNeedsPassword = false;
    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  users.users.fortuneteller2k = {
    isNormalUser = true;
    home = "/home/fortuneteller2k";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    coreutils
    git
    xdo 
    vim
    shotgun
    hacksaw
    xclip
    pcmanfm
    cmake
    unzip
    zip
    ripgrep
    fd
    nixfmt
    python3
    pypy3
    shellcheck
    gcc
    rustup
    rust-analyzer-unwrapped
    elixir
    nodejs
    nodePackages.typescript
    nodePackages.npm
    go
    gimp
    gnumake
    libtool
    xorg.xkill
    xorg.xdpyinfo
    xidlehook
    nitrogen
    ghc
    stack
    haskell-language-server
  ];

  programs = {
    slock.enable = true;
    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.slock}/bin/slock";
    };
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      promptInit = "eval $(starship init zsh)";
      interactiveShellInit = ''
        function nix() {
          if [[ "$1" == "develop" ]]; then
            command nix develop "$2" -c zsh
          else
            command nix "$@"
          fi
        }

        export TERM=xterm-256color
        export PATH=$PATH:$HOME/.config/emacs/bin
      '';
      shellAliases = {
        ls = "exa";
        la = "exa -la";
        l = "exa -l";
      };
    };
  };

  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  
  fonts = {
    fonts = with pkgs; [
      nerdfonts
      inter
      fantasque-sans-mono
      twemoji-color-font
    ];
    fontconfig = {
      enable = true;
      dpi = 96;
      defaultFonts = {
        serif = [ "Inter" ];
        sansSerif = [ "Inter" ];
        monospace = [ "FantasqueSansMono Nerd Font" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };

  system = {
    stateVersion = "20.09";
    autoUpgrade = {
      enable = true;
      flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
    };
  };
}
