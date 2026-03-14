#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  SPIDER'S LAB — Plymouth Asset Generator v2                        ║
║  System Initialization HUD — Sci-Fi boot sequence                  ║
║                                                                    ║
║  Generates: logo.png, hex-grid.png, scanline.png,                  ║
║             hud-bar.png, hud-fill.png,                             ║
║             corner-tl.png, corner-tr.png,                          ║
║             corner-bl.png, corner-br.png,                          ║
║             hud-ring.png                                           ║
║                                                                    ║
║  Run: python3 generate-assets.py                                   ║
║  Requires: pip install Pillow                                      ║
╚══════════════════════════════════════════════════════════════════════╝
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ── Fluoromachine Palette ──────────────────────────────────────────
HOT_PINK    = (252, 25, 154)
CYAN        = (97, 226, 255)
PURPLE      = (175, 109, 249)
DEEP_BG     = (10, 8, 16)
DIM_PURPLE  = (40, 30, 60)
WHITE       = (205, 214, 244)
DIM_CYAN    = (97, 226, 255, 40)


def get_font(size, bold=False):
    """Try to load JetBrains Mono, fall back gracefully."""
    names = [
        f"/usr/share/fonts/TTF/JetBrainsMonoNerdFont-{'Bold' if bold else 'Regular'}.ttf",
        f"/usr/share/fonts/truetype/dejavu/DejaVuSansMono{'-Bold' if bold else ''}.ttf",
    ]
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except (OSError, IOError):
            continue
    return ImageFont.load_default()


