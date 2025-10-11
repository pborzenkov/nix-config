{
  config,
  machineSecrets,
  ...
}:
let
  port = 3001;
in
{
  # pbor.webapps.apps.invidious = {
  #   subDomain = "invidious";
  #   proxyTo = "http://127.0.0.1:${toString port}";
  #   locations = {
  #     "/" = { };
  #     "~ (^/videoplayback|^/vi/|^/ggpht/|^/sb/)" = {
  #       custom = {
  #         proxyPass = "http://unix:/run/http3-ytproxy/socket/http-proxy.sock";
  #       };
  #     };
  #   };
  #   dashboard = {
  #     name = "Invidious";
  #     category = "app";
  #     icon = "video";
  #   };
  # };

  # services.invidious = {
  #   enable = true;
  #   address = "127.0.0.1";
  #   port = 3001;
  #   domain = "invidious.lab.borzenkov.net";
  #   http3-ytproxy.enable = true;
  #   sig-helper = {
  #     enable = true;
  #   };
  #   database.createLocally = true;
  #   settings = {
  #     db = {
  #       user = "invidious";
  #       dbname = "invidious";
  #     };
  #     external_port = 443;
  #     https_only = true;
  #     captcha_enabled = false;
  #     admins = [ "pavel" ];
  #     default_user_preferences = {
  #       quality = "dash";
  #       quality_dash = "auto";
  #       default_home = "Subscriptions";
  #     };
  #   };
  #   extraSettingsFile = "/run/credentials/invidious.service/extra-settings";
  # };
  # systemd.services = {
  #   invidious.serviceConfig.LoadCredential = "extra-settings:${config.age.secrets.invidious-credentials.path}";
  #   http3-ytproxy.serviceConfig.User = config.services.nginx.user;
  # };

  # age.secrets.invidious-credentials.file = machineSecrets + "/invidious-credentials.age";
}
