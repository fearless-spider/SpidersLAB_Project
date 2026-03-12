# Spider's LAB

A cyberpunk Arch Linux distribution built for hackers, pentesters, and developers who refuse to compromise on aesthetics. Every pixel tuned, every interaction cinematic.

> *"Mess with the best, die like the rest."*

## What is this?

Spider's LAB is a complete system theme and live ISO built on top of Arch Linux. It ships a fully configured Hyprland Wayland desktop with custom HUD overlays, AI integration, hacking tools, and a cohesive **Fluoromachine** color palette that runs from boot splash to lock screen.

The project includes:
- **Bootable ISO profile** (archiso) — build a full live/installable image
- **Theme installer** — apply Spider's LAB to an existing Arch/CachyOS system
- **hypr-hud-frame plugin** — cyberpunk window decorations for Hyprland

## Screenshots

*Coming soon*

## The Stack

| Layer | Component | Notes |
|-------|-----------|-------|
| Boot | Plymouth + spider-matrix | Animated spider web splash + BIOS POST hex dump |
| Login | Lemurs | Minimal TUI display manager, Fluoromachine themed |
| Compositor | Hyprland | Wayland, dwindle layout, GPU-accelerated |
| Bar | Waybar | Frosted glass HUD with GPU/VRAM/AI/network modules |
| Terminal | Kitty | 80% opacity, cyan cursor, JetBrainsMono Nerd |
| Editor | Neovim | lazy.nvim, Treesitter, Spider-Neon theme |
| Shell | Zsh | Spider-Sense AI, direnv glitch animations |
| Widgets | EWW | HUD sidebar with arc meters, syslog feed |
| Audio Viz | Glava | Radial mode, desktop-rendered |
| AI | Ollama | Local LLM (llama3.2), GPU-accelerated |
| Lock | Hyprlock | CRT terminal aesthetic, ASCII art banner |
| Launcher | Wofi | App launcher + clipboard history |
| Wallpaper | Hyprpaper + spider-wallgen | Procedural 4K neural-web artwork |

## Color Palette (Fluoromachine)

| Color | Hex | Usage |
|-------|-----|-------|
| Void Black | `#000000` | Backgrounds, shadows |
| Deep Purple | `#191724` | Base background |
| Spider Red | `#FC199A` | Accents, alerts, glow |
| Electric Cyan | `#61E2FF` | Text highlights, cursors |
| Neon Magenta | `#AF6DF9` | Borders, secondary accents |
| Text Primary | `#E8E3E3` | Foreground text |
| Text Dim | `#6B5F7B` | Inactive elements |

## Custom Tools

### Desktop & HUD

| Tool | Description |
|------|-------------|
| `spider-launch` | Hyprland wrapper — auto-detects VM vs bare metal, sets NVIDIA/Wayland env |
| `spider-cyberdeck` | Launches 3-panel terminal grid: btop + cmatrix + network monitor |
| `spider-power-menu` | Wofi-based power menu (shutdown/reboot/suspend/lock/logout) |
| `spider-wallgen` | Python procedural wallpaper generator — 4K neural-web artwork |
| `ghost-out` | Cinematic session wipe — glitch animation, evidence destruction, clean exit |

### Monitoring (Waybar modules)

| Module | Description |
|--------|-------------|
| `spider-aistatus` | Ollama GPU activity indicator (idle/active/generating) |
| `spider-neuralload` | VRAM monitor — shows loaded model and memory usage |
| `spider-nettraffic` | Real-time network RX/TX with human-readable rates |

### Development

| Tool | Description |
|------|-------------|
| `spider-summon` | Interactive devenv provisioner — 10 modules (Python, Go, Rust, Node, C++, Java, PostgreSQL, Redis, Docker, Security) |
| `spider()` | Zsh function — pipe anything to local LLM: `cat error.log \| spider "diagnose"` |
| direnv + glitch | Auto-activates project environments with CRT flicker effect |

### Boot Sequence

| Phase | Component |
|-------|-----------|
| 1. BIOS POST | Plymouth spiderslab theme — pulsing web + progress bar |
| 2. TTY init | spider-matrix — hex dump + ASCII banner + fake boot messages |
| 3. Boot sound | spider-bootsound — async cyberpunk chime via PipeWire |
| 4. TTY colors | spider-ttycolors — 16-color console palette remap |
| 5. Desktop | spider-launch — Hyprland with full autostart chain |

## hypr-hud-frame Plugin

Custom Hyprland plugin rendering cyberpunk HUD frames around windows:

- Neon borders with active/inactive color switching
- Chamfered (cut) corners with dark fill
- Glow effect with quadratic alpha falloff
- Pulse animation on active windows
- Hash marks, accent bars, dots, inner accent lines
- Configurable padding, colors, and per-class exclusion
- Toggle with `Super+Shift+F`

See [hypr-hud-frame/README.md](hypr-hud-frame/) for full documentation.

## Keybindings

| Binding | Action |
|---------|--------|
| `Super+T` | Terminal |
| `Super+Shift+T` | Hazard terminal (high-contrast) |
| `Super+Q` | Kill window |
| `Super+D` | App launcher (wofi) |
| `Super+E` | File manager |
| `Super+V` | Float toggle |
| `Super+F` | Fullscreen |
| `Super+L` | Lock screen |
| `Super+X` | Power menu |
| `Super+C` | Clipboard history |
| `Super+Shift+F` | Toggle HUD frame |
| `Super+Shift+H` | Toggle hazard shader |
| `Print` | Screenshot to clipboard |
| `Super+Print` | Screenshot to file |
| `Super+1-0` | Switch workspace I-X |

## Hardware Target

Optimized for:
- **GPU**: NVIDIA RTX 3060 (12GB VRAM) — Ollama, blur, glow, all enabled
- **Wayland**: Native Hyprland compositor
- **Audio**: PipeWire
- **VM fallback**: Auto-detects QEMU/VirtualBox/VMware with software rendering

## Installation

### Option 1: Build the ISO

Requires an Arch Linux host with `archiso` installed:

```bash
sudo mkarchiso -v -w /tmp/spiderslab-work -o /tmp/ iso_profile/
```

Boot the resulting ISO to get the full Spider's LAB experience.

### Option 2: Theme an existing system

Apply Spider's LAB to a running Arch or CachyOS installation:

```bash
sudo bash install-spiderslab-theme.sh
```

This installs: Plymouth theme, TTY colors, boot animation, boot sound, Hyprland/Waybar/Kitty/Neovim configs, all spider-* tools, lock screen, and shell configuration.

Reboot to see the full experience.

### Option 3: Cherry-pick components

All configs live in `iso_profile/airootfs/` mirroring the filesystem. Copy what you need:

```
iso_profile/airootfs/
├── etc/skel/.config/       # Hyprland, Waybar, Kitty, Neovim, EWW, Glava
├── etc/skel/.zshrc         # Shell config with Spider-Sense AI
├── usr/local/bin/          # All spider-* scripts
└── usr/share/              # Plymouth theme, wallpapers, sounds
```

## Packages

Full package list in [`packages.x86_64`](iso_profile/packages.x86_64). Highlights:

- **Desktop**: Hyprland, Waybar, Wofi, Dunst, Kitty, EWW, Glava
- **Hacking**: Metasploit, Wireshark, Nmap
- **Dev**: Neovim, direnv, Ollama (CUDA)
- **System**: PipeWire, Plymouth, Lemurs, btop, fastfetch

## License

MIT

## Author

**Spider's LAB** — [@fearless-spider](https://github.com/fearless-spider)
