{ pkgs, ... }:
let
  fw-fancontrol = pkgs.writeShellApplication {
    name = "fw-fancontrol";
    text = builtins.readFile ./scripts/fw-fancontrol.sh;
    runtimeInputs = [
      pkgs.framework-tool
      pkgs.gawk
    ];
  };

  hdds = builtins.map builtins.toString [
    0
    1
    2
    3
    4
    5
    28
    29
    30
    31
  ];
  config = pkgs.writers.writeYAML "config.yaml" {
    dbPath = "/var/lib/fan2go/fan2go.db";
    tempSensorPollingRate = "10s";
    rpmPollingRate = "1s";
    fans = [
      {
        id = "hdd_fan";
        cmd = {
          setPwm = {
            exec = "${fw-fancontrol}/bin/fw-fancontrol";
            args = [
              "-f"
              "1"
              "set"
              "%pwm%"
            ];
          };
          getRpm = {
            exec = "${fw-fancontrol}/bin/fw-fancontrol";
            args = [
              "-f"
              "1"
              "get-rpm"
            ];
          };
        };
        neverStop = true;
        curve = "hdd_combined_curve";
        startPwm = 100;
        minPwm = 50;
        maxPwm = 255;
        controlAlgorithm.direct.maxPwmChangePerCycle = 10;
      }
    ];
    sensors = builtins.map (hdd: {
      id = "hdd_${hdd}";
      hwmon = {
        platform = "drivetemp-scsi-${hdd}-0";
        index = 1;
      };
    }) hdds;
    curves =
      (builtins.map (hdd: {
        id = "hdd_${hdd}_curve";
        linear = {
          sensor = "hdd_${hdd}";
          min = 35;
          max = 50;
        };
      }) hdds)
      ++ [
        {
          id = "hdd_combined_curve";
          function = {
            type = "maximum";
            curves = builtins.map (hdd: "hdd_${hdd}_curve") hdds;
          };
        }
      ];
  };
in
{
  environment.etc."fan2go/fan2go.yaml" = {
    user = "root";
    group = "root";
    source = config;
  };

  systemd.services.fan2go = {
    description = "NAS fancontrol";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      StateDirectory = "fan2go";
      ExecStart = "${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml";
      Restart = "always";
    };
  };
}
