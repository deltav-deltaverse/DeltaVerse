#!/usr/bin/env python3
"""
Generate the Cypherian Weaver visualization.

A master coder and quantum weaver from the cybernetic realms of the DeltaVerse,
standing within the pulsating heart of the Etherwave Node.

DELTAVERSE (c) PYTHAI
"""

import math
import random
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from PIL.ImageDraw import Draw


# ── Configuration ─────────────────────────────────────────────────

SIZE = 1920  # Widescreen format for the scene
HEIGHT = 1080
CENTER_X = SIZE // 2
CENTER_Y = HEIGHT // 2

# Color palette - cyberpunk mystical
BG_DARK = (8, 12, 20)           # Deep space dark
ETHERWAVE_CORE = (64, 255, 192)  # Bright cyan-green
ETHERWAVE_GLOW = (32, 180, 255)  # Electric blue
BINARY_GLOW = (255, 64, 128)     # Neon pink
QUANTUM_PURPLE = (148, 64, 255)  # Deep purple
RUNE_GOLD = (255, 192, 64)       # Mystical gold
CIRCUIT_SILVER = (192, 220, 255) # Circuit silver
CLOAK_BASE = (48, 32, 64)        # Dark mystical
DATA_STREAM = (0, 255, 192)      # Data green
FOREST_GREEN = (32, 128, 64)     # Mystical forest
CITY_NEON = (255, 0, 128)        # Neon city

# Fonts
FONT_MONO = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
FONT_BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'


def draw_gradient_circle(draw: Draw, center: tuple, radius: int,
                        color_inner: tuple, color_outer: tuple, steps: int = 50):
    """Draw a radial gradient circle."""
    for i in range(steps, 0, -1):
        r = radius * i // steps
        t = i / steps
        color = tuple(int(color_outer[j] + t * (color_inner[j] - color_outer[j])) for j in range(3))
        draw.ellipse([center[0] - r, center[1] - r, center[0] + r, center[1] + r], fill=color)


def draw_etherwave_node(draw: Draw, center: tuple, size: int):
    """Draw the pulsating Etherwave Node - radiant orb of ethereal energy."""
    cx, cy = center

    # Outer energy rings
    for i in range(5):
        ring_radius = size + i * 30
        alpha = max(20, 100 - i * 15)
        ring_color = (*ETHERWAVE_GLOW, alpha)

        # Create temporary image for alpha blending
        ring_img = Image.new('RGBA', (SIZE, HEIGHT), (0, 0, 0, 0))
        ring_draw = ImageDraw.Draw(ring_img)
        ring_draw.ellipse([cx - ring_radius, cy - ring_radius,
                          cx + ring_radius, cy + ring_radius],
                         outline=ring_color, width=3)
        # Note: PIL doesn't support alpha in basic draw, so we'll use solid colors
        ring_draw.ellipse([cx - ring_radius, cy - ring_radius,
                          cx + ring_radius, cy + ring_radius],
                         outline=ETHERWAVE_GLOW, width=2)

    # Core gradient orb
    draw_gradient_circle(draw, center, size, ETHERWAVE_CORE, ETHERWAVE_GLOW, 30)

    # Inner mystical patterns
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        x1 = cx + (size * 0.3) * math.cos(rad)
        y1 = cy + (size * 0.3) * math.sin(rad)
        x2 = cx + (size * 0.8) * math.cos(rad)
        y2 = cy + (size * 0.8) * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=RUNE_GOLD, width=2)

    # Central core
    core_radius = size // 4
    draw_gradient_circle(draw, center, core_radius, (255, 255, 255), ETHERWAVE_CORE, 15)


