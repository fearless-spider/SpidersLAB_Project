# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# ── SPIDER'S LAB — Auto-start Hyprland on TTY1 ──
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    # Don't use exec — if Hyprland crashes, drop back to shell with log
    spider-launch

    # If we get here, Hyprland exited/crashed
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
