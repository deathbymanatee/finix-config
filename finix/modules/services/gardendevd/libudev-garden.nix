{
  lib,
  stdenv,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-garden";
  version = "0.2.1";

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "libudev-garden";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-+95+3Hb6lkIhpNZF0pQdM9y5GxZCplp/o2nemZJb5Wc=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  meta = {
    homepage = "https://codeberg.org/Gardenhouse/libudev-garden";
    description = "Daemonless replacement for libudev";
    changelog = "https://codeberg.org/Gardenhouse/libudev-garden/src/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [
      aanderse
      choco98
    ];
    license = lib.licenses.gpl3Only;
    pkgConfigModules = [ "libudev" ];
    platforms = lib.platforms.linux;
  };
})
