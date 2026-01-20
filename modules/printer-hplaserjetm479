



{ pkgs, pkgs-stable, ... }:

{

# https://wiki.nixos.org/wiki/Printing
# Regular CUPS UI may not be able to add HP printers with proprietary drivers. Use:
#NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup'

  services.printing = {
    enable = true;
    drivers = [
      pkgs.hplipWithPlugin
      pkgs.cups-filters
      pkgs.ghostscript
      pkgs.foomatic-filters
      pkgs.gutenprint
    ];
    extraConf = ''
      DefaultPStoRaster True
    '';
  };

  environment.systemPackages = with pkgs; [
    poppler-utils  # For PDF processing
  ];

  # Autodiscovery of IPP Everywhere network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
