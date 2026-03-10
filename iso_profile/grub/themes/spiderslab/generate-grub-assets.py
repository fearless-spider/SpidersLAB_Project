#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  SPIDER'S LAB — GRUB Theme Asset Generator                        ║
║  CRT monitor aesthetic. 1995 terminal vibes.                      ║
║  "Mess with the best, die like the rest."                         ║
║                                                                    ║
║  Generates:                                                        ║
║    - background.png       (1920x1080 CRT with scanlines)          ║
║    - terminal_box_*.png   (menu box styling - 9-slice)            ║
║    - select_*.png         (selected item highlight)               ║
║    - progress_bar_*.png   (Hacking in progress... bar)            ║
║    - slider_*.png         (scrollbar assets)                      ║
║    - icons/*.png          (menu entry icons)                      ║
║                                                                    ║
║  Run: python3 generate-grub-assets.py                             ║
║  Requires: pip install Pillow                                     ║
╚══════════════════════════════════════════════════════════════════════╝
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os
import random

DIR = os.path.dirname(os.path.abspath(__file__))
ICONS_DIR = os.path.join(DIR, "icons")
os.makedirs(ICONS_DIR, exist_ok=True)

# ── Colors ────────────────────────────────────────────────────────────
BLACK = (0, 0, 0)
SPIDER_RED = (255, 0, 0)
CRT_GREEN = (0, 200, 0)
DIM_GREEN = (0, 80, 0)
ELECTRIC_CYAN = (0, 255, 255)
NEON_MAGENTA = (255, 0, 255)
DARK_RED = (40, 0, 0)
PHOSPHOR = (0, 30, 0)
SCANLINE_COLOR = (0, 0, 0, 70)

W, H = 1920, 1080


# ══════════════════════════════════════════════════════════════════════
#  1. BACKGROUND — CRT with scanlines, vignette, phosphor glow
# ══════════════════════════════════════════════════════════════════════
def generate_background():
    img = Image.new("RGB", (W, H), BLACK)
    draw = ImageDraw.Draw(img)

    # Subtle phosphor base tint
    for y in range(H):
        for x in range(0, W, 4):
            noise = random.randint(0, 6)
            img.putpixel((x, y), (noise, noise + random.randint(0, 3), noise))

    # CRT scanlines — every other line gets darkened
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    for y in range(0, H, 2):
        overlay_draw.line([(0, y), (W, y)], fill=(0, 0, 0, 50), width=1)

    # Additional thicker scanlines every 4th line for depth
    for y in range(0, H, 4):
        overlay_draw.line([(0, y), (W, y)], fill=(0, 0, 0, 25), width=1)

    img = Image.alpha_composite(img.convert("RGBA"), overlay)

    # Vignette — darken edges like a CRT tube
    vignette = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    vig_draw = ImageDraw.Draw(vignette)
    cx, cy = W // 2, H // 2
    max_dist = math.sqrt(cx * cx + cy * cy)
    for ring in range(0, 80, 1):
        radius_factor = 1.0 - (ring / 80.0) * 0.5
        alpha = int((ring / 80.0) * 120)
        r = int(max_dist * radius_factor)
        vig_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            outline=(0, 0, 0, alpha)
        )

    img = Image.alpha_composite(img, vignette)

    # Spider web watermark — very faint in background
    web_cx, web_cy = W // 2, H // 2 - 50
    web_overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    web_draw = ImageDraw.Draw(web_overlay)
    num_radials = 12
    max_radius = 350
    for i in range(num_radials):
        angle = (2 * math.pi * i) / num_radials
        ex = web_cx + int(max_radius * math.cos(angle))
        ey = web_cy + int(max_radius * math.sin(angle))
        web_draw.line([(web_cx, web_cy), (ex, ey)], fill=(255, 0, 0, 12), width=1)
    for ring in range(1, 7):
        r = int(max_radius * ring / 6)
        pts = []
        for i in range(num_radials):
            angle = (2 * math.pi * i) / num_radials
            pts.append((web_cx + int(r * math.cos(angle)), web_cy + int(r * math.sin(angle))))
        pts.append(pts[0])
        for j in range(len(pts) - 1):
            web_draw.line([pts[j], pts[j + 1]], fill=(255, 0, 0, 8), width=1)

    img = Image.alpha_composite(img, web_overlay)

    # Top banner area — faint red line
    draw2 = ImageDraw.Draw(img)
    draw2.line([(100, 180), (W - 100, 180)], fill=(255, 0, 0, 40), width=1)
    draw2.line([(100, H - 180), (W - 100, H - 180)], fill=(255, 0, 0, 40), width=1)

    # CRT corner glow — very subtle red in corners
    corner_glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cg_draw = ImageDraw.Draw(corner_glow)
    for r in range(200, 0, -2):
        alpha = int(8 * (1 - r / 200))
        cg_draw.ellipse([0 - r, 0 - r, r, r], fill=(255, 0, 0, alpha))
        cg_draw.ellipse([W - r, 0 - r, W + r, r], fill=(255, 0, 0, alpha))
        cg_draw.ellipse([0 - r, H - r, r, H + r], fill=(255, 0, 0, alpha))
        cg_draw.ellipse([W - r, H - r, W + r, H + r], fill=(255, 0, 0, alpha))

    img = Image.alpha_composite(img, corner_glow)

    img.convert("RGB").save(os.path.join(DIR, "background.png"))
    print("[+] background.png (1920x1080 CRT)")


# ══════════════════════════════════════════════════════════════════════
#  2. TERMINAL BOX — 9-slice styled menu container
# ══════════════════════════════════════════════════════════════════════
def generate_terminal_box():
    # GRUB uses styled_box with directional slices:
    # {c, n, s, e, w, ne, nw, se, sw}
    size = 8
    border_color = (255, 0, 0, 100)
    fill_color = (0, 0, 0, 200)
    corner_color = (255, 0, 0, 160)

    parts = {
        "c":  (fill_color,),
        "n":  (border_color,),
        "s":  (border_color,),
        "e":  (border_color,),
        "w":  (border_color,),
        "nw": (corner_color,),
        "ne": (corner_color,),
        "sw": (corner_color,),
        "se": (corner_color,),
    }

    for name, (color,) in parts.items():
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        if name == "c":
            draw.rectangle([0, 0, size - 1, size - 1], fill=color)
        elif name == "n":
            draw.line([(0, size - 1), (size - 1, size - 1)], fill=color, width=1)
            draw.rectangle([0, 0, size - 1, size - 2], fill=fill_color)
        elif name == "s":
            draw.line([(0, 0), (size - 1, 0)], fill=color, width=1)
            draw.rectangle([0, 1, size - 1, size - 1], fill=fill_color)
        elif name == "w":
            draw.line([(size - 1, 0), (size - 1, size - 1)], fill=color, width=1)
            draw.rectangle([0, 0, size - 2, size - 1], fill=fill_color)
        elif name == "e":
            draw.line([(0, 0), (0, size - 1)], fill=color, width=1)
            draw.rectangle([1, 0, size - 1, size - 1], fill=fill_color)
        else:
            # Corners — L-shaped bracket
            draw.rectangle([0, 0, size - 1, size - 1], fill=fill_color)
            if "n" in name:
                draw.line([(0, size - 1), (size - 1, size - 1)], fill=color, width=1)
            if "s" in name:
                draw.line([(0, 0), (size - 1, 0)], fill=color, width=1)
            if "w" in name:
                draw.line([(size - 1, 0), (size - 1, size - 1)], fill=color, width=1)
            if "e" in name:
                draw.line([(0, 0), (0, size - 1)], fill=color, width=1)

        img.save(os.path.join(DIR, f"terminal_box_{name}.png"))

    print("[+] terminal_box_*.png (9-slice menu container)")


# ══════════════════════════════════════════════════════════════════════
#  3. SELECTION HIGHLIGHT — selected menu item
# ══════════════════════════════════════════════════════════════════════
def generate_selection():
    size = 8
    sel_color = (255, 0, 0, 50)
    sel_border = (255, 0, 0, 180)

    parts = {
        "c":  sel_color,
        "n":  sel_border,
        "s":  sel_border,
        "e":  sel_border,
        "w":  sel_border,
        "nw": sel_border,
        "ne": sel_border,
        "sw": sel_border,
        "se": sel_border,
    }

    for name, color in parts.items():
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        if name == "c":
            draw.rectangle([0, 0, size - 1, size - 1], fill=color)
        elif name in ("n", "s"):
            draw.line([(0, size // 2), (size - 1, size // 2)], fill=color, width=1)
        elif name in ("e", "w"):
            draw.line([(size // 2, 0), (size // 2, size - 1)], fill=color, width=1)
        else:
            draw.rectangle([0, 0, size - 1, size - 1], fill=color)

        img.save(os.path.join(DIR, f"select_{name}.png"))

    print("[+] select_*.png (selection highlight)")


# ══════════════════════════════════════════════════════════════════════
#  4. PROGRESS BAR — "Hacking in progress..." style
# ══════════════════════════════════════════════════════════════════════
def generate_progress_bar():
    bar_h = 20

    # Highlight (filled portion) — cyan with scanlines
    highlight = Image.new("RGBA", (bar_h, bar_h), (0, 0, 0, 0))
    hd = ImageDraw.Draw(highlight)
    for y in range(bar_h):
        alpha = 200 if y % 2 == 0 else 140
        hd.line([(0, y), (bar_h - 1, y)], fill=(0, 255, 255, alpha))

    parts_hl = {"c": highlight}
    for name, img in parts_hl.items():
        img.save(os.path.join(DIR, f"progress_highlight_{name}.png"))

    # Background (unfilled portion) — dark with scanlines
    bg = Image.new("RGBA", (bar_h, bar_h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bg)
    for y in range(bar_h):
        alpha = 120 if y % 2 == 0 else 80
        bd.line([(0, y), (bar_h - 1, y)], fill=(30, 0, 0, alpha))

    parts_bg = {"c": bg}
    for name, img in parts_bg.items():
        img.save(os.path.join(DIR, f"progress_bar_{name}.png"))

    print("[+] progress_bar_*.png + progress_highlight_*.png")


# ══════════════════════════════════════════════════════════════════════
#  5. SCROLLBAR / SLIDER
# ══════════════════════════════════════════════════════════════════════
def generate_slider():
    sw, sh = 8, 20

    # Slider thumb
    thumb = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    td = ImageDraw.Draw(thumb)
    td.rectangle([1, 1, sw - 2, sh - 2], fill=(255, 0, 0, 160), outline=(255, 0, 0, 200))
    thumb.save(os.path.join(DIR, "slider_c.png"))

    # Slider track
    track = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    tkd = ImageDraw.Draw(track)
    tkd.rectangle([2, 0, sw - 3, sh - 1], fill=(40, 0, 0, 80))
    track.save(os.path.join(DIR, "scrollbar_c.png"))

    print("[+] slider_c.png + scrollbar_c.png")


# ══════════════════════════════════════════════════════════════════════
#  6. MENU ICONS — 32x32 pixel art style
# ══════════════════════════════════════════════════════════════════════
def generate_icons():
    icon_size = 36

    def make_icon(name, draw_func):
        img = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        draw_func(draw, icon_size)
        img.save(os.path.join(ICONS_DIR, f"{name}.png"))

    # Spider / arch icon — simplified spider shape
    def draw_arch(d, s):
        cx, cy = s // 2, s // 2
        # Body
        d.ellipse([cx - 4, cy - 3, cx + 4, cy + 3], fill=SPIDER_RED)
        d.ellipse([cx - 2, cy - 6, cx + 2, cy - 2], fill=SPIDER_RED)
        # Legs
        for angle_offset in [-45, -25, 25, 45]:
            angle = math.radians(angle_offset)
            for side in [-1, 1]:
                ex = cx + int(12 * math.cos(angle) * side)
                ey = cy + int(10 * math.sin(angle))
                d.line([(cx + 3 * side, cy), (ex, ey)], fill=SPIDER_RED, width=1)

    def draw_shutdown(d, s):
        cx, cy = s // 2, s // 2
        r = 10
        d.arc([cx - r, cy - r, cx + r, cy + r], start=220, end=320, fill=SPIDER_RED, width=2)
        d.line([(cx, cy - r - 2), (cx, cy - 2)], fill=SPIDER_RED, width=2)

    def draw_reboot(d, s):
        cx, cy = s // 2, s // 2
        r = 10
        d.arc([cx - r, cy - r, cx + r, cy + r], start=0, end=300, fill=SPIDER_RED, width=2)
        # Arrow
        d.polygon([(cx + r - 2, cy - r - 3), (cx + r + 3, cy - r + 2), (cx + r - 2, cy - r + 2)],
                  fill=SPIDER_RED)

    def draw_efi(d, s):
        cx, cy = s // 2, s // 2
        d.rectangle([cx - 8, cy - 8, cx + 8, cy + 8], outline=ELECTRIC_CYAN, width=1)
        d.rectangle([cx - 5, cy - 5, cx + 5, cy + 5], outline=ELECTRIC_CYAN, width=1)
        d.line([(cx - 8, cy), (cx - 5, cy)], fill=ELECTRIC_CYAN, width=1)
        d.line([(cx + 5, cy), (cx + 8, cy)], fill=ELECTRIC_CYAN, width=1)

    def draw_memtest(d, s):
        cx, cy = s // 2, s // 2
        # RAM chip shape
        d.rectangle([cx - 10, cy - 5, cx + 10, cy + 5], outline=CRT_GREEN, width=1)
        for i in range(-8, 9, 4):
            d.line([(cx + i, cy + 5), (cx + i, cy + 9)], fill=CRT_GREEN, width=1)

    make_icon("arch", draw_arch)
    make_icon("shutdown", draw_shutdown)
    make_icon("reboot", draw_reboot)
    make_icon("efi", draw_efi)
    make_icon("memtest86", draw_memtest)

    print("[+] icons/*.png (5 menu icons)")


# ══════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════╗")
    print("║  SPIDER'S LAB — GRUB Theme Asset Generator    ║")
    print("╚═══════════════════════════════════════════════╝")

    random.seed(1995)  # Deterministic CRT noise. 1995, obviously.

    generate_background()
    generate_terminal_box()
    generate_selection()
    generate_progress_bar()
    generate_slider()
    generate_icons()

    print("\n[✓] All GRUB theme assets generated in:", DIR)
