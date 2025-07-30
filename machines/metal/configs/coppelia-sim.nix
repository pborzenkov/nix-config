{ pkgs, ... }:
let
  src =
    let
      version = "4_10_0_rev0";
    in
    pkgs.fetchzip {
      url = "https://downloads.coppeliarobotics.com/V${version}/CoppeliaSim_Edu_V${version}_Ubuntu24_04.tar.xz";
      hash = "sha256-sr+OBDsJz/k2boyJKTkD9OJJU/kUHO7quwU1Py294Dk=";
    };
  coppelia-sim = pkgs.writeShellApplication {
    name = "coppelia-sim";
    text = ''
      if ! distrobox list | grep -q coppelia-sim; then
        distrobox create \
          --name coppelia-sim \
          --image ubuntu:24.04 \
          --yes \
          --additional-packages "
            libxkbcommon-x11-0 libsodium23 libwebpmux3 libzvbi0t64
            libsnappy1v5 libaom3 libgsm1 libmp3lame0 libopenjp2-7 libopus0
            libshine3 libspeex1 libtheora0 libtwolame0 libvorbis0a libvorbisenc2
            libx265-199	 libxvidcore4 libva2 libgme0 libopenmpt0t64 libchromaprint1
            libbluray2 librabbitmq4 libssh-gcrypt-4 libva-drm2 libva-x11-2 libvdpau1
            ocl-icd-libopencl1 libsoxr0 python3-zmq python3-cbor2
          "
      fi
      exec distrobox enter coppelia-sim --clean-path -- ${src}/coppeliaSim.sh
    '';
    runtimeInputs = [ pkgs.distrobox ];
    runtimeEnv = {
      QT_QPA_PLATFORM = "xcb";
      QT_SCALE_FACTOR = "2";
    };
  };
in
{
  hm.home.packages = [ coppelia-sim ];
}
