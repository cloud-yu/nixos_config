{
  pkgs,
  lib,
  ...
}: {
  home.packages = lib.mkAfter (with pkgs; [
    nodejs
  ]);
}
