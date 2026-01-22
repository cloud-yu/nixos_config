# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  config,
  lib,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../common/programs.nix
    ../common/containers.nix
  ];

  # TODO: Set your username
  home = {
    username = "mistery";
    homeDirectory = "/home/mistery";
  };

  services."rclone@" = {
    enable = true;
    instances = ["onedrive" "googledrive"];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
  home.activation = {
    rmSomething = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ${config.home.homeDirectory}/.nix-profile
      rm -rf ${config.home.homeDirectory}/.nix-defexpr
    '';
  };
}
