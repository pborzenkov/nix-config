{ config, pkgs, ... }:

{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {
          targets = [
            "helios64.lab.borzenkov.net:9100"
          ];
        }
      ];
    }
  ];
}
