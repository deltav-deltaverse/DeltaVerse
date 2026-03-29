#!/usr/bin/env python3
"""
Generate the True DELTA VERSE coin image.

The binary digits in this image are REAL — they encode an actual message.
Anyone can read the binary, decode it, and verify the message.

Output: JPEG (required for steghide embedding).
"""

import hashlib
import json
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


# ── Binary encoding (from binarytotext/text-to-binary.py) ─────────

def text_to_binary(text: str) -> str:
    return ''.join(format(ord(char), '08b') for char in text)


def binary_to_text(binary: str) -> str:
    chars = [binary[i:i+8] for i in range(0, len(binary), 8)]
    return ''.join(chr(int(b, 2)) for b in chars if len(b) == 8)


# ── Configuration ─────────────────────────────────────────────────

SIZE = 2048
CENTER = SIZE // 2
COIN_RADIUS = SIZE // 2 - 80
RIM_WIDTH = 18

# The message encoded in binary around the coin
MESSAGE = "DELTA VERSE :: SELF-VERIFYING NFT :: THREE LAYERS OF TRUTH"

# Colors — silver coin palette
BG_COLOR = (18, 18, 22)          # near-black background
COIN_DARK = (58, 62, 68)         # darker silver
COIN_MID = (140, 148, 158)       # mid silver
COIN_LIGHT = (195, 200, 210)     # bright silver
COIN_SHINE = (225, 230, 240)     # highlight silver
RIM_COLOR = (170, 178, 188)      # rim silver
BINARY_ON = (215, 222, 235)      # '1' digit — bright
BINARY_OFF = (95, 100, 110)      # '0' digit — dim
TEXT_COLOR = (230, 235, 245)      # main text
LOGO_COLOR = (200, 208, 220)     # V logo

# Fonts
FONT_MONO = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
FONT_BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
FONT_SANS = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'


def draw_radial_gradient(draw: ImageDraw.Draw, cx: int, cy: int, radius: int):
    """Draw a metallic radial gradient for the coin face."""
    for r in range(radius, 0, -1):
        t = r / radius
        # Metallic gradient with slight off-center highlight
        if t > 0.95:
            c = RIM_COLOR
        elif t > 0.92:
            # Inner rim shadow
            f = (t - 0.92) / 0.03
            c = tuple(int(COIN_MID[i] + f * (RIM_COLOR[i] - COIN_MID[i])) for i in range(3))
        else:
            # Coin face — gradient from dark edge to lighter center
            f = 1.0 - t / 0.92
            # Add slight asymmetry for metallic look
            shift = 0.15 * math.sin(f * math.pi)
            f = min(1.0, f + shift)
            c = tuple(int(COIN_DARK[i] + f * (COIN_MID[i] - COIN_DARK[i])) for i in range(3))
        bbox = [cx - r, cy - r, cx + r, cy + r]
        draw.ellipse(bbox, fill=c)


