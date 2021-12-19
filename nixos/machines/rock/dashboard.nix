{ config, lib, pkgs, ... }:

let
  homer = pkgs.stdenv.mkDerivation rec {
    pname = "homer";
    version = "21.09.2";

    src = pkgs.fetchurl {
      urls = [
        "https://github.com/bastienwirtz/${pname}/releases/download/v${version}/${pname}.zip"
      ];
      sha256 = "sha256-NHvH3IW05O1YvPp0KOUU0ajZsuh7BMgqUTJvMwbc+qY=";
    };
    nativeBuildInputs = [ pkgs.unzip ];

    dontInstall = true;
    sourceRoot = ".";
    unpackCmd = "${pkgs.unzip}/bin/unzip -d $out $curSrc";
  };

  homeConfig = {
    title = "Dashboard";
    header = false;
    footer = false;
    connectivityCheck = false;
    colums = "auto";
    services = config.lib.webapps.homerServices;
  };
in
{
  webapps = {
    dashboardCategories = [
      { name = "Applications"; tag = "app"; }
      { name = "Infrastructure"; tag = "infra"; }
    ];
    apps.dashboard = {
      subDomain = "dashboard.lab";
      locations = {
        "/" = {
          custom = {
            root = homer;
          };
        };
        "=/assets/config.yml" = {
          custom = {
            alias = pkgs.writeText "homerConfig.yml" (builtins.toJSON homeConfig);
          };
        };
      };
    };
  };
}