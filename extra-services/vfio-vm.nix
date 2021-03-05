{ config, lib, pkgs, ... }:

let
  cfg = config.localConfiguration.extraServices.vfio-vm;
in

with lib;

{

  options = {
    services.vfio-vm.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configuration to enable VFIO hardware passthrough to libvirt VM.
      '';
    };

    services.vfio-vm.onShutDown = mkOption {
      type = types.str;
      default = "shutdown"; # avoid problems with suspended hardware state
      description = ''
        shutdown or suspend guests on host shutdown.
      '';
    };

    services.vfio-vm.pciIDs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        PCI IDs to bind to the vfio-pci driver.
      '';
    };

    services.vfio-vm.isolcpus = mkOption {
      type = types.listOf types.int;
      default = [];
      description = ''
        CPUs to isolate for usage by VM/Emulator only.
      '';
    };

    services.vfio-vm.hugePageSize = mkOption {
      type = types.str;
      default = "1G";
      example = "512M";
      description = ''
        Size of each hugepage to make available for the VM.
      '';
    };

    services.vfio-vm.hugePageCount = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Amount of hugepages to make available for the VM.
      '';
    };

    services.vfio-vm.inputDevices = mkOption { 
      type = types.listOf types.str;
      default = [];
      example = [ "/dev/input/by-id/kbd-event" "/dev/input/by-id/mouse-event" ];
      description = ''
        Input devices to add to the QEMU cgroup device ACL.
        This is needed to passthrough evdev events to the guest.
      '';
    };

    services.vfio-vm.extraQemuVerbatimConfig = mkOption {
      type = types.str;
      default = "";
      description = ''
        Additional lines appended to virtualisation.libvirtd.qemuVerbatimConfig.
      '';
    };

    services.vfio-vm.vmAddr = mkOption {
      type = types.str;
      default = "";
      description = ''
        IP Address of guest VM for integration of IP services.
      '';
    };

    services.vfio-vm.tunnelPulse = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Load pulseaudio module-tunnel-{source,sink}-new to send host audio
        to the soundcard of the guest. This way you can have the guest own
        your soundcard for latency sensitive things like games, but still hear
        audio from applications on the host.
      '';
    };

    services.vfio-vm.disableMitigations = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Disable security mitigations for spectre/meltdown.
      '';
    };

    services.vfio-vm.intelNested = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable nested virtualisation on intel cpus.
      '';
    };

    services.vfio-vm.kvmgt = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable intel gpu virtualisation.
      '';
    };

    services.vfio-vm.synergyKBM = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Connect to Synergy mouse/keyboard sharing server on guest.
      '';
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      onShutdown = cfg.onShutDown;
      qemuRunAsRoot = false;
      qemuVerbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null",
          "/dev/full",
          "/dev/zero",
          "/dev/random",
          "/dev/urandom",
          "/dev/ptmx",
          "/dev/kvm",
          "/dev/kqemu",
          "/dev/rtc",
          "/dev/hpet",
          ${concatStringsSep ",\n" (map (x: ''"${x}"'') cfg.inputDevices)}
        ]
        namespaces = []
      '' + cfg.extraQemuVerbatimConfig;
    };

    users.users.qemu-libvirtd.extraGroups = [ "input" ];

    boot.kernelParams = let
      hugePages = if cfg.hugePageCount == 0 then []
        else [
          "default_hugepagesz=${cfg.hugePageSize}"
          "hugepagesz=${cfg.hugePageSize}"
          "hugepages=${toString cfg.hugePageCount}"
        ];
      pcis = if cfg.pciIDs == [] then []
        else [
          "vfio-pci.ids=${concatStringsSep "," cfg.pciIDs}"
        ];
      isolcpus = if cfg.isolcpus == [] then []
        else [
          "isolcpus=${concatStringsSep "," (map toString cfg.isolcpus)}"
        ];
      nohz = if cfg.isolcpus == [] then []
        else [
          "no_hz_full=${concatStringsSep "," (map toString cfg.isolcpus)}"
        ];
      disableMitigations = if !cfg.disableMitigations then []
        else [
          "pti=off" "spectre_v2=off" "l1tf=off" "nospec_store_bypass_disable" "no_stf_barrier"
        ];
      nested = if !cfg.intelNested then []
        else [
          "kvm-intel.nested=1"
        ];
      kvmgt = if !cfg.kvmgt then []
        else [
          "i915.enable_gvt=1 kvm.ignore_msrs=1"
        ];
      in
      [ "intel_iommu=on" ] ++ hugePages ++ pcis ++ isolcpus ++
      nohz ++ disableMitigations ++ nested ++ kvmgt;

    environment.systemPackages = with pkgs; [
      virtmanager gnome3.dconf win-virtio win-spice
    ];

    boot.initrd.kernelModules = lib.mkBefore [
      "vfio_pci" "vfio" "vfio_iommu_type1"
      "vfio_virqfd" "kvmgt" "vfio-mdev"
    ];

    hardware.pulseaudio = mkIf cfg.tunnelPulse {
      enable = true;
      configFile = pkgs.writeText "default.pa" (fileContents "${pkgs.pulseaudio}/etc/pulse/default.pa" +
      ''

        load-module module-tunnel-sink-new server=${cfg.vmAddr} sink=output sink_name=vmspkr
        load-module module-tunnel-source-new server=${cfg.vmAddr} source=input source_name=vmmic
        update-sink-proplist vmspkr device.description=VM-Output
        update-source-proplist vmmic device.description=VM-Mic
      '');
    };

    services.synergy.client = mkIf cfg.synergyKBM {
      enable = true;
      serverAddress = cfg.vmAddr;
    };
  };
}
## USING:
  # extraServices.vfio-vm = {
  #   enable = true;
  #   pciIDs = [ "1002:67b0" "1002:aac8" "104c:8241"];
  #   isolcpus = [ 1 2 5 6 ]; # core 2&3 + corresponding hyperthreads
  #   hugePageSize = "1G";
  #   hugePageCount = 20;
  #   inputDevices = [
  #     "/dev/input/by-id/usb-Logitech_G403_Prodigy_Gaming_Mouse_1274375E3330-event-mouse"
  #     "/dev/input/by-id/usb-Corsair_Corsair_K65_RGB_Gaming_Keyboard_01031005AE3998A7534EC0CAF5001942-if01-event-kbd"
  #   ];
  #   tunnelPulse = true;
  #   vmAddr = "192.168.122.28";
  #   intelNested = true;
  #   synergyKBM = false;
  # };

## -------------------

# { pkgs, ... }:
# let
#   netboot = import (pkgs.path + "/nixos/lib/eval-config.nix") {
#       modules = [
#         (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
#         module
#       ];
#     };
#     module = {
#       # you will want to add options here to support your filesystem
#       # and also maybe ssh to let you in
#       boot.supportedFilesystems = [ "zfs" ];
#     };
# in {
#   boot.loader.grub.extraEntries = ''
#     menuentry "Nixos Installer" {
#       linux ($drive1)/rescue-kernel init=${netboot.config.system.build.toplevel}/init ${toString netboot.config.boot.kernelParams}
#       initrd ($drive1)/rescue-initrd
#     }
#   '';
#   boot.loader.grub.extraFiles = {
#     "rescue-kernel" = "${netboot.config.system.build.kernel}/bzImage";
#     "rescue-initrd" = "${netboot.config.system.build.netbootRamdisk}/initrd";
#   };
# }


## Docs: https://lantian.pub/en/article/modify-computer/laptop-intel-nvidia-optimus-passthrough.lantian/