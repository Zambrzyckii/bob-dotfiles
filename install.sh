#!/bin/bash

cd "$(dirname "$0")"

[[ ! -f /etc/arch-release ]] && echo "this is for arch btw" && exit 1
[[ ! -d .config ]] && echo "cant find .config" && exit 1

install_deps() {
  sudo pacman -S --needed hyprland hyprlock hypridle kitty thunar waybar awww swaync cava fastfetch starship kdeconnect grim slurp mpd mpc gnuplot ttf-jetbrains-mono-nerd alsa-utils networkmanager bluez bluez-utils wireplumber brightnessctl playerctl imagemagick quickshell qt6-5compat gpu-screen-recorder rmpc mpd-mpris wl-clipboard cliphist wofi jq chafa ripgrep xorg-xrdb pacman-contrib zsh zsh-autosuggestions zsh-syntax-highlighting bat eza firefox btop asciiquarium cmatrix neovim lazygit || exit 1

  if command -v yay &>/dev/null; then
    yay -S --needed python-pywal
  elif command -v paru &>/dev/null; then
    paru -S --needed python-pywal
  else
    echo "no aur helper, skipping aur packages"
    echo "run: yay -S python-pywal"
  fi

  sudo systemctl enable --now NetworkManager 2>/dev/null
  sudo systemctl enable --now bluetooth 2>/dev/null
}

install_configs() {
  mkdir -p ~/.config ~/.local/bin ~/wallpapers ~/screenshots ~/screen-recordings ~/bobby-dotfiles

  backup=~/.dotfiles-backup-$(date +%s)
  mkdir -p "$backup"

  for dir in hypr kitty waybar quickshell swaync scripts wal templates fastfetch cava; do
    [[ -e ~/.config/"$dir" ]] && mv ~/.config/"$dir" "$backup"/
    [[ -d .config/"$dir" ]] && cp -r .config/"$dir" ~/.config/
  done

  [[ -e ~/.config/starship.toml ]] && mv ~/.config/starship.toml "$backup"/
  cp .config/starship.toml ~/.config/

  for file in .zshrc .Xresources; do
    [[ -e ~/"$file" ]] && mv ~/"$file" "$backup"/
    cp "$file" ~/
  done

  [[ -d wallpapers ]] && cp -n wallpapers/* wallpapers/.current-blurred.jpg ~/wallpapers/ 2>/dev/null
  cp -rn Gif FastFetchLogos ~/bobby-dotfiles/

  echo '#!/bin/bash
pkill quickshell; nohup quickshell &>/dev/null &' > ~/.local/bin/start-quickshell.sh
  chmod +x ~/.local/bin/start-quickshell.sh

  grep -rl '/home/harman' ~/.config/hypr ~/.config/waybar ~/.config/quickshell 2>/dev/null | xargs -r sed -i "s|/home/harman|$HOME|g"

  chmod +x ~/.config/scripts/* 2>/dev/null
}

case "$1" in
  deps)
    install_deps
    echo "deps installed"
    ;;
  configs)
    install_configs
    echo "configs installed, log out and back in"
    ;;
  *)
    echo "first time? [y/n]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_deps
      install_configs
      echo ""
      echo "done, log out and back in"
      echo "then run: ~/.config/scripts/random-wallpaper.sh"
      echo "THANK YOU FOR INSTALLING :)"
    else
      install_configs
      echo ""
      echo "configs updated, log out and back in"
    fi
    ;;
esac