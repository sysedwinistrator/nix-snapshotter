{ self, inputs, ... }:
{
  # Provide overlay to add `nix-snapshotter`.
  flake.overlays.default = self: super: {
    nix-snapshotter = self.callPackage ../../package.nix {
      inherit (inputs) globset;
    };

    k3s = super.k3s_1_30.override {
      buildGoModule = args: super.buildGoModule (args // super.lib.optionalAttrs (args.pname != "k3s-cni-plugins" && args.pname != "k3s-containerd") {
        vendorHash = {
          "sha256-fs9p6ywS5XCeJSF5ovDG40o+H4p4QmEJ0cvU5T9hwuA=" = "sha256-htanp0VOMadzoIyPUT8kOTSb58sz5DHlVBVGbY13ejU=";
          "sha256-q/cRKuqXuzPcLEYD+BH82ZAc+ZgGIqKWLsM1E4uQsok=" = "sha256-tJBi4b3OGrGbc49+LNx0PXwj9NuvBB55DNvIG1VCMh8=";
          "sha256-HTUFv8WBIDiBQ860p3RiROF+kDzBekvgBAr2TJh036E=" = "sha256-Wzd0ief4HnMc/EW+AZOabTdl2yYJWohn51Unw1Nj850=";
          "sha256-G7RUyFzg3B4X0tdKmD1ep9a4cnVkUmFqBP5t1s8uFLc=" = "sha256-nHlMqR3fkt+tLb4K0P5PWQ9Fj7J9vzy/01HfCdsJODY=";
          "sha256-FQu2Chk463c+/VYcOhfU8xIxm/ZNe1GumkEH/u2DIt0=" = "sha256-Y1m27ANqY7pWJUpnQ0df947y9JArOkuFL7kVjJZGSrA=";
        }.${args.vendorHash};
        # Source https://patch-diff.githubusercontent.com/raw/k3s-io/k3s/pull/9319.patch
        # Remove when merged
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
