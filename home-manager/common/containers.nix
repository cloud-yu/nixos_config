{pkgs, ...}: {
  home.packages = with pkgs; [
    podman
    podman-tui
  ];
  services.podman = {
    enable = true;
    images = {
      "renew_e5_local" = {
        image = "docker.io/hanhongyong/ms365-e5-renew-x:general";
      };
    };
    networks = {
      "podman_dual" = {
        autoStart = true;
        driver = "bridge";
        extraPodmanArgs = [
          "--ipv6"
        ];
      };
    };
    volumes = {
      "msvol" = {
        autoStart = true;
        driver = "local";
      };
    };
    containers = {
      "renew_e5_local" = {
        image = "docker.io/hanhongyong/ms365-e5-renew-x:general";
        network = "podman_dual";
        autoStart = true;
        environment = {
          "TZ" = "Asia/Shanghai";
        };
        volumes = [
          "msvol:/app"
        ];
        ports = ["127.0.0.1:18066:18066"];
      };
    };
  };
}
