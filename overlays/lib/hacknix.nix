self: super:

let

  localLibs = import ../../lib;

  # Provide access to the whole package, if needed.
  path = ../../.;

in
{
  lib = (super.lib or {}) // {
    hacknix = (super.lib.hacknix or {}) // {
      inherit path;

      # Access to hacknix-lib's fixed nixpkgs.
      inherit (localLibs) nixpkgs;
    };
  };
}
