{
  pkgs,
  lib,
  config,
  ...
}: {
  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # your username
    mistery = {
      ## You can set an initial password for your user.
      ## If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      ## Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      createHome = true;
      hashedPasswordFile = config.sops.secrets.mistery-hashed-password.path;
      openssh.authorizedKeys.keys = [
        ## Add your SSH public key(s) here, if you plan on using SSH to connect
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHy7BUvwtFBbOWuCIoJ6GUjEr4PzpQ0QJVFGeGA0kLzV personal@key"
      ];
      ## Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "proxy"];
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = lib.mkForce true;
  };
}
