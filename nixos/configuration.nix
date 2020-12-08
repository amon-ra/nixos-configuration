# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # Allow nonfree software
  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    autoOptimiseStore = true;
  };

  # Use the grub EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "mitigations=off"
      "acpi_backlight=vendor"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        gfxmodeEfi = "1366x768";
      };
    };
  };
 
  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "nixos"; # Set your hostname
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    networkmanager = {
      enable = true; # Enable wireless with NetworkManager
      dns = "none";
    };
    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      wlo1.useDHCP = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services = {
    xserver = {
      # Enable selected window managers.
      enable = true;
      displayManager = {
        gdm.enable = true;
        defaultSession = "none+xmonad";
      };
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
        };
      };
      # Configure keymap in X11
      layout = "us";
      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
    };
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      opacityRules = [
        "97:class_g = 'tabbed' && focused"
        "89:class_g = 'tabbed' && !focused"
        "0:_NET_WM_STATE@[0]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[1]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[2]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[3]:32a *= '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[4]:32a *= '_NET_WM_STATE_HIDDEN'"
      ];      
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
    openssh.enable = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware = { 
    pulseaudio.enable = true; # Use pulseaudio for sound
    acpilight.enable = true; # Backlight control
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  # sudo needs no password
  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fortuneteller2k = {
    isNormalUser = true;
    home = "/home/fortuneteller2k";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    coreutils
    git
    xdo 
    vim
    lxappearance
    shotgun
    hacksaw
    xclip
    pcmanfm
    cmake
    unzip
    ripgrep
    fd
    nixfmt
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
    xidlehook
    xss-lock
    nitrogen
  ];

  programs = {
    slock.enable = true; # screen locker
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      interactiveShellInit = ''. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"'';
      promptInit = "eval $(starship init zsh)";
      shellAliases = {
        ls = "exa";
        la = "exa -la";
        l = "exa -l";
      };
    };
  };

  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  
  # Font packages and configuration
  fonts = {
    fonts = with pkgs; [
      nerdfonts
      inter
      fantasque-sans-mono
      noto-fonts-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Inter" ];
        sansSerif = [ "Inter" ];
        monospace = [ "FantasqueSansMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "20.09"; # Did you read the comment?
    autoUpgrade.enable = true;
  };
}