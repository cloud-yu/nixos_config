{
  systemd.coredump = {
    enable = true;
    settings.Coredump = {
      Storage = "external";
      Compress = "yes";
      ProcessMaxSize = "4G";
    };
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "core";
      value = "4000000";
    }
  ];
}
