{pkgs, ...}: {
  boot.binfmt.registrations = {
    DOSWin = {
      interpreter = "${pkgs.wineWowPackages.waylandFull}/bin/wine64";
      magicOrExtension = "MZ";
      recognitionType = "magic";
    };
  };
  environment.systemPackages = [
    pkgs.wineWowPackages.waylandFull
    pkgs.winetricks
  ];
}
