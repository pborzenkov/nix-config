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
  get-hdd-temp = pkgs.writeShellApplication {
    name = "get-hdd-temp";
    text = builtins.readFile ./scripts/get-hdd-temp.sh;
    runtimeInputs = [
      pkgs.promql-cli
      pkgs.jq
    ];
  };

  hdds = [
    "S75CNX0Y922701H"
    "S75CNX0Y904668P"
    "WV70A7RC"
    "ZRT2K7V9"
    "ZRT2AK20"
    "WV70A749"
    "ZRT2HQQK"
    "WV70A1HV"
    "WRS0YSFE"
    "WV70A7LF"
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
      {
        id = "case_fan";
        cmd = {
          setPwm = {
            exec = "${fw-fancontrol}/bin/fw-fancontrol";
            args = [
              "-f"
              "2"
              "set"
              "%pwm%"
            ];
          };
          getRpm = {
            exec = "${fw-fancontrol}/bin/fw-fancontrol";
            args = [
              "-f"
              "2"
              "get-rpm"
            ];
          };
        };
        neverStop = true;
        curve = "cpu_curve";
        startPwm = 100;
        minPwm = 50;
        maxPwm = 255;
        controlAlgorithm.direct.maxPwmChangePerCycle = 10;
      }
    ];
    sensors = [
      {
        id = "cpu";
        hwmon = {
          platform = "cros_ec-isa-000c";
          index = 4;
        };
      }
    ]
    ++ builtins.map (hdd: {
      id = "hdd_${hdd}";
      cmd = {
        exec = "${get-hdd-temp}/bin/get-hdd-temp";
        args = [ hdd ];
      };
    }) hdds;
    curves =
      (builtins.map (hdd: {
        id = "hdd_${hdd}_curve";
        linear = {
          sensor = "hdd_${hdd}";
          min = 20;
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
        {
          id = "cpu_curve";
          linear = {
            sensor = "cpu";
            min = 25;
            max = 100;
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

    path = [ pkgs.getent ];
    serviceConfig = {
      Type = "simple";
      StateDirectory = "fan2go";
      ExecStart = "${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml";
      Restart = "always";
    };
  };
}
