# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "acpi_call" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-amd" "amdgpu" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        # "vm.overcommit_memory" = 1;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 500;
    };
    # kernelParams = [
    #   "transparent_hugepage=never"
    # ];    
  };
  #boot.loader.grub.copyKernels = true;
  # https://bugzilla.kernel.org/show_bug.cgi?id=110941
  #boot.kernelParams = [ "intel_pstate=no_hwp" ];
  #boot.kernelParams = [ "amd_iommu=pt" "ivrs_ioapic[32]=00:14.0" "iommu=soft" ];                                                                                                                                   
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportAll = false;
  boot.zfs.devNodes = "/dev/disk/by-partuuid";
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
    monthly = 1;  # keep only one monthly snapshot (instead of twelve)
  };

  services.tlp.enable = lib.mkDefault true;
  services.fstrim.enable = lib.mkDefault true;
  networking.hostId = "10faa34b";

  fileSystems."/" =
    { device = "rpool/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

  #boot.initrd.luks.devices."luks-nixos-root".device = "/dev/disk/by-uuid/a7561bd1-f3ef-4f4d-ab3b-69121e64689f";

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { 
      device = "rpool/home";
      fsType = "zfs";
    };

  # boot.initrd.luks.devices."luks-nixos-var".device = "/dev/disk/by-uuid/54c4bc98-ac8c-43e1-9c98-1889ff858dfc";
  # luks-nixos-var contains an LVM so it needs to be opened after LVM has been
  # activated
  # boot.initrd.luks.devices."luks-nixos-var".preLVM = false;

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

}
