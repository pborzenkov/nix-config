{ config, pkgs, ... }:

let
  rendersvg = pkgs.runCommandNoCC "rendersvg" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';

  themeName = "base16";
  gtkTheme = pkgs.stdenv.mkDerivation rec {
    name = "generated-gtk-theme-${themeName}";
    src = pkgs.fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "76cac96ca7fe45dc9e5b9822b0fbb5f4cad47984";
      sha256 = "sha256-0eCAfm/MWXv6BbCl2vbVbvgv8DiUH09TAUhoKq7Ow0k=";
      fetchSubmodules = true;
    };
    buildInputs = with pkgs; [
      sassc
      bc
      which
      rendersvg
      meson
      ninja
      nodePackages.sass
      gtk4.dev
      optipng
    ];

    phases = [ "unpackPhase" "installPhase" ];
    installPhase = with config.scheme; ''
      HOME=/build
      chmod 777 -R .
      patchShebangs .
      mkdir -p $out/share/themes
      mkdir bin
      sed -e 's/handle-horz-.*//' -e 's/handle-vert-.*//' -i ./src/gtk-2.0/assets.txt
      cat > /build/gtk-colors << EOF
        BTN_BG=${base02}
        BTN_FG=${base06}
        FG=${base05}
        BG=${base00}
        HDR_BTN_BG=${base01}
        HDR_BTN_FG=${base05}
        ACCENT_BG=${base0B}
        ACCENT_FG=${base00}
        HDR_FG=${base05}
        HDR_BG=${base02}
        MATERIA_SURFACE=${base02}
        MATERIA_VIEW=${base01}
        MENU_BG=${base02}
        MENU_FG=${base06}
        SEL_BG=${base0D}
        SEL_FG=${base0E}
        TXT_BG=${base02}
        TXT_FG=${base06}
        WM_BORDER_FOCUS=${base05}
        WM_BORDER_UNFOCUS=${base03}
        UNITY_DEFAULT_LAUNCHER_STYLE=False
        NAME=${themeName}
        MATERIA_STYLE_COMPACT=True
      EOF
      echo "Changing colours:"
      ./change_color.sh -o ${themeName} /build/gtk-colors -i False -t "$out/share/themes"
      chmod 555 -R .
    '';
  };
in
{
  gtk = {
    enable = true;
    theme = {
      name = themeName;
      package = gtkTheme;
    };
  };

  xsession.pointerCursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 24;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "capitaine-cursors";
      cursor-size = 24;
    };
  };
}
