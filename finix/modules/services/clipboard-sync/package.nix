{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  stdenv,
  wayland,
  xorg,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clipboard-sync";
  version = "0.2.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "dnut";
    repo = "clipboard-sync";
    tag = finalAttrs.version;
    hash = "sha256-gme5pwQrwQbk8MroF/mGYqlY6hcjM5cHKHL7Y3nlW9k=";
  };

  cargoHash = "sha256-kc+650Lk8hueAzxZGa/deWsNAWgsXCq+rz73BCQiS9E=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    wayland
    xorg.libxcb
  ];

  passthru.updateScript = nix-update-script { };
})
