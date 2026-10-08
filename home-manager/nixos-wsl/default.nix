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
  programs.npm = {
    enable = true;
    settings = {
      prefix = "${config.home.homeDirectory}/.local";
      registry = "https://registry.npmmirror.com";
    };
  };

  # 终端 shell 的 core dump 软限制（配套 ../../nixos/nixos-wsl/coredump.nix）：
  # WSL 终端 shell 由微软 /init 会话树派生，不经过 PAM、不在 systemd 之下，
  # 软限制是内核默认的 0。NixOS 的 programs.fish.* 经 fenv 在子 POSIX shell
  # 中执行，ulimit 无法回传到 fish 本体，因此用 fish 原生的用户级 conf.d 投递
  # （实测 /etc/fish/conf.d 与 /etc/xdg/fish/conf.d 均不被读取）。
  # fish 的 ulimit 单位是 1024 字节块：4000000 → 4096000000 字节，
  # 与 common/kernel.nix 中 loginLimits 的 core=4000000(KB) 一致；
  # 用户服务无需此文件（user manager 经 PAM 已拿到相同限制）。
  xdg.configFile."fish/conf.d/10-core-limit.fish".text = ''
    ulimit -c 4000000
  '';

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
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
