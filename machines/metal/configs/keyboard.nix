{pkgs, ...}: {
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "keychron-k7";
      text = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0270", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-keychron-k7.rules";
    })
  ];
}