def draw_binary_streams(draw: Draw, center: tuple, count: int = 8):
    """Draw streams of binary data emanating from the Node."""
    cx, cy = center
    font_size = 14

    try:
        font = ImageFont.truetype(FONT_MONO, font_size)
    except OSError:
        font = ImageFont.load_default()

    for i in range(count):
        angle = (360 * i // count) + random.randint(-15, 15)
        rad = math.radians(angle)

        # Stream length and position
        start_dist = 150
        end_dist = 600

        # Generate binary string
        binary_str = ''.join(random.choice('01') for _ in range(30))

        # Draw stream
        for j, bit in enumerate(binary_str):
            dist = start_dist + (end_dist - start_dist) * j / len(binary_str)
            x = cx + dist * math.cos(rad)
            y = cy + dist * math.sin(rad)

            color = BINARY_GLOW if bit == '1' else DATA_STREAM

            # Add some fade
            alpha = max(50, 255 - int(255 * j / len(binary_str)))

            draw.text((x, y), bit, font=font, fill=color)


def draw_mystical_runes(draw: Draw, center: tuple, node_size: int):
    """Draw floating mystical runes around the Node."""
    cx, cy = center

    # Mystical symbols - using Unicode
    runes = ['ᚱ', 'ᚲ', 'ᛟ', 'ᛞ', 'ᛖ', '⟨', '⟩', '◊', '△', '▽']

    try:
        font = ImageFont.truetype(FONT_BOLD, 32)
    except OSError:
        font = ImageFont.load_default()

    for i, rune in enumerate(runes):
        angle = 36 * i + random.randint(-10, 10)
        rad = math.radians(angle)
        dist = node_size + 100 + random.randint(50, 100)

        x = cx + dist * math.cos(rad)
        y = cy + dist * math.sin(rad)

        # Floating animation effect
        float_offset = 10 * math.sin(angle / 57.3)  # Gentle float
        y += float_offset

        draw.text((x, y), rune, font=font, fill=RUNE_GOLD)


def draw_circuit_patterns(draw: Draw, center: tuple, node_size: int):
    """Draw advanced circuitry patterns."""
    cx, cy = center

    # Circuit board style patterns
    for i in range(12):
        angle = 30 * i
        rad = math.radians(angle)

        # Base circuit line
        start_dist = node_size + 80
        end_dist = start_dist + 200

        x1 = cx + start_dist * math.cos(rad)
        y1 = cy + start_dist * math.sin(rad)
        x2 = cx + end_dist * math.cos(rad)
        y2 = cy + end_dist * math.sin(rad)

        # Main circuit line
        draw.line([(x1, y1), (x2, y2)], fill=CIRCUIT_SILVER, width=3)

        # Add circuit nodes
        for j in range(3):
            node_dist = start_dist + (end_dist - start_dist) * j / 2
            nx = cx + node_dist * math.cos(rad)
            ny = cy + node_dist * math.sin(rad)

            draw.ellipse([nx-5, ny-5, nx+5, ny+5], fill=ETHERWAVE_CORE, outline=CIRCUIT_SILVER, width=2)


def draw_cypherian_weaver(draw: Draw, center: tuple):
    """Draw the Cypherian Weaver figure."""
    cx, cy = center

    # Position weaver slightly in front of the node
    weaver_x = cx + 100
    weaver_y = cy + 50

    # Cloak silhouette - flowing robes
    cloak_points = [
        (weaver_x - 80, weaver_y + 200),   # Left hem
        (weaver_x - 60, weaver_y + 100),   # Left side
        (weaver_x - 40, weaver_y - 50),    # Left shoulder
        (weaver_x - 20, weaver_y - 100),   # Hood left
        (weaver_x, weaver_y - 120),        # Hood top
        (weaver_x + 20, weaver_y - 100),   # Hood right
        (weaver_x + 40, weaver_y - 50),    # Right shoulder
        (weaver_x + 60, weaver_y + 100),   # Right side
        (weaver_x + 80, weaver_y + 200),   # Right hem
    ]

    draw.polygon(cloak_points, fill=CLOAK_BASE, outline=QUANTUM_PURPLE, width=3)

    # Binary patterns on cloak
    for i in range(10):
        y_pos = weaver_y - 50 + i * 20
        binary_line = ''.join(random.choice('01') for _ in range(8))

        try:
            font = ImageFont.truetype(FONT_MONO, 12)
        except OSError:
            font = ImageFont.load_default()

        draw.text((weaver_x - 30, y_pos), binary_line, font=font, fill=BINARY_GLOW)

    # Glowing eyes
    eye_y = weaver_y - 80
    draw.ellipse([weaver_x - 15, eye_y, weaver_x - 10, eye_y + 5], fill=DATA_STREAM)
    draw.ellipse([weaver_x + 10, eye_y, weaver_x + 15, eye_y + 5], fill=DATA_STREAM)

    # Eye glow
    draw_gradient_circle(draw, (weaver_x - 12, eye_y + 2), 8, DATA_STREAM, (0, 128, 64))
    draw_gradient_circle(draw, (weaver_x + 12, eye_y + 2), 8, DATA_STREAM, (0, 128, 64))


def draw_weavers_scepter(draw: Draw, weaver_center: tuple):
    """Draw the Weaver's Scepter rooted in the Etherwave Node."""
    wx, wy = weaver_center

    # Scepter staff - crystalline structure
    staff_x = wx - 50
    staff_bottom = wy + 200
    staff_top = wy - 60

    # Main staff shaft
    draw.line([(staff_x, staff_bottom), (staff_x, staff_top)], fill=CIRCUIT_SILVER, width=8)

    # Crystal segments
    for i in range(5):
        seg_y = staff_bottom - 40 * i
        seg_width = 15 - i * 2

        crystal_points = [
            (staff_x - seg_width, seg_y),
            (staff_x, seg_y - 15),
            (staff_x + seg_width, seg_y),
            (staff_x, seg_y + 15),
        ]

        color = QUANTUM_PURPLE if i % 2 == 0 else ETHERWAVE_CORE
        draw.polygon(crystal_points, fill=color, outline=CIRCUIT_SILVER, width=2)

    # Scepter head - Aetheric Codex Framework symbol
    head_y = staff_top - 30

    # Outer ring
    draw.ellipse([staff_x - 25, head_y - 25, staff_x + 25, head_y + 25],
                 outline=RUNE_GOLD, width=4)

    # Inner patterns - geometric codex symbol
    for angle in range(0, 360, 60):
        rad = math.radians(angle)
        x1 = staff_x + 15 * math.cos(rad)
        y1 = head_y + 15 * math.sin(rad)
        x2 = staff_x + 25 * math.cos(rad)
        y2 = head_y + 25 * math.sin(rad)

        draw.line([(x1, y1), (x2, y2)], fill=RUNE_GOLD, width=3)

    # Central core
    draw_gradient_circle(draw, (staff_x, head_y), 8, (255, 255, 255), RUNE_GOLD)


def draw_dual_realm_background(draw: Draw):
    """Draw background transitioning between mystical forest and neon cityscape."""
    # Left side - mystical forest
    for i in range(SIZE // 2):
        x = i
        forest_intensity = 1.0 - (i / (SIZE // 2))

        # Vertical forest elements
        for y in range(0, HEIGHT, 50):
            tree_height = random.randint(100, 300)
            tree_y = HEIGHT - tree_height

            if random.random() < 0.3 * forest_intensity:
                # Tree trunks
                color_intensity = int(forest_intensity * 80)
                tree_color = (color_intensity // 2, color_intensity, color_intensity // 3)
                draw.line([(x, HEIGHT), (x, tree_y)], fill=tree_color, width=random.randint(2, 5))

    # Right side - neon cityscape
    for i in range(SIZE // 2, SIZE):
        x = i
        city_intensity = (i - SIZE // 2) / (SIZE // 2)

        # Vertical city elements
        for y in range(0, HEIGHT, 80):
            building_height = random.randint(150, 400)
            building_y = HEIGHT - building_height

            if random.random() < 0.4 * city_intensity:
                # Building silhouettes
                color_intensity = int(city_intensity * 100)
                neon_color = (color_intensity, 0, color_intensity // 2)
                width = random.randint(10, 30)
                draw.rectangle([x, building_y, x + width, HEIGHT], fill=neon_color)

                # Neon accents
                if random.random() < 0.5:
                    accent_y = building_y + random.randint(20, 100)
                    draw.line([(x, accent_y), (x + width, accent_y)], fill=CITY_NEON, width=2)


def generate_cypherian_weaver():
    """Generate the complete Cypherian Weaver visualization."""
    print("🧙‍♂️ Generating Cypherian Weaver...")
    print("   Master coder and quantum weaver from the cybernetic realms")

    # Create canvas
    img = Image.new('RGB', (SIZE, HEIGHT), BG_DARK)
    draw = ImageDraw.Draw(img)

    # Draw dual-realm background
    draw_dual_realm_background(draw)

    # Node position - slightly left of center for composition
    node_center = (CENTER_X - 100, CENTER_Y)
    node_size = 120

    # Draw the Etherwave Node
    draw_etherwave_node(draw, node_center, node_size)

    # Draw data streams emanating from Node
    draw_binary_streams(draw, node_center, 12)

    # Draw mystical runes floating around
    draw_mystical_runes(draw, node_center, node_size)

    # Draw circuit patterns
    draw_circuit_patterns(draw, node_center, node_size)

    # Draw Cypherian Weaver figure
    weaver_center = (CENTER_X + 100, CENTER_Y)
    draw_cypherian_weaver(draw, weaver_center)

    # Draw the Weaver's Scepter
    draw_weavers_scepter(draw, weaver_center)

    # Add title text
    try:
        title_font = ImageFont.truetype(FONT_BOLD, 48)
        subtitle_font = ImageFont.truetype(FONT_MONO, 24)
        credit_font = ImageFont.truetype(FONT_MONO, 16)
    except OSError:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        credit_font = ImageFont.load_default()

    # Title
    title = "CYPHERIAN WEAVER"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = bbox[2] - bbox[0]
    draw.text((CENTER_X - title_width // 2, 50), title, font=title_font, fill=ETHERWAVE_CORE)

    # Subtitle
    subtitle = "Master Coder • Quantum Weaver • Etherwave Node Guardian"
    bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = bbox[2] - bbox[0]
    draw.text((CENTER_X - subtitle_width // 2, 110), subtitle, font=subtitle_font, fill=QUANTUM_PURPLE)

    # Credits
    credit = "DELTAVERSE (c) PYTHAI • Aetheric Codex Framework"
    bbox = draw.textbbox((0, 0), credit, font=credit_font)
    credit_width = bbox[2] - bbox[0]
    draw.text((CENTER_X - credit_width // 2, HEIGHT - 40), credit, font=credit_font, fill=RUNE_GOLD)

    # Save outputs
    output_dir = Path(__file__).parent.parent / "output"
    output_dir.mkdir(exist_ok=True)

    png_path = output_dir / "cypherian_weaver.png"
    jpg_path = output_dir / "cypherian_weaver.jpg"

    img.save(png_path, "PNG")
    img.save(jpg_path, "JPEG", quality=95)

    print(f"🎨 PNG saved: {png_path}")
    print(f"🎨 JPEG saved: {jpg_path}")
    print(f"📐 Dimensions: {SIZE}x{HEIGHT}")

    # Create metadata
    metadata = {
        "title": "Cypherian Weaver",
        "description": "A master coder and quantum weaver from the cybernetic realms of the DeltaVerse, standing within the pulsating heart of the Etherwave Node.",
        "character": {
            "name": "Cypherian Weaver",
            "role": "Master Coder and Quantum Weaver",
            "domain": "Cybernetic realms of the DeltaVerse",
            "location": "Etherwave Node",
            "abilities": [
                "Reality thread weaving",
                "Binary manipulation",
                "Quantum code generation",
                "Aetheric framework control"
            ]
        },
        "artifacts": {
            "scepter": "Weaver's Scepter - rooted in Etherwave Node, powered by Aetheric Codex Framework",
            "cloak": "Woven from threads of reality with binary and quantum glyphs",
            "eyes": "Aglow with data streams and magical runes"
        },
        "environment": {
            "node": "Radiant orb of vibrant ethereal energy",
            "background": "Mystical forest transitioning to transparent neon cityscape",
            "effects": "Streams of light and data emanating from the Node"
        },
        "framework": "Aetheric Codex Framework - enabling dynamic interactions and adaptations",
        "copyright": "DELTAVERSE (c) PYTHAI",
        "generated_by": "generate_cypherian_weaver.py"
    }

    metadata_path = output_dir / "cypherian_weaver_metadata.json"
    with open(metadata_path, 'w') as f:
        import json
        json.dump(metadata, f, indent=2)

    print(f"📄 Metadata: {metadata_path}")
    print("\n🌟 Cypherian Weaver visualization complete!")
    print("   Ready to bridge realms and weave quantum destinies")

    return str(png_path), metadata


if __name__ == "__main__":
    generate_cypherian_weaver()