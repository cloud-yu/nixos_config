{pkgs, ...}: {
  services.nginx = {
    package = pkgs.unstable.nginx;
    enable = true;
    recommendedOptimisation = true;
    typesHashMaxSize = 4096;
    appendConfig = ''
      worker_processes auto;
      worker_rlimit_nofile 65535;
    '';
    eventsConfig = ''
      multi_accept on;
      worker_connections 65535;
    '';
    commonHttpConfig = ''
      proxy_set_header X-Real-IP $proxy_protocol_addr;
      proxy_set_header X-Forwarded-For $proxy_protocol_addr;
    '';

    # stream module config
    streamConfig = ''
      # stream -- TCP and UDP traffic
      log_format stream_basic '$remote_addr -> $proxy_protocol_addr [$time_local] '
                              'SNI: $ssl_preread_server_name Backend: $stream_map '
                              'Destination: $upstream_addr ';

      access_log /var/log/nginx/stream_access.log stream_basic;

      map $ssl_preread_server_name $stream_map {
        hostnames;
      #  ~(.*\.)?s3\.hk\.ywings\.top    s3;
        lahd.ywings.top              xray;
        msdev.hk.ywings.top             msdev;
        hk.ywings.top                   webhost;
        default                         err;
      }

      upstream webhost {
        server unix:/run/socks/webhost.sock;
      }

      upstream msdev {
        server unix:/run/socks/msdev.sock;
      }

      upstream xray {
        server unix:/run/socks/xray.sock;
      }

      upstream err {
        server unix:/run/socks/err.sock;
      }

      server {
        listen 443 reuseport;
        listen [::]:443 reuseport;

        ssl_preread on;
        proxy_protocol on;
        proxy_pass $stream_map;
      }
    '';

    virtualHosts = {
      "80" = {
        default = true;
        serverName = "hk.ywings.top";
        listenAddresses = ["*" "[::]"];
        globalRedirect = "https://$server_name$request_uri";
        redirectCode = 308;
      };

      "webhost" = {
        listen = [
          {
            addr = "unix:/run/socks/webhost.sock";
            proxyProtocol = true;
            ssl = true;
          }
        ];
        onlySSL = true;
        http2 = true;

        useACMEHost = "hk.ywings.top";
        root = "/srv/http/html";
        extraConfig = ''
          set_real_ip_from unix:;
          real_ip_header proxy_protocol;

          ssl_session_timeout 5m;
          ssl_session_cache shared:MozSSL:10m;
          ssl_session_tickets on;

          index index.html index.htm index.nginx-debian.html;
        '';
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ =404";
          };
          "/***REMOVED***" = {
            proxyPass = "http://127.0.0.1:8443";
            extraConfig = ''
              client_max_body_size 0;
              client_body_timeout 5m;
              grpc_set_header X-Real-IP $remote_addr;
              grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              grpc_set_header Host $host;
              grpc_read_timeout 315;
              grpc_send_timeout 5m;
              grpc_pass unix:/run/socks/xrxh.sock;
            '';
          };
          "/openai/" = let
            openai_pass = "api.openai.com";
          in {
            proxyPass = "https://${openai_pass}";
            extraConfig = ''
              rewrite ^/openai(.*)$ $1$is_args$args break;
              proxy_ssl_server_name on;
              proxy_http_version 1.1;
              proxy_set_header Host ${openai_pass};
              chunked_transfer_encoding off;
              resolver 8.8.8.8 8.8.4.4 ipv6=off;
            '';
          };
        };
      };
      "msdev" = {
        listen = [
          {
            addr = "unix:/run/socks/msdev.sock";
            proxyProtocol = true;
            ssl = true;
          }
        ];
        onlySSL = true;
        serverName = "msdev.hk.ywings.top";
        useACMEHost = "hk.ywings.top";
        # sslCertificate = "/etc/nginx/cert/hk.ywings.top.cer";
        # sslCertificateKey = "/etc/nginx/cert/hk.ywings.top.key";
        extraConfig = ''
          ssl_prefer_server_ciphers on;
        '';
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:18066";
            extraConfig = ''
              proxy_redirect off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
            '';
          };
        };
      };
      "err" = {
        listen = [
          {
            addr = "unix:/run/socks/err.sock";
            proxyProtocol = true;
            ssl = true;
          }
        ];
        rejectSSL = true;
      };
    };
  };

  systemd.tmpfiles.settings."socks"."/run/socks"."d" = {
    mode = "1777";
  };
  users.users.nginx.extraGroups = ["acme"];
  networking.firewall.allowedTCPPorts = [443 80];
}
