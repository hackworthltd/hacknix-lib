{ localLib ? import nix/default.nix
}:

localLib.pkgs.mkShell {
  buildInputs = [
    localLib.niv
  ];
}
