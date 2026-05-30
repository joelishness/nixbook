



{ config, pkgs, lib, ... }:

{
imports = [
    # Jill's laptop hardware config. First need to run commands to add channel:
    #sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
    #sudo nix-channel --update
    <nixos-hardware/microsoft/surface/common>

  ];

  # Touchpad settings
  services.libinput.touchpad = {
    disableWhileTyping = true;
    naturalScrolling = true;
  };

  # Webcam
  # 1. Enable linux-firmware, which includes the required ipu3-fw.bin
  hardware.enableRedistributableFirmware = true;

  # 2. Add jill to the video group
  users.users.jill.extraGroups = [ "networkmanager" "wheel" "video" ];

  # 3. Install libcamera (userspace IPU3 pipeline + IPA modules)
  environment.systemPackages = with pkgs; [
    libcamera
    v4l-utils   # handy for testing with v4l2-ctl --list-devices
  ];

  # 4. Load the camera sensor drivers
  boot.kernelModules = [ "ov5693" "ov8865" ];

  # Check after rebuild and reboot
  #cam --list          # should show front and rear cameras

  # Make kernel compile faster
  nix.settings = {
    cores = 4;      # use all hyperthreads for the kernel build
    max-jobs = 1;   # one job at a time avoids OOM on 8 GB
  };
  
  # Prefer USB network dongle over internal card
  # 1. Permanent Naming via Udev
  # Matches the hardware 'permaddr' to assign the name 'wlan-usb'
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="5c:62:8b:11:28:b4", NAME="wlan-usb"
  '';

  # 2. Declare Interface-Specific Priorities
  # This applies to ANY SSID connected on these specific interfaces.
  networking.networkmanager.connectionConfig = {
    # Default metric for any connection not specified below
    "ipv4.route-metric" = 100; 
  };

  # 3. This tells NetworkManager: "If the device is wlan-usb, use metric 50"
  environment.etc."NetworkManager/conf.d/99-interface-priority.conf".text = ''
    [connection-10-usb]
    match-device=interface-name:wlan-usb
    ipv4.route-metric=50
    ipv6.route-metric=50

    [connection-20-internal]
    match-device=interface-name:wlp3s0
    ipv4.route-metric=100
    ipv6.route-metric=100
  '';

  # Check after reboot
  #nmcli device status
  #ip route | grep default

}
