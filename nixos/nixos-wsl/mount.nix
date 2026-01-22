{
  fileSystems = {
    "/home/nixos/repo" = {
      device = "/mnt/e/repo";
      fsType = "none";
      options = ["bind"];
    };
    "/home/nixos/exercism" = {
      device = "/mnt/e/Exercism/exercism";
      fsType = "none";
      options = ["bind"];
    };
  };
}
