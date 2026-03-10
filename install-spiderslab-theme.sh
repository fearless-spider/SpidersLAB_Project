#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SPIDER'S LAB — System Theme Installer                            ║
# ║  Applies Spider's LAB theme to running CachyOS installation.      ║
# ║  Run: sudo bash install-spiderslab-theme.sh                       ║
# ╚══════════════════════════════════════════════════════════════════════╝

set -e

RED='\e[31m'
CYAN='\e[36m'
GREEN='\e[32m'
DIM='\e[2m'
BOLD='\e[1m'
RESET='\e[0m'

USER_HOME="/home/f3ar13ss"
ISO="$USER_HOME/SpidersLAB_Project/iso_profile/airootfs"

ok()   { echo -e "  ${DIM}[${RESET}${CYAN} OK ${DIM}]${RESET}  ${GREEN}$1${RESET}"; }
info() { echo -e "  ${DIM}[${RESET}${RED}....${DIM}]${RESET}  $1"; }
warn() { echo -e "  ${DIM}[${RESET}${RED}${BOLD}WARN${DIM}]${RESET}  ${RED}$1${RESET}"; }

echo ""
echo -e "${RED}${BOLD}"
echo "   ███████╗██████╗ ██╗██████╗ ███████╗██████╗ ██╗███████╗"
echo "   ██╔════╝██╔══██╗██║██╔══██╗██╔════╝██╔══██╗╚═╝██╔════╝"
echo "   ███████╗██████╔╝██║██║  ██║█████╗  ██████╔╝   ███████╗"
echo "   ╚════██║██╔═══╝ ██║██║  ██║██╔══╝  ██╔══██╗   ╚════██║"
echo "   ███████║██║     ██║██████╔╝███████╗██║  ██║   ███████║"
echo "   ╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚══════╝"
echo -e "${RESET}"
echo -e "${CYAN}           System Theme Installer${RESET}"
echo ""
echo -e "${RED}  ─────────────────────────────────────────────${RESET}"
echo ""

# ── Check root ────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    warn "This script must be run as root (sudo)."
    exit 1
fi

# ══════════════════════════════════════════════════════════════════════
#  1. PLYMOUTH THEME
# ══════════════════════════════════════════════════════════════════════
info "Installing Plymouth theme..."

cp -r "$ISO/usr/share/plymouth/themes/spiderslab" \
      /usr/share/plymouth/themes/spiderslab
ok "Plymouth theme files copied"

# Set as default theme
cat > /etc/plymouth/plymouthd.conf << 'EOF'
[Daemon]
Theme=spiderslab
ShowDelay=0
DeviceTimeout=8
EOF
ok "Plymouth theme set to 'spiderslab'"

# Rebuild initramfs with plymouth
info "Rebuilding initramfs (this takes a moment)..."
mkinitcpio -P
ok "Initramfs rebuilt with Plymouth"

# ══════════════════════════════════════════════════════════════════════
#  2. TTY COLORS — kernel params + vconsole
# ══════════════════════════════════════════════════════════════════════
info "Configuring TTY colors..."

# vconsole.conf — Terminus bitmap font
cat > /etc/vconsole.conf << 'EOF'
KEYMAP=pl
FONT=ter-v18n
EOF
ok "vconsole.conf updated (Terminus font)"

# Install TTY color script
cp "$ISO/usr/local/bin/spider-ttycolors" /usr/local/bin/spider-ttycolors
chmod 755 /usr/local/bin/spider-ttycolors
ok "spider-ttycolors script installed"

# Install systemd service
cp "$ISO/etc/systemd/system/spider-ttycolors.service" \
   /etc/systemd/system/spider-ttycolors.service
systemctl daemon-reload
systemctl enable spider-ttycolors.service
ok "spider-ttycolors.service enabled"

