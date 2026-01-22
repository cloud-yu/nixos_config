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
    # outputs.homeManagerModules.rcloneService

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    # ../common/nix.nix
    ../common/programs.nix
    ../common/development.nix
    ./programs.nix
  ];
  # TODO: Set your username
  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
  };

  # systemd.user.services = {
  #   "mount-home-repo" = {
  #     Unit = {
  #       Description = "bind mount /mnt/e/repo in home dir";
  #     };
  #     Service = {
  #       Type = "oneshot";
  #       ExecStart = "${pkgs.bindfs}/bin/bindfs --no-allow-other --create-with-perms=u+rw,a+rD /mnt/e/repo ${config.home.homeDirectory}/repo";
  #       ExecStop = "/run/wrappers/bin/fusermount3 -u ${config.home.homeDirectory}/repo";
  #       RemainAfterExit = true;
  #     };
  #     Install = {
  #       WantedBy = [ "default.target" ];
  #     };
  #   };
  #   "mount-home-exercism" = {
  #     Unit = {
  #       Description = "bind mount /mnt/e/Exercises/exercises in home dir";
  #     };
  #     Service = {
  #       Type = "oneshot";
  #       ExecStart = "${pkgs.bindfs}/bin/bindfs --no-allow-other --create-with-perms=u+rw,a+rD /mnt/e/Exercism/exercism ${config.home.homeDirectory}/exercism";
  #       ExecStop = "/run/wrappers/bin/fusermount3 -u ${config.home.homeDirectory}/exercism";
  #       RemainAfterExit = true;
  #     };
  #     Install.WantedBy = [ "default.target" ];
  #   };
  # };

  # services."rclone@" = {
  #   enable = true;
  #   instances = [ "onedrive" "googledrive" ];
  # };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/.node_modules "
  ];
  home.file = {
    ".npmrc" = {
      enable = true;
      text = ''
        prefix=~/.node_modules
      '';
    };
    ".zlogin" = {
      enable = true;
      text = ''
        ulimit -c 4000000
        if [ -d "''${HOME}/.node_modules" ]; then
          PATH="''${HOME}/.node_modules/bin:''${PATH}"
        fi
      '';
    };
  };

  home = {
    stateVersion = "24.11";
    ## Home Manager is only able to set session variables automatically if it manages you BAHS, Z shell
    ## or fish shell configuration.
    ## To enable such management you use `programs.bash.enable`, `programs.zsh.enable`, or `programs.fish.enable`.
    # sessionPath = [];
    # activation = {
    #   rmSomething = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     rm -rf ${config.home.homeDirectory}/.nix-profile
    #     rm -rf ${config.home.homeDirectory}/.nix-defexpr
    #   '';
    # };
  };
}
