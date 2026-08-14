{
  pkgs,
  lib,
  config,
  modules,
  ...
}:

with lib;
let
  cfg = config.modules.custom-packages;
  maintenance = pkgs.writeShellScriptBin "maintenance" ''
    nix-collect-garbage -d
    sudo nix-collect-garbage -d 
    sudo nix store verify --all
    cd ~/.config/finix-config
    hostname=$HOSTNAME
    nix flake update
    if [[ "$1" == "boot" ]]; then
      sudo nixos-rebuild boot --flake .#$hostname
    else
      sudo nixos-rebuild switch --flake .#$hostname
    fi
    nix store optimise
    sudo nix store optimise
  '';
  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    hostname=$HOSTNAME
    cd ~/.config/finix-config
    git add .
    if [[ "$1" == "boot" ]]; then
      sudo nixos-rebuild boot --flake .#$hostname
    else
      sudo nixos-rebuild switch --flake .#$hostname
    fi
  '';

  # nocalia battery hook
  low-battery = pkgs.writeShellScriptBin "low-battery" ''
    set -euo pipefail

    low_threshold="20"
    warning_threshold="10"
    critical_threshold="5"

    # Keep a tiny state file so the script can compare this event with the last one.
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/noctalia"
    state_file="$state_dir/battery-percent"

    # Noctalia provides these values whenever battery_percentage_changed fires.
    percent="''${NOCTALIA_BATTERY_PERCENT:-}"
    battery_state="''${NOCTALIA_BATTERY_STATE:-unknown}"

    # Ignore the event if the percentage is missing or not a whole number.
    [[ "$percent" =~ ^[0-9]+$ ]] || exit 0

    mkdir -p "$state_dir"

    # Read the previous percentage, then save the current percentage for next time.
    previous=""
    [[ -r "$state_file" ]] && previous="$(<"$state_file")"
    printf '%s\n' "$percent" > "$state_file"

    # Only warn while discharging, and only after we have a previous value to compare.
    [[ "$battery_state" == "discharging" ]] || exit 0
    [[ "$previous" =~ ^[0-9]+$ ]] || exit 0

    # Fire once when crossing below the threshold, not every time the battery changes below it.
    if (( previous >= low_threshold && percent < low_threshold )); then
      notify-send -u critical "Low battery" "Battery is ''${percent}%. You may want to plug in soon."
      brightnessctl set 50%
      powerprofilesctl set power-saver
    fi
    if (( previous >= critical_threshold && percent < critical_threshold )); then
      notify-send -u critical "Very low battery" "Battery is ''${percent}%. Plug in as soon as possible."
      brightnessctl set 30%
      powerprofilesctl set power-saver
    fi
  '';

in
{
  imports = [ modules.power-profiles-daemon ];
  options.modules.custom-packages = {
    enable = mkEnableOption "custom-packages";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      maintenance
      rebuild
    ]
    ++ lib.optionals config.services.power-profiles-daemon.enable [ low-battery ];
  };
}
