final: prev:
let
  forAllSystems = systems: f: prev.lib.genAttrs systems (system: f system);

  ## These functions are useful for building package sets from
  ## stand-alone overlay repos.

  compose = overlays: pkgSet:
    let
      toFix = prev.lib.foldl' (prev.lib.flip prev.lib.extends) (prev.lib.const pkgSet) overlays;
    in
    prev.lib.fix toFix;

  composeFromFiles = overlaysFiles: pkgSet:
    compose (map import overlaysFiles) pkgSet;

  composeFromDir = dir: pkgSet:
    let
      files = prev.lib.filesystem.listFilesRecursive dir;
    in
    composeFromFiles files pkgSet;

in
{
  lib = (prev.lib or { }) // {
    flakes = (prev.lib.flakes or { }) // {
      inherit forAllSystems;
    };
    overlays = (prev.lib.overlays or { }) // {
      inherit compose composeFromFiles composeFromDir;
    };
  };
}
