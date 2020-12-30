{ lib
, ...
}:
{
  modules = lib.singleton
    ({ pkgs, ... }: {
      services.activate-system.enable = true;
    });
}
