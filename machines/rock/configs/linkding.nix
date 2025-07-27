{
  ...
}:
{
  pbor.webapps.apps = {
    linkding = {
      subDomain = "linkding";
      auth.rbac = [ "group:linkding" ];
      proxyTo = "http://127.0.0.1:8087";
      locations."/" = { };
      locations."/api" = {
        skip_auth = true;
      };
      dashboard = {
        name = "Linkding";
        category = "app";
        icon = "shopping-bag";
      };
    };
  };

  virtualisation.oci-containers.containers.linkding = {
    autoStart = true;
    image = "sissbruecker/linkding:1.41.0-alpine";
    volumes = [ "/var/lib/linkding:/etc/linkding/data" ];
    ports = [ "8087:8087" ];
    environment = {
      LD_SERVER_PORT = "8087";
      LD_ENABLE_AUTH_PROXY = "True";
      LD_AUTH_PROXY_USERNAME_HEADER = "HTTP_REMOTE_USER";
    };
  };

  pbor.backup.fsBackups.linkding = {
    paths = [
      "/var/lib/private/linkding"
    ];
  };
}