# ── 1. HEX GRID — subtle background overlay ───────────────────────
def generate_hex_grid():
    """Generates a subtle hexagonal grid pattern."""
    w, h = 1920, 1080
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    hex_size = 30
    row_h = int(hex_size * math.sqrt(3))
    col_w = int(hex_size * 1.5)

    for row in range(-1, h // row_h + 2):
        for col in range(-1, w // col_w + 2):
            cx = col * col_w
            cy = row * row_h + (col % 2) * (row_h // 2)

            # Distance from screen center for vignette
            dx = (cx - w / 2) / (w / 2)
            dy = (cy - h / 2) / (h / 2)
            dist = math.sqrt(dx * dx + dy * dy)
            alpha = max(0, int(18 * (1.0 - dist * 0.7)))

            if alpha < 2:
                continue

            points = []
            for i in range(6):
                angle = math.radians(60 * i + 30)
                px = cx + hex_size * math.cos(angle)
                py = cy + hex_size * math.sin(angle)
                points.append((px, py))

            draw.polygon(points, outline=(*CYAN[:3], alpha))

    img.save(os.path.join(OUTPUT_DIR, "hex-grid.png"))
    print("[+] hex-grid.png generated")


# ── 2. LOGO — Spider's LAB with neon glow ─────────────────────────
def generate_logo():
    """Spider's LAB title with hot pink glow."""
    w, h = 700, 140
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    font_big = get_font(52, bold=True)
    font_small = get_font(16)

    title = "SPIDER'S LAB"
    bbox = draw.textbbox((0, 0), title, font=font_big)
    tw = bbox[2] - bbox[0]
    tx = (w - tw) // 2
    ty = 10

    # Glow layer
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.text((tx, ty), title, fill=(*HOT_PINK, 100), font=font_big)
    glow = glow.filter(ImageFilter.GaussianBlur(radius=8))

    # Second glow pass — wider
    glow2 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow2_draw = ImageDraw.Draw(glow2)
    glow2_draw.text((tx, ty), title, fill=(*HOT_PINK, 40), font=font_big)
    glow2 = glow2.filter(ImageFilter.GaussianBlur(radius=16))

    # Sharp text
    draw.text((tx, ty), title, fill=(*HOT_PINK, 255), font=font_big)

    # Subtitle
    sub = "SYSTEM INITIALIZATION"
    bbox2 = draw.textbbox((0, 0), sub, font=font_small)
    sw = bbox2[2] - bbox2[0]
    sx = (w - sw) // 2
    draw.text((sx, 80), sub, fill=(*CYAN, 180), font=font_small)

    # Thin line under subtitle
    line_w = 200
    lx = (w - line_w) // 2
    draw.line([(lx, 105), (lx + line_w, 105)], fill=(*CYAN, 60), width=1)

    result = Image.alpha_composite(glow2, glow)
    result = Image.alpha_composite(result, img)
    result.save(os.path.join(OUTPUT_DIR, "logo.png"))
    print("[+] logo.png generated")


# ── 3. SCANLINE — horizontal sweep ────────────────────────────────
def generate_scanline():
    """Horizontal scan line with fade edges."""
    w, h = 1920, 6
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    for x in range(w):
        # Fade at edges
        edge_dist = min(x, w - x) / (w * 0.3)
        alpha = min(1.0, edge_dist)

        for y in range(h):
            # Brightest at center of line height
            y_fade = 1.0 - abs(y - h / 2) / (h / 2)
            a = int(60 * alpha * y_fade)
            img.putpixel((x, y), (*CYAN[:3], a))

    img.save(os.path.join(OUTPUT_DIR, "scanline.png"))
    print("[+] scanline.png generated")


# ── 4. HUD PROGRESS BAR — chamfered corners ───────────────────────
def generate_hud_bar():
    """Progress bar container with chamfered (cut) corners like HUD frame."""
    bar_w, bar_h = 400, 20
    notch = 6  # chamfer size
    img = Image.new("RGBA", (bar_w, bar_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Chamfered rectangle outline
    color = (*CYAN[:3], 80)
    points = [
        (notch, 0),
        (bar_w - 1, 0),
        (bar_w - 1, bar_h - 1 - notch),
        (bar_w - 1 - notch, bar_h - 1),
        (0, bar_h - 1),
        (0, notch),
    ]
    draw.polygon(points, outline=color)

    # Dark fill inside
    fill_color = (*DEEP_BG, 180)
    inner = [
        (notch + 1, 1),
        (bar_w - 2, 1),
        (bar_w - 2, bar_h - 2 - notch),
        (bar_w - 2 - notch, bar_h - 2),
        (1, bar_h - 2),
        (1, notch + 1),
    ]
    draw.polygon(inner, fill=fill_color)

    img.save(os.path.join(OUTPUT_DIR, "hud-bar.png"))
    print("[+] hud-bar.png generated")

    # Fill — gradient cyan → purple
    fill_img = Image.new("RGBA", (bar_w - 4, bar_h - 4), (0, 0, 0, 0))
    for x in range(bar_w - 4):
        ratio = x / (bar_w - 4)
        r = int(CYAN[0] + (PURPLE[0] - CYAN[0]) * ratio)
        g = int(CYAN[1] + (PURPLE[1] - CYAN[1]) * ratio)
        b = int(CYAN[2] + (PURPLE[2] - CYAN[2]) * ratio)
        for y in range(bar_h - 4):
            fill_img.putpixel((x, y), (r, g, b, 200))

    # Glow on top
    glow = fill_img.filter(ImageFilter.GaussianBlur(radius=2))
    result = Image.alpha_composite(glow, fill_img)
    result.save(os.path.join(OUTPUT_DIR, "hud-fill.png"))
    print("[+] hud-fill.png generated")


# ── 5. HUD CORNERS — bracket decorations ──────────────────────────
def generate_corners():
    """HUD corner brackets for the boot screen frame."""
    size = 60
    thickness = 2
    notch = 12
    color = (*CYAN[:3], 100)

    for name, flip_h, flip_v in [
        ("corner-tl", False, False),
        ("corner-tr", True, False),
        ("corner-bl", False, True),
        ("corner-br", True, True),
    ]:
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Top-left corner shape (others are flipped)
        # Vertical line
        draw.line([(0, notch), (0, size - 1)], fill=color, width=thickness)
        # Horizontal line
        draw.line([(notch, 0), (size - 1, 0)], fill=color, width=thickness)
        # Chamfer diagonal
        draw.line([(0, notch), (notch, 0)], fill=color, width=thickness)

        if flip_h:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
        if flip_v:
            img = img.transpose(Image.FLIP_TOP_BOTTOM)

        img.save(os.path.join(OUTPUT_DIR, f"{name}.png"))
        print(f"[+] {name}.png generated")


# ── 6. HUD RING — spinning element ────────────────────────────────
def generate_hud_ring():
    """Partial circle ring for spinning HUD element."""
    size = 160
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    radius = 65

    # Draw arc segments with gaps
    segments = [
        (0, 80),
        (100, 170),
        (190, 260),
        (280, 350),
    ]

    for start, end in segments:
        for angle in range(start, end):
            rad = math.radians(angle)
            x = cx + radius * math.cos(rad)
            y = cy + radius * math.sin(rad)

            # Fade at segment edges
            seg_len = end - start
            pos_in_seg = angle - start
            edge_fade = min(pos_in_seg, seg_len - pos_in_seg) / 15.0
            alpha = int(min(1.0, edge_fade) * 120)

            draw.ellipse([x - 1, y - 1, x + 1, y + 1], fill=(*CYAN[:3], alpha))

    # Inner ring — thinner, dimmer
    inner_r = 55
    for angle in range(0, 360, 2):
        rad = math.radians(angle)
        x = cx + inner_r * math.cos(rad)
        y = cy + inner_r * math.sin(rad)
        draw.ellipse([x, y, x + 1, y + 1], fill=(*PURPLE[:3], 40))

    # Tick marks
    for angle in range(0, 360, 15):
        rad = math.radians(angle)
        x1 = cx + (radius + 3) * math.cos(rad)
        y1 = cy + (radius + 3) * math.sin(rad)
        x2 = cx + (radius + 8) * math.cos(rad)
        y2 = cy + (radius + 8) * math.sin(rad)

        tick_alpha = 60 if angle % 45 != 0 else 120
        draw.line([(x1, y1), (x2, y2)], fill=(*CYAN[:3], tick_alpha), width=1)

    img.save(os.path.join(OUTPUT_DIR, "hud-ring.png"))
    print("[+] hud-ring.png generated")


# ── 7. HUD RING FRAME 2 — second ring for counter-rotation ────────
def generate_hud_ring2():
    """Second ring that rotates opposite direction."""
    size = 160
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2
    radius = 75

    segments = [
        (20, 60),
        (120, 160),
        (200, 240),
        (300, 340),
    ]

    for start, end in segments:
        for angle in range(start, end):
            rad = math.radians(angle)
            x = cx + radius * math.cos(rad)
            y = cy + radius * math.sin(rad)

            seg_len = end - start
            pos_in_seg = angle - start
            edge_fade = min(pos_in_seg, seg_len - pos_in_seg) / 10.0
            alpha = int(min(1.0, edge_fade) * 70)

            draw.ellipse([x - 0.5, y - 0.5, x + 0.5, y + 0.5],
                         fill=(*HOT_PINK[:3], alpha))

    img.save(os.path.join(OUTPUT_DIR, "hud-ring2.png"))
    print("[+] hud-ring2.png generated")


# ── MAIN ───────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("╔═══════════════════════════════════════════════════╗")
    print("║  SPIDER'S LAB — Plymouth HUD Assets Generator v2  ║")
    print("╚═══════════════════════════════════════════════════╝")
    generate_hex_grid()
    generate_logo()
    generate_scanline()
    generate_hud_bar()
    generate_corners()
    generate_hud_ring()
    generate_hud_ring2()
    print(f"\n[✓] All assets written to: {OUTPUT_DIR}")
