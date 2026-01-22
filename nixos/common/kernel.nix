{
  systemd.coredump = {
    enable = true;
    extraConfig = ''
      Storage=external
      Compress=yes
      ProcessMaxSize=4G
    '';
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
