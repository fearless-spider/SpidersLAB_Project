# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SPIDER'S LAB — Electrical Hazard Custom Tab Bar                   ║
# ║  Purple/dark hazard stripes with ⚠ warning symbols.               ║
# ║  Matches Eww Electrical Hazard panel palette.                      ║
# ╚══════════════════════════════════════════════════════════════════════╝

from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

# Hazard colors — synced with eww $hazard-* vars
HAZARD_PURPLE_BG = as_rgb(color_as_int(0xAF, 0x6D, 0xF9))  # #AF6DF9 ($hazard-gold)
HAZARD_DARK_FG   = as_rgb(color_as_int(0x1E, 0x14, 0x32))  # #1E1432 ($hazard-bg)
HAZARD_DIM_BG    = as_rgb(color_as_int(0x1E, 0x14, 0x32))  # #1E1432
HAZARD_DIM_FG    = as_rgb(color_as_int(0x7B, 0x4D, 0xB0))  # #7B4DB0 ($hazard-dim)
HAZARD_GLOW_FG   = as_rgb(color_as_int(0xAF, 0x6D, 0xF9))  # purple for stripe fill


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw a single tab with Electrical Hazard styling."""

    if tab.is_active:
        fg = HAZARD_DARK_FG
        bg = HAZARD_PURPLE_BG
        prefix = " \u26a0 "   # ⚠
        suffix = " \u26a0 "
    else:
        fg = HAZARD_DIM_FG
        bg = HAZARD_DIM_BG
        prefix = "  "
        suffix = "  "

    # Separator between tabs
    if index > 0:
        screen.cursor.fg = HAZARD_GLOW_FG
        screen.cursor.bg = HAZARD_DIM_BG
        screen.draw("\u2502")  # │
        before += 1

    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.cursor.bold = tab.is_active

    # Build tab content: ⚠ {index}: {title} ⚠
    tab_title = f"{prefix}{index + 1}: {tab.title}{suffix}"

    if len(tab_title) > max_tab_length:
        tab_title = tab_title[:max_tab_length - 1] + "\u2026"  # …

    screen.draw(tab_title)
    end = screen.cursor.x

    # Fill remaining space on last tab with hazard stripe pattern
    if is_last:
        screen.cursor.fg = HAZARD_DIM_FG
        screen.cursor.bg = HAZARD_DIM_BG
        screen.cursor.bold = False
        remaining = screen.columns - end
        if remaining > 0:
            stripe = "\u2591" * remaining  # ░ light shade
            screen.draw(stripe[:remaining])

    return end