def draw_binary_ring(draw: ImageDraw.Draw, binary: str, cx: int, cy: int,
                     radius: int, font_size: int, start_angle: float = 0):
    """Draw binary digits in a circular ring around the center."""
    font = ImageFont.truetype(FONT_MONO, font_size)

    # Calculate how many characters fit in the ring
    char_width = font_size * 0.7
    circumference = 2 * math.pi * radius
    max_chars = int(circumference / char_width)

    # Repeat or truncate binary to fill the ring
    ring_binary = (binary * ((max_chars // len(binary)) + 1))[:max_chars]

    angle_step = 360.0 / max_chars

    for i, digit in enumerate(ring_binary):
        angle_deg = start_angle + i * angle_step
        angle_rad = math.radians(angle_deg - 90)  # -90 so 0 deg = top

        x = cx + radius * math.cos(angle_rad)
        y = cy + radius * math.sin(angle_rad)

        color = BINARY_ON if digit == '1' else BINARY_OFF

        # Create a small image for the rotated character
        txt_img = Image.new('RGBA', (font_size * 2, font_size * 2), (0, 0, 0, 0))
        txt_draw = ImageDraw.Draw(txt_img)
        txt_draw.text((font_size // 2, font_size // 2), digit, font=font, fill=color + (255,))

        # Rotate to follow the circle
        rotated = txt_img.rotate(-angle_deg, expand=False, center=(font_size, font_size))

        # Paste onto main image
        paste_x = int(x - font_size)
        paste_y = int(y - font_size)
        if 0 <= paste_x < SIZE and 0 <= paste_y < SIZE:
            draw._image.paste(rotated, (paste_x, paste_y), rotated)


def draw_v_logo(draw: ImageDraw.Draw, cx: int, cy: int, size: int):
    """Draw the triangular V logo (DELTA VERSE mark)."""
    # Outer V
    half = size // 2
    top_y = cy - size // 3
    bot_y = cy + size // 2
    mid_y = cy + size // 6

    # Main V shape
    v_points = [
        (cx - half, top_y),           # top left
        (cx - half // 4, top_y),      # inner top left
        (cx, mid_y),                  # bottom point (inner)
        (cx + half // 4, top_y),      # inner top right
        (cx + half, top_y),           # top right
        (cx, bot_y),                  # bottom point (outer)
    ]
    draw.polygon(v_points, fill=LOGO_COLOR, outline=COIN_SHINE, width=2)

    # Inner triangle (negative space)
    inner_size = size // 4
    inner_points = [
        (cx - inner_size, top_y + size // 6),
        (cx + inner_size, top_y + size // 6),
        (cx, top_y + size // 6 + inner_size * 2),
    ]
    draw.polygon(inner_points, fill=COIN_DARK)

    # Horizontal bar through the V
    bar_y = top_y + size // 5
    draw.line([(cx - half + 10, bar_y), (cx + half - 10, bar_y)],
              fill=COIN_SHINE, width=3)


def generate():
    """Generate the True DELTA VERSE coin image."""

    binary_message = text_to_binary(MESSAGE)
    print(f"Message: {MESSAGE}")
    print(f"Binary:  {binary_message[:64]}...")
    print(f"Binary length: {len(binary_message)} bits ({len(MESSAGE)} chars)")

    # Verify round-trip
    decoded = binary_to_text(binary_message)
    assert decoded == MESSAGE, f"Round-trip failed: {decoded}"
    print(f"Round-trip verified.")

    # ── Create canvas ──
    img = Image.new('RGB', (SIZE, SIZE), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # ── Draw coin base with metallic gradient ──
    draw_radial_gradient(draw, CENTER, CENTER, COIN_RADIUS)

    # ── Draw rim ──
    for w in range(RIM_WIDTH):
        r = COIN_RADIUS - w
        t = w / RIM_WIDTH
        c = tuple(int(RIM_COLOR[i] * (1 - t * 0.3)) for i in range(3))
        draw.ellipse([CENTER - r, CENTER - r, CENTER + r, CENTER + r], outline=c, width=1)

    # ── Draw binary rings ──
    # Ring 1 (outermost): Full message
    ring_configs = [
        (COIN_RADIUS - 45,  20, 0),      # outer ring — large digits
        (COIN_RADIUS - 85,  16, 15),     # second ring — offset
        (COIN_RADIUS - 115, 14, 30),     # third ring
        (COIN_RADIUS - 145, 12, 45),     # fourth ring — smaller
        (COIN_RADIUS - 170, 11, 60),     # fifth ring — smallest
    ]

    for radius, font_size, start_angle in ring_configs:
        draw_binary_ring(draw, binary_message, CENTER, CENTER,
                         radius, font_size, start_angle)

    # ── Draw inner circle (logo area) ──
    inner_radius = COIN_RADIUS - 200
    draw.ellipse([CENTER - inner_radius, CENTER - inner_radius,
                  CENTER + inner_radius, CENTER + inner_radius],
                 outline=COIN_LIGHT, width=3)

    # ── Draw V logo ──
    draw_v_logo(draw, CENTER, CENTER + 40, 200)

    # ── Draw "DELTA VERSE" text ──
    try:
        font_title = ImageFont.truetype(FONT_BOLD, 64)
        font_sub = ImageFont.truetype(FONT_SANS, 22)
        font_tiny = ImageFont.truetype(FONT_MONO, 14)
    except OSError:
        font_title = ImageFont.load_default()
        font_sub = ImageFont.load_default()
        font_tiny = ImageFont.load_default()

    # Title above logo
    title = "DELTA VERSE"
    bbox = draw.textbbox((0, 0), title, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER - 180), title, font=font_title, fill=TEXT_COLOR)

    # Subtitle below logo
    subtitle = "SELF-VERIFYING NFT"
    bbox = draw.textbbox((0, 0), subtitle, font=font_sub)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 200), subtitle, font=font_sub, fill=COIN_LIGHT)

    # Binary decode hint at bottom of coin
    hint = f"BINARY DECODES TO: \"{MESSAGE[:30]}...\""
    bbox = draw.textbbox((0, 0), hint, font=font_tiny)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 240), hint, font=font_tiny, fill=BINARY_OFF)

    # ── Draw outer ring text (readable around the rim) ──
    # Top arc: verification notice
    top_text = "THREE LAYERS OF TRUTH"
    bbox = draw.textbbox((0, 0), top_text, font=font_tiny)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER - COIN_RADIUS + 12), top_text,
              font=font_tiny, fill=COIN_LIGHT)

    # Bottom arc: original reference
    bot_text = "EVOLVED FROM 0x024b...8f90 POLYGON"
    bbox = draw.textbbox((0, 0), bot_text, font=font_tiny)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + COIN_RADIUS - 28), bot_text,
              font=font_tiny, fill=COIN_LIGHT)

    # ── Save as JPEG (steghide requirement) ──
    output_dir = Path(__file__).parent.parent / "output"
    output_dir.mkdir(exist_ok=True)

    jpeg_path = output_dir / "true_deltaverse.jpg"
    png_path = output_dir / "true_deltaverse.png"

    # Save PNG for reference (lossless)
    img.save(png_path, "PNG")
    print(f"PNG saved: {png_path}")

    # Save JPEG for steghide
    img.save(jpeg_path, "JPEG", quality=95)
    print(f"JPEG saved: {jpeg_path}")

    # ── Compute hashes ──
    jpeg_bytes = jpeg_path.read_bytes()
    sha256 = hashlib.sha256(jpeg_bytes).hexdigest()
    print(f"Pre-steganography SHA-256: {sha256}")

    # Save manifest
    manifest = {
        "name": "True DELTA VERSE",
        "message_encoded": MESSAGE,
        "binary_encoded": binary_message,
        "binary_length_bits": len(binary_message),
        "pre_steg_sha256": sha256,
        "jpeg_size_bytes": len(jpeg_bytes),
        "dimensions": f"{SIZE}x{SIZE}",
        "original_contract": "0x024b464ec595f20040002237680026bf006e8f90",
        "original_chain": "polygon",
        "original_chain_id": 137,
        "rings": len(ring_configs),
        "generated_by": "generate_true_deltaverse.py",
    }

    manifest_path = output_dir / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2))
    print(f"Manifest saved: {manifest_path}")

    return str(jpeg_path), manifest


if __name__ == "__main__":
    jpeg_path, manifest = generate()
    print(f"\nDone. Image ready for steganographic embedding.")
    print(f"Next: steghide embed -cf {jpeg_path} -ef payload.json -p <passphrase>")
