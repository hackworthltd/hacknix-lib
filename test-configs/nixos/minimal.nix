{ lib
, system
, ...
}:
{
  inherit system;
  modules = lib.singleton
    ({ pkgs, ... }:
      let
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL/10ldzuaIOI1je/YRCuz18XgHuf4adsl2VgJv/Pz6s";
      in
      {
        users.users.root.openssh.authorizedKeys.keys = [
          sshPublicKey
        ];
      });
}
