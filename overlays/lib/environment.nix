self: super:

let

  getEnvNonEmpty = name:
    let
      value = builtins.getEnv name;
    in
      assert super.lib.assertMsg (value != "")
        "environment.getEnvNonEmpty: environment variable ${name} is not set or has empty value";
      value;

in
{
  lib = (super.lib or {}) // {
    environment = (super.lib.environment or {}) // {
      inherit getEnvNonEmpty;
    };
  };
}
