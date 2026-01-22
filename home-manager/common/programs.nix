{
  pkgs,
  lib,
  ...
}: {
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = lib.mkBefore (with pkgs; [
    aria2
    btop
    nix-tree
  ]);

  # Enable home-manager and git
  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "monthly";
      timestamp = "-2 weeks";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.git = {
    enable = true;
    settings = {
      user.name = "mistery";
      user.email = "cloud2037@gmail.com";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "lahd" = {
        hostname = "lahd.ywings.top";
        user = "mistery";
        port = 8022;
        forwardAgent = false;
      };
      "bwh-jp" = {
        host = "bwh";
        hostname = "www.ywings.top";
        user = "mistery";
        port = 8022;
        forwardAgent = false;
      };
      "nixos-hk" = {
        host = "hk";
        hostname = "hk.ywings.top";
        user = "mistery";
        port = 8022;
        forwardAgent = false;
      };
      "default" = {
        host = "*";
        addKeysToAgent = "no";
        compression = false;
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%h:%p";
        controlPersist = "no";
        forwardAgent = false;
        hashKnownHosts = false;
        serverAliveCountMax = 3;
        serverAliveInterval = 0;
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
