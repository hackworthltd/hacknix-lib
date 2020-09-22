self: super:
let
  localLibs = import ../../nix/default.nix;

  # Provide access to the whole package, if needed.
  path = ../../.;
in
{
  lib = (super.lib or {}) // {
    hacknix-lib = (super.lib.hacknix-lib or {}) // { inherit path; };
  };
}