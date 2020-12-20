final: prev:
let
  packageSource = name: version: srcPath: prev.callPackage ../pkgs/package-source {
    inherit name version srcPath;
  };
in
{
  inherit packageSource;
}
