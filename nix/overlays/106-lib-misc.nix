final: prev:
let
  shortRev = builtins.substring 0 7;

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
    prev.lib.filterAttrs supported pkgs;

in
{
  lib = (prev.lib or { }) // {
    misc = (prev.lib.misc or { }) // {
      inherit shortRev;
      inherit filterPackagesByPlatform;
    };
  };
}
