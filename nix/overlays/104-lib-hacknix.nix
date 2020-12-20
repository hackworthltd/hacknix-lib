final: prev:
let
  # Provide access to the whole package, if needed.
  path = ../../.;
in
{
  lib = (prev.lib or { }) // {
    hacknix-lib = (prev.lib.hacknix-lib or { }) // { inherit path; };
  };
}
