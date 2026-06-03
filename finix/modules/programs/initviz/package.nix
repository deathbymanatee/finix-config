{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "initviz";
  version = "0.14.9";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "finit-project";
    repo = "initviz";
    tag = finalAttrs.version;
    hash = "sha256-sRJheliAF4UHHWhYlNV3K8VqezcssSnPRShp1+rE5kI=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "InitViz is a fork of bootchart2 for use with any init system.  Some bells and whistles added, for Finit";
    homepage = "https://github.com/finit-project/initviz";
    changelog = "https://github.com/finit-project/initviz/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "initviz";
    platforms = lib.platforms.all;
  };
})
