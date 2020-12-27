final: prev:
let
  packageSource = name: version: srcPath: final.callPackage ../pkgs/package-source {
    inherit name version srcPath;
  };
in
{
  inherit packageSource;
}
