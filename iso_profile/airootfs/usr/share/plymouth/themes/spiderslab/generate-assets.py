#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  SPIDER'S LAB — Plymouth Asset Generator                           ║
║  Generates: logo.png, web.png, progress-bar.png, progress-fill.png ║
║                                                                    ║
║  Run: python3 generate-assets.py                                   ║
║  Requires: pip install Pillow                                      ║
╚══════════════════════════════════════════════════════════════════════╝
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math
import os

# ── Config ────────────────────────────────────────────────────────────
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
HOT_PINK = (252, 25, 154)
ELECTRIC_CYAN = (97, 226, 255)
NEON_PURPLE = (175, 109, 249)
DEEP_PURPLE = (25, 23, 36)
WHITE = (232, 227, 227)

CANVAS_W = 800
CANVAS_H = 600
CENTER = (CANVAS_W // 2, CANVAS_H // 2)

# ── 1. SPIDER WEB — radial web with concentric rings ─────────────────
def generate_web():
    img = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = CENTER
    num_radials = 16
    num_rings = 8
    max_radius = 220

    # Draw radial lines from center
    for i in range(num_radials):
        angle = (2 * math.pi * i) / num_radials
        end_x = cx + int(max_radius * math.cos(angle))
        end_y = cy + int(max_radius * math.sin(angle))

        # Gradient opacity along the line — brighter near center
        for seg in range(20):
            t0 = seg / 20
            t1 = (seg + 1) / 20
            x0 = cx + int(max_radius * t0 * math.cos(angle))
            y0 = cy + int(max_radius * t0 * math.sin(angle))
            x1 = cx + int(max_radius * t1 * math.cos(angle))
            y1 = cy + int(max_radius * t1 * math.sin(angle))
            alpha = int(200 * (1 - t0 * 0.6))
            draw.line([(x0, y0), (x1, y1)], fill=(*HOT_PINK, alpha), width=1)

    # Draw concentric rings (the web strands)
    for ring in range(1, num_rings + 1):
        radius = int(max_radius * ring / num_rings)
        alpha = int(180 * (1 - (ring - 1) / num_rings * 0.5))

        # Draw ring as connected polygon between radial points
        points = []
        for i in range(num_radials):
            angle = (2 * math.pi * i) / num_radials
            px = cx + int(radius * math.cos(angle))
            py = cy + int(radius * math.sin(angle))
            points.append((px, py))
        points.append(points[0])  # Close the ring

        for j in range(len(points) - 1):
            # Slight sag in the web strand (organic feel)
            mid_x = (points[j][0] + points[j + 1][0]) // 2
            mid_y = (points[j][1] + points[j + 1][1]) // 2
            # Pull midpoint slightly toward center for sag
            sag = 0.03
            mid_x = int(mid_x + (cx - mid_x) * sag)
            mid_y = int(mid_y + (cy - mid_y) * sag)
            draw.line([points[j], (mid_x, mid_y), points[j + 1]],
                      fill=(*HOT_PINK, alpha), width=1)

    # Center dot — the spider's core
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3],
                 fill=(*HOT_PINK, 255))

    # Subtle glow via blur
    glow = img.filter(ImageFilter.GaussianBlur(radius=4))
    result = Image.alpha_composite(glow, img)

    result.save(os.path.join(OUTPUT_DIR, "web.png"))
    print("[+] web.png generated")


# ── 2. LOGO — "SPIDER'S LAB" text ────────────────────────────────────
def generate_logo():
    img = Image.new("RGBA", (600, 120), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Try to use a good font, fall back to default
    font_size = 48
    small_size = 20
    try:
        font = ImageFont.truetype("/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Bold.ttf", font_size)
        font_small = ImageFont.truetype("/usr/share/fonts/TTF/JetBrainsMonoNerdFont-Regular.ttf", small_size)
    except (OSError, IOError):
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", font_size)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", small_size)
        except (OSError, IOError):
            font = ImageFont.load_default()
            font_small = font

    # Main title — SPIDER'S LAB
    title = "SPIDER'S LAB"
    bbox = draw.textbbox((0, 0), title, font=font)
    tw = bbox[2] - bbox[0]
    tx = (600 - tw) // 2
    ty = 15

    # Red glow layer (drawn slightly larger, blurred)
    glow_img = Image.new("RGBA", (600, 120), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    glow_draw.text((tx, ty), title, fill=(*HOT_PINK, 120), font=font)
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(radius=6))

    # Sharp text on top
    draw.text((tx, ty), title, fill=(*HOT_PINK, 255), font=font)

    # Subtitle
    subtitle = "[ CYBERPUNK HACKER WORKSTATION ]"
    bbox2 = draw.textbbox((0, 0), subtitle, font=font_small)
    sw = bbox2[2] - bbox2[0]
    sx = (600 - sw) // 2
    draw.text((sx, 75), subtitle, fill=(*WHITE, 160), font=font_small)

    # Composite glow + sharp
    result = Image.alpha_composite(glow_img, img)
    result.save(os.path.join(OUTPUT_DIR, "logo.png"))
    print("[+] logo.png generated")


# ── 3. PROGRESS BAR — container and fill ──────────────────────────────
def generate_progress_bar():
    bar_w = 280
    bar_h = 2

    # Container — dim pink outline
    container = Image.new("RGBA", (bar_w, bar_h + 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(container)
    draw.rectangle([0, 0, bar_w - 1, bar_h + 1],
                   outline=(*HOT_PINK, 60), width=1)
    container.save(os.path.join(OUTPUT_DIR, "progress-bar.png"))
    print("[+] progress-bar.png generated")

    # Fill — cyan to purple gradient
    fill = Image.new("RGBA", (bar_w, bar_h), (0, 0, 0, 0))
    for x in range(bar_w):
        ratio = x / bar_w
        r = int(97 + (175 - 97) * ratio)
        g = int(226 + (109 - 226) * ratio)
        b = int(255 + (249 - 255) * ratio)
        alpha = int(180 + 75 * ratio)
        for y in range(bar_h):
            fill.putpixel((x, y), (r, g, b, alpha))

    # Add glow
    glow = fill.filter(ImageFilter.GaussianBlur(radius=2))
    result = Image.alpha_composite(glow, fill)
    result.save(os.path.join(OUTPUT_DIR, "progress-fill.png"))
    print("[+] progress-fill.png generated")


# ── MAIN ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("╔═══════════════════════════════════════════╗")
    print("║  SPIDER'S LAB — Generating Plymouth PNGs  ║")
    print("╚═══════════════════════════════════════════╝")
    generate_web()
    generate_logo()
    generate_progress_bar()
    print("\n[✓] All assets written to:", OUTPUT_DIR)
