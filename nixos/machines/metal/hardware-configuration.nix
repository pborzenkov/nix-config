{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ff2a425b-aca6-4cdf-b4f9-0c05f635213e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D33B-32E5";
    fsType = "vfat";
  };

  fileSystems."/mnt/dump" = {
    device = "/dev/disk/by-uuid/0a8ceb2c-4561-40db-9f09-0fd4c3e15f32";
    fsType = "ext4";
  };

  fileSystems."/storage" = {
    device = "helios64.lab.borzenkov.net:/storage";
    fsType = "nfs";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/f052d296-83e6-46be-a878-5a0ec5b83873";}];

  hardware.enableRedistributableFirmware = true;
}
