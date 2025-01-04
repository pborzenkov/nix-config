{pkgs, ...}: {
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "keychron-k7";
      text = ''
        # Keychron K7 Pro
        KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0270", TAG+="uaccess"
        # Keychron K7 Max
        KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0a70", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-keychron-k7.rules";
    })
  ];
}
