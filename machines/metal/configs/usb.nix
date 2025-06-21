{ pkgs, ... }:
{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "usb-uaccess";
      text = ''
        SUBSYSTEM=="usb", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-usb-uaccess.rules";
    })
  ];
}
