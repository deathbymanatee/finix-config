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

  xSessionFile = pkgs.writeTextDir "share/xsessions/lxqt.desktop" ''
    [Desktop Entry]
    Name=LXQt (X11)
    Comment=LXQT Desktop
    Exec=${pkgs.lxqt.lxqt-session}/bin/startlxqt    
    Type=Application
    DesktopNames=LXQt
  '';

  waylandSessionFile = pkgs.writeTextDir "share/wayland-sessions/lxqt-wayland.desktop" ''
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

  removePackagesByName =
    packages: packagesToRemove:
    let
      namesToRemove = map lib.getName packagesToRemove;
    in
    lib.filter (x: !(lib.elem (lib.getName x) namesToRemove)) packages;

  packages = {
    # TODO opinionated package set
    preRequisitePackages = [
      kdePackages.kwindowsystem # provides some QT plugins needed by lxqt-panel
      kdePackages.libkscreen # provides plugins for screen management software
      pkgs.libfm
      pkgs.libfm-extra
      pkgs.menu-cache
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

      # x11 session
      # pkgs.lxqt-session

      # wayland session
      # pkgs.lxqt-wayland-session

      lxqt.lxqt-sudo
      lxqt.lxqt-themes

      # TODO
      lxqt.pavucontrol-qt

      ### CORE 2
      lxqt.lxqt-panel
      lxqt.lxqt-runner
      lxqt.pcmanfm-qt
      pkgs.xdg-utils
      pkgs.libnotify
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

    wayland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable the LXQt desktop environment's Wayland session.
        '';
      };
      compositor = lib.mkOption {
        type = lib.types.package;
        default = pkgs.labwc.override {
          inherit libinput;
          wlroots_0_19 = pkgs.wlroots_0_19.override { inherit libinput; };
        };
        description = ''
          The default Wayland compositor package to use.
        '';
      };
    };

    xsession = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable the LXQt desktop environment's X11 session.
        '';
      };
      windowManager = lib.mkOption {
        type = lib.types.package;
        default = pkgs.openbox;
        description = ''
          The default X11 window manager package to use.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      packages.preRequisitePackages
      ++ packages.corePackages
      ++ packages.optionalPackages
      ++ [ cfg.iconThemePackage ]
      ++ (removePackagesByName packages.optionalPackages cfg.excludePackages)
      ++ cfg.extraPackages

      # little messy, is there a better way to do this? lib.optional cfg.wayland.enable [...] results in a typeerror
      ++ (
        if cfg.wayland.enable then
          [
            (lib.hiPrio waylandSessionFile)
            cfg.wayland.compositor
            pkgs.lxqt.lxqt-wayland-session
          ]
        else
          (
            if cfg.xsession.enable then
              [
                (lib.hiPrio xSessionFile)
                cfg.xsession.windowManager
                pkgs.lxqt.lxqt-session

                # had issues without this package
                pkgs.libxcb-cursor
              ]
            else
              [ ]
          )
      );

    environment.pathsToLink = [
      "/share"
      "/share/icons"
      "/share/pixmaps"
    ];

    security.pam.environment = {
      XDG_CONFIG_DIRS.default = [ "/run/current-system/sw/share" ];
    };

    # probably not needed since default compositor is not kwin
    # security.wrappers = {
    #   kwin_wayland = {
    #     owner = "root";
    #     group = "root";
    #     capabilities = "cap_sys_nice+ep";
    #     source = "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland";
    #   };
    # };

    xdg.portal.portals = [
      pkgs.lxqt.xdg-desktop-portal-lxqt
    ];

    # this is also kind of messy
    environment.etc."xdg/lxqt/session.conf".text =
      if cfg.wayland.enable then
        "COMPOSITOR=${cfg.wayland.compositor.pname}"
      else
        (if cfg.xsession.enable then "WINDOW_MANAGER=${cfg.xsession.windowManager.pname}" else "");
  };
}
