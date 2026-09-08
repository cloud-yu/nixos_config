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
    # 块的属性名即 Host 匹配模式；值为 OpenSSH 原生指令名（ssh_config(5)）
    settings = {
      "lahd" = {
        HostName = "lahd.ywings.top";
        User = "mistery";
        Port = 8022;
        ForwardAgent = false;
      };
      "bwh" = {
        HostName = "www.ywings.top";
        User = "mistery";
        Port = 8022;
        ForwardAgent = false;
      };
      "hk" = {
        HostName = "hk.ywings.top";
        User = "mistery";
        Port = 8022;
        ForwardAgent = false;
      };
      "*" = {
        AddKeysToAgent = "no";
        Compression = false;
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%h:%p";
        ControlPersist = "no";
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };
    };
  };
}
