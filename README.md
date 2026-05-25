# finix-config

Personal flake-based configuration for [finix](https://github.com/finix-community/finix). Currently a hotbed for experimentation. The end goal is to try and replicate my current [nixos configuration](https://github.com/deathbymanatee/nixos-dotfiles). My current use cases consist of development work, gaming, and audio production. Since finix is currently in an experimental state, so too is this configuration. I will write more documentation when I'm able to, or when the nix code isn't enough to explain why I did certain things the way I did them. 

So far, I've been able to install finix using this configuration on the following: 

- `qemu` (sway graphics don't work properly)
- `virtualbox` (some graphics require special configuration)
- bare metal

This config provides a few helper scripts to automate some routine maintenance, accessible using the following commands: 

- `rebuild`
    - activates a full system rebuild
- `maintenance`
    - collects garbage in nix store and deletes old generations
    - verifies store paths
    - updates flake inputs
    - rebuilds system

Invoke either of these with the `boot` parameter to remain on your current generation. 

# Credits

This configuration was scaffolded from [vitrial's minimal config / install guide](https://codeberg.org/vitrial/finix-config/src/branch/main). Their repository contains an excellent guide for starting your own minimal finix config if you don't want to copy my stuff.

# Requirements

- Nix Flakes
- Internet

# Installing

[Installation Instructions](./docs/INSTALL.md)

# TODOs

- [x] install in qemu
- [x] install on desktop
    - [x] set up steam
    - [ ] set up audio prod
        - [x] low latency audio input
        - [ ] install and configure plugins with yabridge
- [x] get docker working 
- [ ] convert laptop to finix
- [ ] convert server to finix

# Helpful links

[Finix](https://github.com/finix-community/finix)

[Finix Options Wiki](https://finix-community.github.io/finix/options.html)

[aanderse Config](https://github.com/aanderse/finix-config)

[Finit](https://github.com/finit-project/finit)
