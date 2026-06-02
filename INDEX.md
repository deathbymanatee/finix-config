[finix logo here eventually]

# `finix`

`finix` is an experimental Linux distribution built around the Nix package manager. It uses [finit](https://github.com/finit-project/finit) instead of systemd as its init system and service supervisor. By default, it seeks to be: 

- minimal
- unopinionated
- *extremely* flexible

`finix` is fully capable as a daily driver desktop, and it can also serve as a lightweight server OS. 

# Installation

Currently, `finix` does not yet have a disk image available to download. Installation will need to take place from a standard NixOS image, which can be downloaded [here](https://nixos.org/download#nixos-iso). You may download and burn either the minimal image or the graphical image and the steps will remain the same. 

For an installation guide, please see one of the following repositories on Codeberg. Credits to [@xZecora](https://github.com/xZecora) (a.k.a. Vitrial) for writing these.

- [flake-based setup](https://codeberg.org/vitrial/finix-config)
- [channel-based setup](https://codeberg.org/vitrial/finix-channel-install)

# See also

[Finix Options Wiki](https://finix-community.github.io/finix/options.html)

[Finit Project](https://finit-project.github.io/)

[Finix Profiles](https://github.com/finix-community/profiles)

[Finix Community Modules](https://github.com/finix-community/community-modules/)
