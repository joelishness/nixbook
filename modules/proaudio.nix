



{ config, pkgs, lib, ... }:

{
  # Add user to audio group
  users.users.kyle.extraGroups = [ "audio" ];

  # Audio optimizations
  # Max CPU speed, no scaling
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Realtime priority for audio groups
  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio"; type = "hard"; value = 95; }
    { domain = "@audio"; item = "rtprio"; type = "soft"; value = 80; }
    { domain = "@audio"; item = "memlock"; type = "hard"; value = "unlimited"; }
    { domain = "@audio"; item = "memlock"; type = "soft"; value = "unlimited"; }
    { domain = "@audio"; item = "nice"; type = "hard"; value = -10; }
    { domain = "@audio"; item = "nice"; type = "soft"; value = -10; }
  ];

  # Pipewire + JACK for Ardour
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Disable PulseAudio conflict
  services.pulseaudio.enable = false;

  # Install audio tools
  environment.systemPackages = with pkgs; [
    # Ardour DAW
    ardour

    # JACK tools
    qjackctl # GUI control
    jack2    # Full JACK server
  ];

}
