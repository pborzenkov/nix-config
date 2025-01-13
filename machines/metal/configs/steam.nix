{...}: {
  programs.gamescope = {
    enable = true;
    args = [
      "-W"
      "3840"
      "-H"
      "2160"
      "-w"
      "3840"
      "-h"
      "2160"
      "-r"
      "60"
      "--rt"
      "--hdr-enabled"
      "--backend"
      "wayland"
      "--steam"
      "--fullscreen"
    ];
    env = {
      GDK_SCALE = "2";
    };
  };
}
