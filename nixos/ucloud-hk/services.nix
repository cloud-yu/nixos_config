{
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    ports = [8022];
    allowSFTP = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  services.cloud-init = {
    enable = true;
    network.enable = true;
    btrfs.enable = true;
    settings = {
      datasourceList = ["UCloud"];
      cloud_init_modules = [
        "migrator"
        "seed_random"
        "bootcmd"
        "write-files"
        "growpart"
        "resolv-conf"
        "ca-certs"
        "rsyslog"
      ];
      disable_root = true;
      system_info.ntp_client = "auto";
      users = ["default"];
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "15m";
  };

  services.resolved.enable = true;
}
