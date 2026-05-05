{
  config,
  pkgs,
  lib,
  ...
}:
# helpful links
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/x11/desktop-managers/lxqt.nix
# https://github.com/NixOS/nixpkgs/pkgs/desktops/lxqt/default.nix
let
  cfg = config.programs.lxqt;

  inherit (pkgs) lxqt;
  inherit (pkgs) kdePackages;

  xSessionFile = pkgs.writeTextDir "share/xsessions/lxqt.desktop" ''
    [Desktop Entry]
    Name=LXQT X11
    Comment=LXQT Desktop
    Exec=${lxqt.lxqt}/bin/lxqt-session
    Type=Application
    DesktopNames=KDE
  '';

  waylandSessionFile = pkgs.writeTextDir "share/xsessions/lxqt.desktop" ''
    [Desktop Entry]
    Name=LXQT Wayland 
    Comment=LXQT Wayland Desktop
    Exec=${lxqt.lxqt-wayland-session}/bin/lxqt-wayland-session
    Type=Application
    DesktopNames=KDE
  '';

  packages = {
    preRequisitePackages = [
      kdePackages.kwindowsystem # provides some QT plugins needed by lxqt-panel
      kdePackages.libkscreen # provides plugins for screen management software
      pkgs.libfm
      pkgs.libfm-extra
      pkgs.menu-cache
      pkgs.openbox # default window manager
      kdePackages.qtsvg # provides QT plugins for svg icons
    ];

    corePackages = [
      ### BASE
      lxqt.libqtxdg
      lxqt.libsysstat
      lxqt.liblxqt
      lxqt.qtxdg-tools
      lxqt.libdbusmenu-lxqt

      ### CORE 1
      lxqt.libfm-qt
      lxqt.lxqt-about
      lxqt.lxqt-admin
      lxqt.lxqt-config
      lxqt.lxqt-globalkeys
      lxqt.lxqt-menu-data
      lxqt.lxqt-notificationd
      lxqt.lxqt-openssh-askpass
      lxqt.lxqt-policykit
      lxqt.lxqt-powermanagement
      lxqt.lxqt-qtplugin
      lxqt.lxqt-session
      lxqt.lxqt-sudo
      lxqt.lxqt-themes
      lxqt.lxqt-wayland-session
      lxqt.pavucontrol-qt

      ### CORE 2
      lxqt.lxqt-panel
      lxqt.lxqt-runner
      lxqt.pcmanfm-qt
    ];

    optionalPackages = [
      ### LXQt project
      lxqt.qterminal
      lxqt.obconf-qt
      lxqt.lximage-qt
      lxqt.lxqt-archiver

      ### QtDesktop project
      lxqt.qps
      lxqt.screengrab

      ### Default icon theme
      kdePackages.breeze-icons

      ### Screen saver
      pkgs.xscreensaver
    ];
  };

in
{
  options.programs.lxqt = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the LXQT desktop environment.
      '';
    };

    iconThemePackage = lib.mkPackageOption pkgs [ "kdePackages" "breeze-icons" ] { } // {
      description = "The package that provides a default icon theme.";
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      defaultText = lib.literalExpression "[ ]";
      example = lib.literalExpression "with pkgs; [ lxqt.qterminal ]";
      description = "Extra packages to be installed system wide.";
    };

    excludePackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with lxqt;
      [
        # session entry points
        (lib.hiPrio xSessionFile)
        (lib.hiPrio waylandSessionFile)
      ]
      ++ packages.preRequisitePackages
      ++ packages.corePackages;

    environment.pathsToLink = [
      "/share"
    ];

    security.pam.environment =
      let
        qtVersions = with pkgs; [
          qt5
          qt6
        ];
      in
      {
        QT_PLUGIN_PATH.default = map (qt: "/run/current-system/sw/${qt.qtbase.qtPluginPrefix}") qtVersions;
        QML2_IMPORT_PATH.default = map (qt: "/run/current-system/sw/${qt.qtbase.qtQmlPrefix}") qtVersions;

        XDG_CONFIG_DIRS.default = [ "@{HOME}/.config/kdedefaults" ];
      };

    security.wrappers = {
      kwin_wayland = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_nice+ep";
        source = "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
      };
    };

    xdg.portal.portals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];

    services.elogind.enable = true;
  };
}
