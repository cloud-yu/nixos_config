{
  config,
  pkgs,
  ...
}: let
  username = "mistery";
  homedir = config.users.users.${username}.home;
in {
  users.groups.proxy = {};

  systemd.services."xray@" = {
    unitConfig = {
      Description = "Xray Service";
      After = "network.target nss-lookup.target upd_rules.service";
    };
    serviceConfig = {
      Environment = "XRAY_LOCATION_ASSET=/var/local/rules_data";
      User = "xray";
      Group = "proxy";
      LogsDirectory = "xray";
      LogsDirectoryMode = 0755;
      Nice = -20;
      ExecStart = "${pkgs.unstable.xray}/bin/xray run -confdir /etc/xray/%i";
    };
    overrideStrategy = "asDropin";
  };
  systemd.services."xray@xtls" = {
    wantedBy = ["multi-user.target"];
  };

  systemd.tmpfiles.settings."xray@xtls"."/etc/xray/xtls"."C+" = {
    user = "xray";
    group = "proxy";
    mode = "0750";
    argument = "${homedir}/nixos-config/conf/xray/xtls";
  };

  # REALITY 配置由 sops-nix 渲染（含私钥/UUID），以强制符号链接注入 confdir
  systemd.tmpfiles.settings."xray@xtls-secret"."/etc/xray/xtls/055_reality.json"."L+" = {
    user = "xray";
    group = "proxy";
    argument = config.sops.templates."055_reality.json".path;
  };

  # 清理历史遗留的明文密钥副本（迁移前由 C+ 拷贝生成，源文件已从仓库删除）
  systemd.tmpfiles.settings."99-cleanup-legacy-secrets" = {
    "/etc/xray/xtls/050_xtls_to_sth.json.disabled"."R" = {};
    "/etc/xray/xtls/051_ss_inbounds.json.disabled"."R" = {};
    "/etc/xray/xtls/054_xtls_kcp.json.disabled"."R" = {};
  };

  users.users."xray" = {
    group = "proxy";
    home = "/etc/xray";
    isSystemUser = true;
    extraGroups = ["acme"];
    createHome = true;
    homeMode = "750";
  };

  systemd.services."upd_rules" = {
    wantedBy = ["default.target"];
    description = "Update rules data from internet";
    after = ["network-online.target"];
    path = ["${pkgs.bash}" "${pkgs.wget}"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/var/local/rules_data";
    };
    preStart = ''
      test -f update_rules_data.sh
      chmod +x update_rules_data.sh
    '';
    script = "bash update_rules_data.sh";
  };

  systemd.tmpfiles.settings."upd_rules" = {
    "/var/local/rules_data"."d" = {
      mode = "0755";
    };
    "/var/local/rules_data/update_rules_data.sh"."C+" = {
      user = "root";
      group = "root";
      mode = "0755";
      argument = "${homedir}/nixos-config/conf/upd_rules/update_rules_data.sh";
    };
  };

  systemd.services."hysteria-server@" = {
    description = "Hysteria Server Service";
    documentation = ["https://hysteria.network/"];
    after = ["network.target" "nss-lookup.target" "upd_rules.service"];
    serviceConfig = {
      Type = "simple";
      WorkingDirectory = "/etc/hysteria";
      User = "hysteria";
      Group = "proxy";
      NoNewPrivileges = true;
      CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
      AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
      ExecStart = "${pkgs.unstable.hysteria}/bin/hysteria server --config /etc/hysteria/%i.yaml --disable-update-check";
    };
    environment = {
      HYSTERIA_LOG_LEVEL = "info";
    };
    enable = true;
    overrideStrategy = "asDropin";
  };

  systemd.services."hysteria-server@config" = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Nice = -20;
    };
  };

  systemd.tmpfiles.settings."hysteria-server@config"."/etc/hysteria/config.yaml"."L+" = {
    user = "hysteria";
    group = "proxy";
    argument = config.sops.templates."hysteria-config.yaml".path;
  };

  users.users.hysteria = {
    group = "proxy";
    home = "/etc/hysteria";
    isSystemUser = true;
    extraGroups = ["acme"];
    createHome = true;
    homeMode = "750";
  };
  networking.firewall = {
    allowedTCPPorts = [51012];
    allowedUDPPorts = [51012 443 80];
  };
}