# Update rEFInd kernel params with TTY colors + splash
REFIND_CONF="/boot/refind_linux.conf"
if [ -f "$REFIND_CONF" ]; then
    info "Updating rEFInd kernel parameters..."

    # Backup original
    cp "$REFIND_CONF" "${REFIND_CONF}.bak"

    VT_COLORS="vt.default_red=0,255,0,255,0,255,0,212,51,255,51,255,51,255,102,255 vt.default_grn=0,0,200,170,102,0,255,212,51,51,255,204,153,102,255,255 vt.default_blu=0,0,0,0,255,255,255,212,51,51,153,51,255,255,255,255"

    cat > "$REFIND_CONF" << REFEOF
"Spider's LAB"    "quiet zswap.enabled=0 nowatchdog splash vt.global_cursor_default=0 loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 ${VT_COLORS} rw rootflags=subvol=/@ root=UUID=74abeb7e-6b9d-4b81-a4b0-86a683662536"
"Spider's LAB (verbose)"    "zswap.enabled=0 nowatchdog rw rootflags=subvol=/@ root=UUID=74abeb7e-6b9d-4b81-a4b0-86a683662536"
"Boot to single-user mode"    "quiet zswap.enabled=0 nowatchdog splash rw rootflags=subvol=/@ root=UUID=74abeb7e-6b9d-4b81-a4b0-86a683662536 single"
REFEOF
    ok "rEFInd config updated (backup: refind_linux.conf.bak)"
else
    warn "rEFInd config not found at $REFIND_CONF — update kernel params manually"
fi

# ══════════════════════════════════════════════════════════════════════
#  3. BOOT ANIMATION — spider-matrix
# ══════════════════════════════════════════════════════════════════════
info "Installing boot animation..."

cp "$ISO/usr/local/bin/spider-matrix" /usr/local/bin/spider-matrix
chmod 755 /usr/local/bin/spider-matrix
ok "spider-matrix installed"

# ══════════════════════════════════════════════════════════════════════
#  4. BOOT SOUND
# ══════════════════════════════════════════════════════════════════════
info "Installing boot sound..."

mkdir -p /usr/share/spiderslab/sounds
cp "$ISO/usr/share/spiderslab/sounds/startup.wav" \
   /usr/share/spiderslab/sounds/startup.wav
ok "startup.wav installed"

cp "$ISO/usr/local/bin/spider-bootsound" /usr/local/bin/spider-bootsound
chmod 755 /usr/local/bin/spider-bootsound
ok "spider-bootsound script installed"

cp "$ISO/etc/systemd/system/spider-bootsound.service" \
   /etc/systemd/system/spider-bootsound.service
systemctl daemon-reload
systemctl enable spider-bootsound.service
ok "spider-bootsound.service enabled"

# ══════════════════════════════════════════════════════════════════════
#  5. SPIDER-LAUNCH WRAPPER
# ══════════════════════════════════════════════════════════════════════
info "Installing spider-launch..."

cp "$ISO/usr/local/bin/spider-launch" /usr/local/bin/spider-launch
chmod 755 /usr/local/bin/spider-launch
ok "spider-launch installed"

cp "$ISO/usr/local/bin/spider-power-menu" /usr/local/bin/spider-power-menu
chmod 755 /usr/local/bin/spider-power-menu
ok "spider-power-menu installed"

cp "$ISO/usr/local/bin/spider-nettraffic" /usr/local/bin/spider-nettraffic
chmod 755 /usr/local/bin/spider-nettraffic
ok "spider-nettraffic installed"

cp "$ISO/usr/local/bin/spider-summon" /usr/local/bin/spider-summon
chmod 755 /usr/local/bin/spider-summon
ok "spider-summon installed"

cp "$ISO/usr/local/bin/spider-neuralload" /usr/local/bin/spider-neuralload
chmod 755 /usr/local/bin/spider-neuralload
ok "spider-neuralload installed"

cp "$ISO/usr/local/bin/ghost-out" /usr/local/bin/ghost-out
chmod 755 /usr/local/bin/ghost-out
ok "ghost-out installed"

# ══════════════════════════════════════════════════════════════════════
#  6. USER CONFIGS (Hyprland, Waybar, Kitty, Fastfetch)
# ══════════════════════════════════════════════════════════════════════
info "Installing user configs..."

SKEL="$ISO/etc/skel/.config"

