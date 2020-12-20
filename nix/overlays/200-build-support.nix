self: super:
let
  packageSource = name: version: srcPath: super.callPackage ../pkgs/package-source {
    inherit name version srcPath;
  };
in
{
  inherit packageSource;
}
