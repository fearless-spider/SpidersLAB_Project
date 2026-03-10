# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SPIDER'S LAB — Boot Sequence (.zlogin)                           ║
# ║  TTY1: Matrix animation → seamless → Hyprland                     ║
# ║  Other TTYs: normal shell                                         ║
# ╚══════════════════════════════════════════════════════════════════════╝

if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then

    # ── PHASE 1: Cinematic boot animation ──
    spider-matrix

    # ── PHASE 2: Clear screen — zero flicker gap ──
    clear
    printf '\e[?25l'  # Hide cursor

    # ── PHASE 3: Launch Hyprland (seamless takeover) ──
    spider-launch

    # ── FALLBACK: If Hyprland exits/crashes ──
    printf '\e[?25h'  # Restore cursor
    echo ""
    echo -e "\e[31m╔═══════════════════════════════════════════════╗\e[0m"
    echo -e "\e[31m║  SPIDER'S LAB — Hyprland exited               ║\e[0m"
    echo -e "\e[31m╚═══════════════════════════════════════════════╝\e[0m"
    echo ""
    if [[ -f /tmp/hyprland.log ]]; then
        echo -e "\e[36m── Last 30 lines of /tmp/hyprland.log ──\e[0m"
        tail -30 /tmp/hyprland.log
    fi
    echo ""
    echo -e "\e[33mType 'spider-launch' to retry, or debug from this shell.\e[0m"
fi
