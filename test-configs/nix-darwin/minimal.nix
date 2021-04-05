{ lib
, ...
}:
{
  system = "x86_64-darwin";
  modules = lib.singleton
    ({ pkgs, ... }: {
      services.activate-system.enable = true;
    });
}
