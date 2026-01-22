{
  pkgs,
  config,
  ...
}: let
  username = "mistery";
  homedir = config.users.users.${username}.home;
in {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "cloud2037@gmail.com";
      environmentFile = "/var/local/acme/acme-cf-api-token";
    };
    certs = {
      "hk.ywings.top" = let
        domain = "hk.ywings.top";
      in {
        dnsProvider = "cloudflare";
        extraDomainNames = [
          "*.${domain}"
          "*.s3.${domain}"
        ];
        reloadServices = [
          "nginx"
          "xray@xtls"
          "hysteria-server@config"
        ];
        postRun = ''
          #  合并证书链并生成 PFX证书文件
          ${pkgs.openssl}/bin/openssl pkcs12 -export -inkey key.pem -in fullchain.pem -out cert.pfx -password ***REMOVED***
        '';
      };
    };
  };
  systemd.tmpfiles.settings."01-acme-cf-api-token"."/var/local/acme"."C+" = {
    mode = "0600";
    user = "acme";
    argument = "${homedir}/nixos-config/conf/go-acme/";
  };
}
