{ self, inputs, ... }:
{
  # Provide overlay to add `nix-snapshotter`.
  flake.overlays.default = self: super: {
    containerd-1_7 = super.containerd.overrideAttrs(_: rec {
      version = "1.7.28";

      src = self.fetchFromGitHub {
        owner = "containerd";
        repo = "containerd";
        tag = "v${version}";
        hash = "sha256-vz7RFJkFkMk2gp7bIMx1kbkDFUMS9s0iH0VoyD9A21s=";
      };

      outputs = [ "out" ];

      buildPhase = ''
        runHook preBuild
        patchShebangs .
        make binaries "VERSION=v${version}" "REVISION=${src.rev}"
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm555 bin/* -t $out/bin
        runHook postInstall
      '';
    });

    nix-snapshotter = self.callPackage ../../package.nix {
      inherit (inputs) globset;
    };

    k3s = super.k3s_1_34.overrideAttrs (finalAttrs: oldAttrs:
      super.lib.optionalAttrs (oldAttrs.pname != "k3s-cni-plugins" && oldAttrs.pname != "k3s-containerd") {
        vendorHash = {
          "sha256-dp8SU24nuy3WmG1Zln/J2nVHnVQmVyN78FBOSxNjbF8=" = "sha256-apHB2wzK4jNYkctrI8kPdAgR6i8DYeLR/4oOgidW1sw=";
        }.${oldAttrs.vendorHash};
        # Source https://patch-diff.githubusercontent.com/raw/k3s-io/k3s/pull/9319.patch
        # Remove when merged
        patches = (oldAttrs.patches or []) ++ [
          ./patches/k3s-nix-snapshotter.patch
        ];
      });
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
