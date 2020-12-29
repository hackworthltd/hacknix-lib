final: prev:
let
  # Filter a package set so that only packages whose platform(s)
  # attribute contain `system` are in the output set.
  #
  # If the package has no platform attribute, assume it's supported
  # only on x86_64-linux.
  filterPackagesByPlatform = system: pkgs:
    let
      packagePlatforms = pkg: pkg.meta.hydraPlatforms or pkg.meta.platforms or [ "x86_64-linux" ];
      supported = _: drv: builtins.elem system (packagePlatforms drv);

    in
    final.lib.filterAttrs supported pkgs;

  # For some reason, the nixpkgs flake doesn't roll its local
  # lib.nixosSystem into nixpkgs.lib. We expose it here.
  inherit (final.lib.hacknix-lib.flake.inputs.nixpkgs.lib) nixosSystem;

  # nixosSystem is difficult to compose, and it's often useful to
  # extend the modules declared in a given configuration; e.g., to
  # override one or more module definitions. This function makes it
  # possible to add extra modules to a configuration.
  nixosSystem' = extraModules: config:
    nixosSystem (config // {
      modules = (config.modules or [ ]) ++ extraModules;
    });

  # Import a directory full of
  # nixosConfigurations/darwinConfigurations and apply a function that
  # has the same shape as nixosSystem'.
  importFromDirectory = nixosSystemFn: dir: args:
    final.lib.mapAttrs
      (_: cf:
        let config = cf args;
        in nixosSystemFn config)
      (final.lib.sources.importDirectory dir);

  # Create an attrset of buildable nixosConfigurations, using any
  # attribute in the `config.system.build` attrset. This is useful for
  # building via a Nix Flake's `hydraJobs`.
  #
  # Originally from:
  # https://github.com/Mic92/doctor-cluster-config/blob/d9964365bb112898fe2b4abb77a8408adf8b1cb5/flake.nix#L36
  build' = attr: configurations:
    final.lib.mapAttrs'
      (name: config: final.lib.nameValuePair name config.config.system.build.${attr})
      configurations;

  # Build the `toplevel` attribute (e.g., something that can be
  # deployed to a live system or container).
  build = build' "toplevel";

  # Build the `amazonImage` attribute.
  buildAmazonImages = build' "amazonImage";

  # Build the `isoImage` attribute.
  buildISOImages = build' "isoImage";

  # Export nix-darwin's lib.darwinSystem function.
  inherit (final.lib.hacknix-lib.flake.inputs.nix-darwin.lib) darwinSystem;

  # Like nixosSystem' for darwinSystem.
  darwinSystem' = extraModules: config:
    darwinSystem (config // {
      modules = (config.modules or [ ]) ++ extraModules;
    });

in
{
  lib = (prev.lib or { }) // {
    flakes = (prev.lib.flakes or { }) // {
      inherit filterPackagesByPlatform;

      inherit nixosSystem nixosSystem';

      nixosConfigurations = (prev.lib.flakes.nixosConfigruations or { }) // {
        inherit importFromDirectory;
        inherit build' build buildAmazonImages buildISOImages;
      };

      inherit darwinSystem darwinSystem';

      darwinConfigurations = (prev.lib.flakes.darwinConfigurations or { }) // {
        inherit importFromDirectory;
        inherit build' build;
      };
    };
  };
}