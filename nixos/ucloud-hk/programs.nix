{
  pkgs,
  lib,
  config,
  ...
}: {
  environment.systemPackages = lib.mkAfter (
    with pkgs; [
      nh
    ]
  );

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    # flake = "\${HOME}/nixos-config";
    flake = "${config.users.users.mistery.home}/nixos-config";
  };
}
