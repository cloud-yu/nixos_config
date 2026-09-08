{config, ...}: {
  sops.defaultSopsFile = ../../secrets/ucloud-hk/secrets.yaml;

  sops.secrets = {
    # --- ACME / Cloudflare ---
    cf-dns-api-token = {};
    cf-zone-api-token = {};
    cf-api-email = {};
    lego-pfx-password = {};
    # --- Xray REALITY ---
    xray-reality-private-key = {};
    xray-client-uuid = {};
    xray-xhttp-uuid = {};
    xray-mlkem-decryption = {};
    xray-xhttp-path = {};
    # --- Hysteria ---
    hysteria-password = {};
    # --- 用户密码哈希（需在用户创建前解密） ---
    mistery-hashed-password = {
      neededForUsers = true;
    };
  };

  # lego/ACME 环境变量文件（渲染为 dotenv 完整文件）
  # 渲染路径: /run/secrets/rendered/acme-cf-api-token
  sops.templates."acme-cf-api-token" = {
    owner = "acme";
    mode = "0600";
    content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cf-dns-api-token}
      CF_ZONE_API_TOKEN=${config.sops.placeholder.cf-zone-api-token}
      CF_API_EMAIL=${config.sops.placeholder.cf-api-email}
      LEGO_PFX_PASSWORD=${config.sops.placeholder.lego-pfx-password}
      LEGO_PFX=true
    '';
  };

  # Xray REALITY 配置（结构/短ID入库，密钥材料运行时渲染）
  # 渲染路径: /run/secrets/rendered/055_reality.json
  sops.templates."055_reality.json" = {
    owner = "xray";
    group = "proxy";
    mode = "0750";
    restartUnits = ["xray@xtls.service"];
    content = ''
      {
        "inbounds": [
          {
            "listen": "/run/socks/xray.sock,0666",
            "protocol": "vless",
            "settings": {
              "clients": [
                {
                  "id": "${config.sops.placeholder.xray-client-uuid}",
                  "flow": "xtls-rprx-vision",
                  "email": "xtls@vps.com"
                }
              ],
              "decryption": "none",
              "fallbacks": [
                {
                  "dest": "/run/socks/xrxh.sock"
                }
              ]
            },
            "tag": "reality",
            "streamSettings": {
              "network": "tcp",
              "tcpSettings": {
                "acceptProxyProtocol": true
              },
              "security": "reality",
              "realitySettings": {
                "show": true,
                "target": "lahd.ywings.top:443",
                "xver": 0,
                "serverNames": [
                  "lahd.ywings.top"
                ],
                "privateKey": "${config.sops.placeholder.xray-reality-private-key}",
                "shortIds": [
                  "ad2037"
                ]
              }
            },
            "sniffing": {
              "enabled": true,
              "destOverride": [
                "http",
                "tls",
                "quic"
              ],
              "routeOnly": true
            }
          },
          {
            "listen": "/run/socks/xrxh.sock,0666",
            "protocol": "vless",
            "settings": {
              "clients": [
                {
                  "id": "${config.sops.placeholder.xray-xhttp-uuid}",
                  "flow": "xtls-rprx-vision",
                  "level": 0,
                  "email": "xtls_xhttp@vps.com"
                }
              ],
              "decryption": "${config.sops.placeholder.xray-mlkem-decryption}"
            },
            "tag": "xtls_xhttp",
            "streamSettings": {
              "network": "xhttp",
              "xhttpSettings": {
                "path": "${config.sops.placeholder.xray-xhttp-path}"
              }
            },
            "sniffing": {
              "enable": true,
              "destOverride": [
                "http",
                "tls",
                "quic"
              ]
            }
          }
        ]
      }
    '';
  };

  # Hysteria 配置（结构与 ACL 入库，密码运行时渲染）
  # 渲染路径: /run/secrets/rendered/hysteria-config.yaml
  sops.templates."hysteria-config.yaml" = {
    owner = "hysteria";
    group = "proxy";
    mode = "0640";
    restartUnits = ["hysteria-server@config.service"];
    content = ''
      listen: :51012

      tls:
        cert: /var/lib/acme/hk.ywings.top/cert.pem
        key: /var/lib/acme/hk.ywings.top/key.pem

      # 带宽
      bandwidth:
        up: 30mbps
        down: 30mbps

      # 伪装
      masquerade:
        type: proxy

        # 作为一个静态文件服务器，从一个目录提供文件
        file:
          dir: /home/mistery/netdisk/googledrive
        # 作为一个反向代理，从另一个网站提供内容
        proxy:
          url: https://hk.ywings.top
          rewriteHost: true
        # 返回一个固定的字符串
        string:
          content: fuck'in world
          headers:
            content-type: text/plain
            custom-stuff: no fuck to say

      udpIdleTimeout: 120s
      auth:
        type: password
        password: ${config.sops.placeholder.hysteria-password}

      outbounds:
        - name: direct_out
          type: direct

      # 路由规则
      acl:
        geoip: /var/local/rules_data/geoip.dat
        geosite: /var/local/rules_data/geosite.dat
        inline:
          - direct(geosite:gfw)
          - direct(suffix:googleapis.cn)
          - direct(suffix:gstatic.com)
          - reject(geosite:cn)
          - reject(geoip:cn)
          - direct(all)
    '';
  };
}
