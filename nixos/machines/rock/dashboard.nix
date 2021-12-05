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
    services = [
      {
        name = "Applications";
        items = [
          {
            name = "Miniflux";
            icon = "fas fa-rss";
            tag = "internal";
            url = "https://rss.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "PhotoPrism";
            icon = "fas fa-camera";
            tag = "external";
            url = "https://photos.borzenkov.net";
            target = "_blank";
          }
        ];
      }
      {
        name = "Infrastructure";
        items = [
          {
            name = "Grafana";
            icon = "fas fa-chart-area";
            tag = "internal";
            url = "https://grafana.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "Prometheus";
            icon = "fas fa-chart-line";
            tag = "internal";
            url = "https://prometheus.lab.borzenkov.net";
            target = "_blank";
          }
        ];
      }
    ];
  };
in
{
  webapps.apps.dashboard = {
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
}
