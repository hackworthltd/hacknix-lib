{ stdenv
, lib
, name
, version
, srcPath
}:

stdenv.mkDerivation {
  inherit name version;
  src = lib.cleanSource srcPath;

  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -rp . $out
  '';

  meta.platforms = lib.platforms.all;
}
