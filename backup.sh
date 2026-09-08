#!/bin/sh
# ─────────────────────────────────────────────────────────────────────────────
# Celestial system backup — collects everything needed to rebuild this Gentoo
# box into ~/setup/ so the git repo becomes a "reinstall this machine" snapshot.
#
#   ./backup.sh          collect + stage into ~/setup/
#   ./backup.sh --push   collect, then git add/commit/push
#
# Runs entirely as astral — every source below is world-readable, no doas.
# Secrets (histories, tokens, cookies, browser profiles) are deliberately NOT
# copied; see the .gitignore and the explicit include lists below.
# ─────────────────────────────────────────────────────────────────────────────
set -eu

SETUP="$HOME/setup"
cd "$SETUP"

say() { printf '\033[36m>>> %s\033[0m\n' "$*"; }

# ── Portage config ──────────────────────────────────────────────────────────
say "portage config"
rm -rf portage && mkdir -p portage
rsync -a --exclude 'gnupg/' /etc/portage/ portage/
# make.profile is a symlink into /var/db/repos — record its target as plain text
readlink /etc/portage/make.profile > portage/make.profile.target
rm -f portage/make.profile

# ── Package / world state ───────────────────────────────────────────────────
say "package + world state"
cp /var/lib/portage/world                world
qlist -IRCv                            > pkglist.txt          # every pkg + version
qlist -ICv                             > pkglist-names.txt    # names only (reinstall)
eselect profile show     2>/dev/null   > profile.txt
eselect repository list -i 2>/dev/null > overlays.txt
emerge --info            2>/dev/null   > emerge-info.txt
portageq envvar USE      2>/dev/null   > use-flags.txt

# ── Kernel ──────────────────────────────────────────────────────────────────
say "kernel"
mkdir -p kernel
zcat /proc/config.gz > kernel/config
uname -a             > kernel/version
eselect kernel list 2>/dev/null > kernel/eselect.txt || true

# ── OpenRC services ─────────────────────────────────────────────────────────
say "services"
rc-update show -v      > services.txt
rc-status --all 2>&1   > services-status.txt || true

# ── System files (/etc bits not owned by Portage) ───────────────────────────
say "system files"
rm -rf system && mkdir -p system
cp /etc/fstab            system/fstab
cp /etc/doas.conf        system/doas.conf
cp /etc/default/grub     system/default-grub
cp -r /etc/conf.d        system/conf.d
cp /etc/locale.gen       system/locale.gen        2>/dev/null || true
cp /etc/timezone         system/timezone          2>/dev/null || true
cp /etc/hostname         system/hostname          2>/dev/null || true
lsblk -f                 > system/lsblk.txt
efibootmgr -v 2>/dev/null > system/efibootmgr.txt || true

# ── ~/.config (desktop + dev only — explicit whitelist) ─────────────────────
say "~/.config"
rm -rf config && mkdir -p config
for d in niri noctalia kitty fastfetch nvim yazi Thunar xfce4 obs-studio \
         MangoHud gtk-3.0 gtk-4.0 qt5ct qt6ct kdeglobals kdenliverc \
         autostart menus pipewire xdg-desktop-portal rc \
         starship.toml mimeapps.list user-dirs.dirs user-dirs.locale; do
    [ -e "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" config/ || true
done

# ── home dotfiles (explicit whitelist) ─────────────────────────────────────
say "home dotfiles"
rm -rf home && mkdir -p home
for f in .zshrc .zshenv .zprofile .bashrc .bash_profile .bash_logout .profile \
         .xinitrc .gtkrc-2.0 .gitconfig .inputrc .Xresources; do
    [ -e "$HOME/$f" ] && cp "$HOME/$f" "home/${f#.}" || true
done

say "collected into $SETUP"

# ── optional push ──────────────────────────────────────────────────────────
if [ "${1:-}" = "--push" ]; then
    say "git commit + push"
    git add -A
    if git diff --cached --quiet; then
        say "nothing changed"
    else
        git commit -m "system backup $(date +%Y-%m-%d\ %H:%M)"
        git push
    fi
fi
