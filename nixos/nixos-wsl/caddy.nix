{pkgs, ...}: {
  services.caddy = {
    enable = true;
    package = pkgs.unstable.caddy.withPlugins {
      plugins = ["github.com/mholt/caddy-l4@v0.0.0-20250428144642-57989befb7e6"];
      hash = "sha256-UNOvokDRmir2RcXdsSwUxHLEKD8PA6aYEngjUPImsTo=";
    };
  };
}
