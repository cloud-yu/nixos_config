{
  pkgs,
  lib,
  ...
}: {
  home.packages = lib.mkAfter (with pkgs; [
    nodePackages_latest.nodejs
  ]);
}
