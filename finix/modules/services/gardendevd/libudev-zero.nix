{
  lib,
  stdenv,
  fetchFromCodeberg,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-zero";
  version = "unstable";

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "libudev-zero";
    rev = "8573d647bb44efd3569b6adf782bfb947a2b7124";
    sha256 = "sha256-zlyzsmLr/3Nx0OUCszENZQum4VR9IKB1XJlxrNmt3tI=";
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
    homepage = "https://github.com/illiliti/libudev-zero";
    description = "Daemonless replacement for libudev";
    changelog = "https://github.com/illiliti/libudev-zero/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [
      qyliss
      shamilton
    ];
    license = lib.licenses.isc;
    pkgConfigModules = [ "libudev" ];
    platforms = lib.platforms.linux;
  };
})
