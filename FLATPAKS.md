# flatpak

Optional flatpaks are documented here. 

## spotify

`flatpak install spotify`

ad blocker

`bash <(curl -sSL https://spotx-official.github.io/run.sh)`

requires: 

- `pkgs.perl`
- `pkgs.zip`
- `pkgs.unzip`

## discord 

fix for the ugly adwaita icon showing instead of breeze cursors (my preferred cursor theme)

`flatpak --user override com.discordapp.Discord --filesystem=/run/current-system/sw/share/icons/breeze_cursors/:ro`
