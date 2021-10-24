{ config, lib, pkgs, ... }:
let
  cfg = config.themes.base16;
  templates = lib.importJSON ./templates.json;
  importYAML = name: (lib.importJSON (pkgs.runCommandNoCC name { } ''
    ${pkgs.yaml2json}/bin/yaml2json < ${name} | ${pkgs.jq}/bin/jq -a '.' > $out
  ''));
in
{
  options = {
    themes.base16.enable = lib.mkEnableOption "Base16 Color Schemes";
    themes.base16.scheme = lib.mkOption {
      type = lib.types.str;
      default = "onedark";
    };
  };

  config = {
    lib.base16.theme = repo:
      let
        t = pkgs.fetchgit {
          url = templates."${repo}".url;
          rev = templates."${repo}".rev;
          sha256 = templates."${repo}".sha256;
        };
        tc = importYAML "${t}/templates/config.yaml";
      in
      "${t}/${tc.default.output}/base16-${cfg.scheme}${tc.default.extension}";
  };
}
