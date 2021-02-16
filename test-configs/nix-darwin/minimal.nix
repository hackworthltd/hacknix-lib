# Note: we should be able to pass `system` here, but darwinSystem
# doesn't support that yet.

{ lib
, ...
}:
{
  modules = lib.singleton
    ({ pkgs, ... }: {
      services.activate-system.enable = true;
    });
}
