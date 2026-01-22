# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    cloud-init =
      prev.cloud-init.overrideAttrs
      (
        oldAttrs: {
          patches =
            oldAttrs.patches
            ++ [
              ./cloud-init-ucloud/patches/ucloud.patch
            ];

          disabledTests =
            oldAttrs.disabledTests
            ++ [
              "test_all_ds_init_vs_unpickle_attributes"
              "test_expected_default_local_sources_found"
            ];
        }
      );

    # nh = prev.nh.overrideAttrs (finalAttrs: oldAttrs: rec {
    #   src = prev.fetchFromGitHub {
    #     owner = "nix-community";
    #     repo = "nh";
    #     rev = "master";
    #     hash = prev.lib.fakeHash;
    #   };
    #   cargoDeps = prev.rustPlatform.fetchCargoVendor {
    #     src = finalAttrs.src;
    #     hash = prev.lib.fakeHash;
    #   };
    # })
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
