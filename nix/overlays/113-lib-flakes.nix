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

  # Create an attrset of buildable nixosConfigurations. This is useful
  # for building via a Nix Flake's `hydraJobs`.
  #
  # Originally from:
  # https://github.com/Mic92/doctor-cluster-config/blob/d9964365bb112898fe2b4abb77a8408adf8b1cb5/flake.nix#L36
  buildNixosConfigurations = configurations:
    final.lib.mapAttrs'
      (name: config: final.lib.nameValuePair name config.config.system.build.toplevel)
      configurations;

in
{
  lib = (prev.lib or { }) // {
    flakes = (prev.lib.misc or { }) // {
      inherit filterPackagesByPlatform;
      inherit buildNixosConfigurations;
    };
  };
}
