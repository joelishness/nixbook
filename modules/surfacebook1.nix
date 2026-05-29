



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
