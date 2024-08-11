{ self, inputs, ... }:
{
  # Provide overlay to add `nix-snapshotter`.
  flake.overlays.default = self: super:
    let

    in {
      nix-snapshotter = self.callPackage ../../package.nix {};

      k3s = super.k3s_1_30.override {
        buildGoModule = args: super.buildGoModule (args // super.lib.optionalAttrs (args.pname != "k3s-cni-plugins" && args.pname != "k3s-containerd") {
          vendorHash = "sha256-9i0vY+CqrLDKYBZPooccX7OtFhS3//mpKTLntvPYDJo=";
          patches = (args.patches or []) ++ [
            ./patches/k3s-nix-snapshotter.patch
          ];
        });
      };
    };

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # Apply default overlay to provide nix-snapshotter for NixOS tests &
      # configurations.
      overlays = [ self.overlays.default ];
    };
  };
}
