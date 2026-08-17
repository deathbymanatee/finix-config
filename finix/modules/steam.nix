{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.steam;

in
{
  options.modules.steam = {
    enable = mkEnableOption "steam";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.steam;
      defaultText = lib.literalExpression "pkgs.steam";
      example = lib.literalExpression ''
        pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraLibraries = p: with p; [
            atk
          ];
        }
      '';
      apply =
        steam:
        steam.override (prev: {
          extraPkgs = p: (cfg.extraPackages ++ lib.optionals (prev ? extraPkgs) (prev.extraPkgs p));
        });
      description = ''
        The Steam package to use. Additional libraries are added from the system
        configuration to ensure graphics work properly.

        Use this option to customise the Steam package rather than adding your
        custom Steam to {option}`environment.systemPackages` yourself.
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          gamescope
        ]
      '';
      description = ''
        Additional packages to add to the Steam environment.
      '';
    };

    fontPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      # `fonts.packages` is a list of paths now, filter out which are not packages
      default = builtins.filter lib.types.package.check config.fonts.packages;
      defaultText = lib.literalExpression "builtins.filter lib.types.package.check config.fonts.packages";
      example = lib.literalExpression "with pkgs; [ source-han-sans ]";
      description = ''
        Font packages to use in Steam.

        Defaults to system fonts, but could be overridden to use other fonts — useful for users who would like to customize CJK fonts used in Steam. According to the [upstream issue](https://github.com/ValveSoftware/steam-for-linux/issues/10422#issuecomment-1944396010), Steam only follows the per-user fontconfig configuration.
      '';
    };
  };

  config = mkIf cfg.enable {
    modules.steam.extraPackages = [
      pkgs.kdePackages.breeze
      pkgs.kdePackages.breeze-icons
      pkgs.kdePackages.breeze-gtk
    ];

    environment.systemPackages = with pkgs; [
      cfg.package
      cfg.package.run
      steam-run
      protonup-qt
      gamescope
    ];
  };
}
