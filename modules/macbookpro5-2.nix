



{ config, pkgs, lib, ... }:

{
imports = [
    ./proaudio.nix
  ];

  # Boot properly
  boot.kernelParams = [ "nomodeset" ];

  # Wifi driver/firmware
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  nixpkgs.config = {
    permittedInsecurePackages = let
      broadcomSta = config.boot.kernelPackages.broadcom_sta;
    in [ broadcomSta.name ];
  };
  boot.blacklistedKernelModules = [ "b43" "ssb" "bcma" ];

  # Wifi enable
  #systemd.services.systemd-rfkill.enable = false;
  systemd.services.unblock-wifi = {
    description = "Unblock WiFi rfkill and enable NM radio";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.util-linux}/bin/rfkill unblock wlan"
        "${pkgs.networkmanager}/bin/nmcli radio wifi on"
      ];
    };
  };

  # CPU
  hardware.cpu.intel.updateMicrocode = true;
  #powerManagement.cpuFreqGovernor = "ondemand"; # or "powersave" if you want cooler/quieter

  # SSD optimizations
  nix.settings.auto-optimise-store = true;
  services.fstrim.enable = true;

  # Touchpad settings
  services.libinput.touchpad = {
    disableWhileTyping = true;
    naturalScrolling = true;
  };

}
