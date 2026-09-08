#!/bin/sh
# Shell + editor stack (ported from eeepy home.nix). Run with doas.
set -u
AKW=/etc/portage/package.accept_keywords/desktop
grep -q 'app-shells/zoxide' "$AKW" 2>/dev/null || printf '\napp-shells/zoxide ~amd64\n' >> "$AKW"

emerge -vn --keep-going \
    app-shells/zsh \
    app-shells/zsh-completions \
    app-shells/zsh-syntax-highlighting \
    app-shells/zsh-autosuggestions \
    app-shells/starship \
    app-shells/zoxide \
    app-shells/fzf \
    app-editors/neovim \
    app-crypt/age \
    media-video/mpv \
    media-sound/playerctl \
    media-gfx/imv \
    x11-themes/tela-icon-theme \
    x11-themes/gtk-engines-murrine \
    media-fonts/fontawesome \
    app-misc/cmatrix \
    games-misc/asciiquarium

usermod -s /bin/zsh astral && echo ">>> default shell -> zsh (next login)"
gtk-update-icon-cache -f -t /usr/share/icons/Tela-pink-dark 2>/dev/null || true

echo
echo ">>> done. Open a new terminal for zsh + starship + fastfetch."
echo ">>> first 'nvim' bootstraps lazy.nvim (treesitter/lualine/gitsigns/synthwave84)."
