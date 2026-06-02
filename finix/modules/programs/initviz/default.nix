{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "initviz";
  version = "1.0.0-rc1";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "finit-project";
    repo = "initviz";
    tag = finalAttrs.version;
    hash = "sha256-/kg1p70rONnsyJL0VnAAatnsoBzsqTHyoXyH0JK83Dg=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "InitViz is a fork of bootchart2 for use with any init system.  Some bells and whistles added, for Finit";
    homepage = "https://github.com/finit-project/initviz";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "initviz";
    platforms = lib.platforms.all;
  };
})
