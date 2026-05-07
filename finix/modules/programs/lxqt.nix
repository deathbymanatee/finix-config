{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.lxqt;

  inherit (pkgs) lxqt;
  inherit (pkgs) kdePackages;

  # TODO: x11?
  xSessionFile = pkgs.writeTextDir "share/xsessions/lxqt.desktop" ''
    [Desktop Entry]
    Name=LXQt (X11)
    Comment=LXQT Desktop
    Exec=${pkgs.lxqt.lxqt-session}/bin/startlxqt    
    Type=Application
    DesktopNames=LXQt
  '';

  sessionFile = pkgs.writeTextDir "share/wayland-sessions/lxqt-wayland.desktop" ''
    [Desktop Entry]
    Name=LXQt (Wayland)
    Comment=LXQt Wayland Desktop
    Exec=${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.lxqt.lxqt-wayland-session}/bin/startlxqtwayland
    Type=Application
    DesktopNames=LXQt
  '';

  libinput = pkgs.libinput.override (
    lib.optionalAttrs config.services.mdevd.enable {
      udev = pkgs.libudev-zero;
      wacomSupport = false;
    }
  );

  packages = {
    preRequisitePackages = [
      kdePackages.kwindowsystem # provides some QT plugins needed by lxqt-panel
      kdePackages.libkscreen # provides plugins for screen management software
      pkgs.libfm
      pkgs.libfm-extra
      pkgs.menu-cache
      pkgs.openbox
      kdePackages.qtsvg # provides QT plugins for svg icons
      pkgs.libxcb-cursor
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
      pkgs.xdg-utils
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
        Whether to enable the LXQt desktop environment.
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

    waylandCompositor = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.labwc.override {
          inherit libinput;
          wlroots_0_19 = pkgs.wlroots_0_19.override { inherit libinput; };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      packages.preRequisitePackages
      ++ packages.corePackages
      ++ [
        # session entry point
        (lib.hiPrio sessionFile)
        (lib.hiPrio xSessionFile)
        cfg.waylandCompositor.package
      ];

    environment.pathsToLink = [
      "/share"
    ];

    security.pam.environment = {
      XDG_CONFIG_DIRS.default = [ "/run/current-system/sw/share" ];
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
      pkgs.lxqt.xdg-desktop-portal-lxqt
    ];

    environment.etc."xdg/lxqt/session.conf".text = ''
      COMPOSITOR=${cfg.waylandCompositor.package.pname}
    '';
  };
}
