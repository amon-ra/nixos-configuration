# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ./desktop-environments
    ./extra-services
  ];

  # Local configuration options
  options.localConfiguration = with lib; {
    hostName = mkOption {
      type = types.str;
      default = "nixos";
    };
    grubDevice = mkOption {
      type = types.str;
    };
    version = mkOption {
      type = types.str;
      default = "20.09";
    };
    users = mkOption {
      type = types.listOf types.attrs;
    };
    displayManager = mkOption {
      type = types.enum [ "lightdm" "sddm" ];
      default = "lightdm";
    };
    desktopEnvironment = mkOption {
      type = types.enum [ "kde" "gnome" "nide" ];
      default = "kde";
    };
    allowUnfree = mkOption {
      type = types.bool;
      default = false;
    };
    autoupgrade = mkOption {
      type = types.bool;
      default = false;
    };    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
    extraKernelModules = mkOption {
      type = types.listOf types.str;
      default = [];
    };    
    nixpkgs = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    bootMode= mkOption {
      type = types.enum [ "bios" "uefi" ];
      default = "bios";
    };
    timezone = mkOption {
      type = types.nullOr types.str;
      default = "Europe/Helsinki";      
    };
  };

  config = let

      # extensions = (with pkgs.vscode-extensions; [
      #     bbenoist.Nix
      #     VisualStudioExptTeam.vscodeintellicode
      #     ms-python.python
      #     ms-python.vscode-pylance
      #     donjayamanne.python-extension-pack
      #     kevinrose.vsc-python-indent
      #     magicstack.magicpython
      #     njpwerner.autodocstring
      #     ms-azuretools.vscode-docker
      #     ms-vscode-remote.remote-ssh
      #     ritwickdey.liveserver
      #     ms-vsliveshare.vsliveshare
      #     ms-vsliveshare.vsliveshare-audio
      #     bycedric.vscode-expo
      #     vscoss.vscode-ansible
      #     hookyqr.beautify
      #     giladgray.theme-blueprint
      #     alefragnani.bookmarks
      #     deerawan.vscode-dash
      #     msjsdiag.debugger-for-chrome
      #     batisteo.vscode-django
      #     editorconfig.editorconfig
      #     dbaeumer.vscode-eslint
      #     eamodio.gitlens
      #     dchanco.vsc-invoke
      #     xabikos.javascriptsnippets
      #     wholroyd.jinja
      #     kiteco.kite
      #     emilast.logfilehighlighter
      #     jeffery9.odoo-snippets
      #     jigar-patel.odoosnippets
      #     sandcastle.vscode-open
      #     fabiospampinato.vscode-open-multiple-files
      #     ryu1kn.partial-diff
      #     felixfbecker.php-pack
      #     mechatroner.rainbow-csv
      #     eamodio.restore-editors
      #     emeraldwalk.runonsave
      #     wayou.vscode-todo-highlight
      #     gruntfuggly.todo-tree
      #     octref.vetur
      #     uctakeoff.vscode-counter
      #     yahya-gilany.vscode-pomodoro
      #     wakatime.vscode-wakatime
      #     johnbillion.vscode-wordpress-hooks
      #     wordpresstoolbox.wordpress-toolbox
      #     redhat.vscode-xml
      #     github.vscode-pull-request-github
      #     dbaeumer.jshint
      #     bajdzis.vscode-database
      # ]);
      # ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
      #   name = "remote-ssh-edit";
      #   publisher = "ms-vscode-remote";
      #   version = "0.47.2";
      #   sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      # }];
      # vscode-with-extensions = pkgs.vscode-with-extensions.override {
      #     vscodeExtensions = extensions;
      #   };

    localConfiguration = (import ./local-configuration.nix) {
      inherit pkgs;
      users = import ./users.nix;
    };

    cfg = config.localConfiguration;

  in {
      nix = {
        useSandbox = false;
        # See: https://github.com/nix-community/nix-direnv#usage
        extraOptions = ''
          keep-derivations = true
          keep-outputs = true
        '';
      } // lib.optionalAttrs (cfg.nixpkgs != null) {
        nixPath = [
          "nixpkgs=${cfg.nixpkgs}"
          "nixos-config=/etc/nixos/configuration.nix"
        ];
      };

      # This enables type checking
      localConfiguration = localConfiguration;

      # Use the GRUB 2 boot loader.
      boot = {

        kernelModules = [ "nf_conntrack_pptp" ]  ++ cfg.extraKernelModules;

        # BIOS systems
        loader.grub = lib.mkIf (cfg.bootMode == "bios") {
          enable = true;
          version = 2;
          device = cfg.grubDevice;
        };
        # UEFI systems
        loader.systemd-boot = lib.mkIf (cfg.bootMode == "uefi") {
          enable = true;
          editor = true;
        };

        loader.efi.canTouchEfiVariables = lib.mkIf (cfg.bootMode == "uefi") true;
        
        # Splash screen at boot time
        plymouth.enable = false;

        cleanTmpDir = true;

        supportedFilesystems = [ "zfs" ];
        zfs.forceImportAll = false;
        zfs.devNodes = "/dev/disk/by-partuuid";


      };

      # fileSystems = cfg.fileSystems;
      # boot.initrd.luks.devices = cfg.luksDevices;

      # Set your time zone.
      time.timeZone = cfg.timezone;

      i18n.consoleUseXkbConfig = true;
      
      # Manual upgrades
      system.autoUpgrade.enable = cfg.autoupgrade;

      # NOTE: This is something you should probably never change. It's not
      # really related to NixOS version. It just prevents some backwards
      # incompatible changes from happening. Grep nixpkgs for "stateVersion" to
      # see how it's used. Basically, when some default setting value is
      # modified, this version number is used to check whether you are using the
      # old or new default, so your system won't break if, for instance, a
      # database changes its default data directory.
      system.stateVersion = cfg.version;

      # Immutable users and groups
      users.mutableUsers = false;
      users.users = let
        getUserAttrs = userCfg: {
          name = userCfg.username;
          value = userCfg.user;
        };
      in builtins.listToAttrs (map getUserAttrs cfg.users);
      users.groups = let
        getGroupAttrs = userCfg: {
          name = userCfg.username;
          value = userCfg.group;
        };
      in builtins.listToAttrs (map getGroupAttrs cfg.users);

      # Networking
      networking = {
        hostName = cfg.hostName;
        networkmanager.enable = true;
        # firewall = {
        #   enable = false;
        #   # Enable PPTP VPN
        #   autoLoadConntrackHelpers = true;
        #   connectionTrackingModules = [ "pptp" ];
        #   #autoLoadConntrackHelpers = true;
        #   extraCommands = ''
        #     iptables -A INPUT -p 47 -j ACCEPT
        #     iptables -A OUTPUT -p 47 -j ACCEPT
        #   '';
        # };
      };

      # Hardware
      hardware = {
        pulseaudio.enable = true;
        sane = {
          enable = true;
          #extraBackends = [ pkgs.hplipWithPlugin ];
        };
        #opengl.enable = true;
        firmware = [
          pkgs.openelec-dvb-firmware
        ];
      };

      services = {
        # Printing
        printing = {
          enable = true;
          webInterface = true;
          drivers = with pkgs; [ gutenprint ];
        };
        avahi = {
          enable = true;
          nssmdns = true;
        };
        # Graphical environment (X server)
        xserver = {
          enable = true;
          displayManager."${cfg.displayManager}".enable = true;
          libinput = {
            enable = true; # or should this be used instead of synaptics??
          };
          synaptics = {
            enable = false;
            twoFingerScroll = true;
          };
        };
        # Automatic device mounting daemon
        devmon.enable = true;
      };

      # Fonts
      fonts = {
        # fontDir = {
        #   enable = true;
        # };
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
          #corefonts # Microsoft free fonts
          inconsolata # monospaced
          unifont # some international languages
          font-awesome-ttf
          freefont_ttf
          opensans-ttf
          liberation_ttf
          liberationsansnarrow
          ttf_bitstream_vera
          libertine
          ubuntu_font_family
          gentium
          # Good monospace fonts
          jetbrains-mono
          source-code-pro
        ];
      };

      security.acme = {
        email = "jaakko.luttinen@iki.fi";
        acceptTerms = true;
      };

      nixpkgs.config.allowUnfree = cfg.allowUnfree;

      # Add a udev rule to grant all users access to the Polar V800 USB device
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0da4", ATTRS{idProduct}=="0008", MODE="0666"
      '';

      programs.ssh.knownHosts = {
        kapsi = {
          hostNames = [ "kapsi.fi" ];
          publicKeyFile = ./pubkeys/kapsi.pub;
        };
      };

      environment.variables.EDITOR = "nvim";
      nixpkgs.overlays = [
        (self: super: {
          neovim = super.neovim.override {
            viAlias = true;
            vimAlias = true;
          };
        })
      ];      

      programs.zsh ={
        enable = true;
      };
      users.defaultUserShell = pkgs.zsh;
      
      # Fundamental core packages
      environment.systemPackages = with pkgs; [

        # Basic command line tools
        bash
        wget
        file
        gksu
        git
        hdf5
        zip
        unzip
        htop
        yle-dl
        youtube-dl
        nix-index
        dnsutils
        whois
        coreutils
        vbetool
        killall
        nethogs
        binutils
        lsof
        usbutils
        
        # Gamin: a file and directory monitoring system
        fam

        # Basic image manipulation and handling stuff
        imagemagick
        ghostscript

        # Simple PDF
        mupdf

        # Text editors
        neovim
        xclip  # system clipboard support for vim

        # VPN
        pptp
        openvpn

        # File format conversions
        pandoc
        pdf2svg

        # Screen brightness and temperature
        redshift

        # SSH filesystem
        sshfsFuse

        # Encryption key management
        gnupg

        # Yet another dotfile manager
        yadm
        gnupg1orig

        # Password hash generator
        mkpasswd
        openssl

        # Android
        jmtpfs
        gphoto2
        libmtp
        mtpfs

        nix-prefetch-git

        # Make NTFS filesystems (e.g., USB drives)
        ntfs3g

        # Encrypted USB sticks etc
        cryptsetup

        # GPG password entry from the terminal
        pinentry

        # GUI for sound control
        pavucontrol

        # Trash management from the command line
        trash-cli

        python3Packages.magic-wormhole

        skype

        # vscode-with-extensions

      ] ++ cfg.extraPackages;

      #programs.docker.enable = true;        
      
    }

  ;

}
