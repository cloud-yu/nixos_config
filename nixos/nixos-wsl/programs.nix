{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = lib.mkAfter (
    with pkgs; [
      # linux-manual
      man-pages
      nh
    ]
  );

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "${config.users.users.nixos.home}/nixos-config";
  };
}
