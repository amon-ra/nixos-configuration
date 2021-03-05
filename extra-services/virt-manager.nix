{ lib, config, pkgs, ... }:
with lib;
let 
  nmScript = pkgs.writeScriptBin "scriptName" ''
    #!${pkgs.stdenv.shell}
    …
  '';   
in {
  options.localConfiguration.extraServices.virt-manager = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf config.localConfiguration.extraServices.virt-manager.enable {
    # Port for hosting multiplayer games
    # networking.firewall.allowedTCPPorts = [
    #   26000 # xonotic
    #   2757 2759 # supertuxkart
    #   4243 # stuntrally
    # ];
    # networking.firewall.allowedUDPPorts = [
    #   26000 # xonotic
    #   2757 2759 # supertuxkart
    #   4243 # stuntrally
    # ];
    #networking.firewall.allowedUDPPorts = [ 26000 ];
    boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
    #boot.extraModprobeConfig = "options kvm_intel nested=1";
    networking.networkmanager.enable = true;
    # environment.etc."NetworkManager/system-connections/my-network.nmconnection" = {
    #   mode = "0600";
    #   source = ./files/my-network.nmconnection;
    # };    
    environment.etc."NetworkManager/dispatcher.d/01_bridge.sh" = {
      mode = "0700";
      source = ../files/01_bridge.sh;
    };    
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      bash 
      dnsmasq
      virt-manager
      # nmScript
    ];
    config.localConfiguration.users = (import ../tools/add-group.nix) config.localConfiguration.users [ "libvirtd" ] ;
  };
}
