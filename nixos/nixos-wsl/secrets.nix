{config, ...}: {
  sops = {
    defaultSopsFile = ../../secrets/nixos-wsl/secrets.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = false;
    };
  };

  sops.secrets.nixos-hashed-password = {
    neededForUsers = true;
  };
}
