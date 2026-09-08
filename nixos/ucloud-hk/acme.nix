{
  pkgs,
  config,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "cloud2037@gmail.com";
      environmentFile = config.sops.templates."acme-cf-api-token".path;
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
          ${pkgs.openssl}/bin/openssl pkcs12 -export -inkey key.pem -in fullchain.pem -out cert.pfx -passout env:LEGO_PFX_PASSWORD
        '';
      };
    };
  };

  # 清理历史遗留的明文 token 副本（迁移前由 tmpfiles C+ 生成）
  systemd.tmpfiles.settings."99-cleanup-acme-token"."/var/local/acme/acme-cf-api-token"."R" = {};
}
