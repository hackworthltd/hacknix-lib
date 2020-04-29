self: super:
let
  hacknix-lib-source = super.packageSource "hacknix-lib-source" "1.0" ../../..;
in
{
  inherit hacknix-lib-source;
}