# Backup existing configs
for dir in hypr waybar kitty fastfetch nvim; do
    if [ -d "$USER_HOME/.config/$dir" ]; then
        cp -r "$USER_HOME/.config/$dir" "$USER_HOME/.config/${dir}.bak.$(date +%s)" 2>/dev/null
    fi
done
ok "Existing configs backed up (.bak.*)"

# Copy new configs
for dir in hypr waybar kitty fastfetch nvim; do
    mkdir -p "$USER_HOME/.config/$dir"
    cp -r "$SKEL/$dir/"* "$USER_HOME/.config/$dir/"
done
chown -R f3ar13ss:f3ar13ss "$USER_HOME/.config/"{hypr,waybar,kitty,fastfetch,nvim}
ok "Hyprland, Waybar, Kitty, Fastfetch, Neovim configs installed"

# ══════════════════════════════════════════════════════════════════════
#  7. .ZLOGIN — boot animation + Hyprland autostart
# ══════════════════════════════════════════════════════════════════════
info "Setting up .zlogin..."

# Backup existing
[ -f "$USER_HOME/.zlogin" ] && cp "$USER_HOME/.zlogin" "$USER_HOME/.zlogin.bak.$(date +%s)"

cat > "$USER_HOME/.zlogin" << 'ZEOF'
# ── SPIDER'S LAB — Boot Sequence ──
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    # Cinematic boot animation
    spider-matrix

    # Seamless transition
    clear
    printf '\e[?25l'

    # Launch Hyprland
    spider-launch

    # Fallback if Hyprland exits
    printf '\e[?25h'
    echo ""
    echo -e "\e[31m╔═══════════════════════════════════════════════╗\e[0m"
    echo -e "\e[31m║  SPIDER'S LAB — Hyprland exited               ║\e[0m"
    echo -e "\e[31m╚═══════════════════════════════════════════════╝\e[0m"
    echo ""
    if [[ -f /tmp/hyprland.log ]]; then
        echo -e "\e[36m── Last 30 lines of /tmp/hyprland.log ──\e[0m"
        tail -30 /tmp/hyprland.log
    fi
    echo -e "\e[33mType 'spider-launch' to retry.\e[0m"
fi
ZEOF
chown f3ar13ss:f3ar13ss "$USER_HOME/.zlogin"
ok ".zlogin configured"

# ══════════════════════════════════════════════════════════════════════
#  DONE
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${RED}  ─────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${CYAN}${BOLD}SPIDER'S LAB theme installed successfully.${RESET}"
echo ""
echo -e "  ${GREEN}Installed:${RESET}"
echo -e "    Plymouth theme    → spiderslab (breathing spider web)"
echo -e "    TTY colors        → Red/Cyan/Black palette (kernel + service)"
echo -e "    Boot animation    → spider-matrix (7-phase ASCII stream)"
echo -e "    Boot sound        → startup.wav (cyberpunk chime)"
echo -e "    Hyprland config   → Spider's LAB Zero Cool edition"
echo -e "    Waybar            → Glassmorphism HUD"
echo -e "    Kitty             → 80% opacity, cyan beam cursor"
echo -e "    Fastfetch         → Custom ASCII + RTX 3060 stats"
echo -e "    Neovim            → Spider-Neon theme + lazy.nvim HUD"
echo -e "    CRT Shader        → Scanlines + chromatic aberration + vignette"
echo -e "    Network HUD       → spider-nettraffic (Waybar traffic module)"
echo -e "    Devenv Summon     → spider-summon (Nix devenv provisioner)"
echo -e "    Direnv + Glitch   → Auto-activation with CRT flicker"
echo -e "    Spider-Sense      → Local AI via Ollama (spider command)"
echo -e "    Neural Load       → spider-neuralload (VRAM Waybar module)"
echo -e "    Hyprlock          → Cyber-Lock Screen (CRT terminal aesthetic)"
echo -e "    Ghost Mode        → ghost-out (trace wipe + shutdown)"
echo -e "    rEFInd            → Updated kernel params"
echo ""
echo -e "  ${RED}${BOLD}Reboot to see the full experience.${RESET}"
echo ""
