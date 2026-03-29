#!/bin/bash
set -euo pipefail

# ── Steganographic Embedding Script for True DELTA VERSE ──
#
# Embeds the provenance payload into the JPEG using steghide.
# Creates the final NFT image with three verification layers:
#   1. Visual binary (readable)
#   2. Steganographic payload (hidden)
#   3. On-chain hash (immutable)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../output"
JPEG_PATH="$OUTPUT_DIR/true_deltaverse.jpg"
PAYLOAD_PATH="$OUTPUT_DIR/payload.json"
FINAL_PATH="$OUTPUT_DIR/true_deltaverse_final.jpg"
PASSPHRASE="${1:-deltaverse2026}"

echo "🏛️  True DELTA VERSE Steganographic Embedding"
echo "═══════════════════════════════════════════════"
echo

# ── Check dependencies ──

if ! command -v steghide &> /dev/null; then
    echo "❌ steghide not found"
    echo "Install with: sudo apt-get install steghide"
    exit 1
fi

if ! command -v tomb &> /dev/null; then
    echo "⚠️  tomb not found (optional for tomb bury mode)"
else
    echo "✅ tomb $(tomb --version | head -1 | awk '{print $2}')"
fi

echo "✅ steghide $(steghide --version 2>&1 | head -1 | awk '{print $2}')"
echo

# ── Check inputs ──

if [[ ! -f "$JPEG_PATH" ]]; then
    echo "❌ Source JPEG not found: $JPEG_PATH"
    echo "Run generate_true_deltaverse.py first"
    exit 1
fi

if [[ ! -f "$PAYLOAD_PATH" ]]; then
    echo "❌ Payload not found: $PAYLOAD_PATH"
    echo "Expected: $PAYLOAD_PATH"
    exit 1
fi

echo "📊 Source image: $(basename "$JPEG_PATH")"
echo "📄 Payload size: $(wc -c < "$PAYLOAD_PATH") bytes"
echo "🔑 Passphrase: $(echo "$PASSPHRASE" | sed 's/./*/g')"
echo

# ── Compute pre-steganography hash ──

PRE_HASH=$(sha256sum "$JPEG_PATH" | awk '{print $1}')
echo "🧮 Pre-steg SHA-256: $PRE_HASH"

# ── Copy image for embedding ──

cp "$JPEG_PATH" "$FINAL_PATH"
echo "📋 Copied to: $(basename "$FINAL_PATH")"

# ── Embed payload via steghide ──

echo
echo "🕳️  Embedding payload via steghide..."
echo "Command: steghide embed -cf \"$FINAL_PATH\" -ef \"$PAYLOAD_PATH\" -p \"***\""

if steghide embed -cf "$FINAL_PATH" -ef "$PAYLOAD_PATH" -p "$PASSPHRASE"; then
    echo "✅ Payload embedded successfully"
else
    echo "❌ Steghide embedding failed"
    exit 1
fi

# ── Compute post-steganography hash ──

POST_HASH=$(sha256sum "$FINAL_PATH" | awk '{print $1}')
echo "🧮 Post-steg SHA-256: $POST_HASH"

# ── Update manifest ──

MANIFEST_PATH="$OUTPUT_DIR/manifest.json"

if [[ -f "$MANIFEST_PATH" ]]; then
    # Update existing manifest with post-steg hash
    python3 -c "
import json
with open('$MANIFEST_PATH', 'r') as f:
    manifest = json.load(f)
manifest['post_steg_sha256'] = '$POST_HASH'
manifest['steganography'] = {
    'tool': 'steghide',
    'payload_file': 'payload.json',
    'payload_size_bytes': $(wc -c < "$PAYLOAD_PATH"),
    'extraction_command': 'steghide extract -sf true_deltaverse_final.jpg -p passphrase'
}
with open('$MANIFEST_PATH', 'w') as f:
    json.dump(manifest, f, indent=2)
print('📄 Updated manifest.json')
"
fi

# ── Verification test ──

echo
echo "🔍 Testing extraction..."

TEMP_EXTRACT="/tmp/extracted_payload.json"
if steghide extract -sf "$FINAL_PATH" -xf "$TEMP_EXTRACT" -p "$PASSPHRASE" -f; then
    if diff -q "$PAYLOAD_PATH" "$TEMP_EXTRACT" > /dev/null; then
        echo "✅ Extraction verified - payload intact"
        rm -f "$TEMP_EXTRACT"
    else
        echo "❌ Extraction failed - payload corrupted"
        exit 1
    fi
else
    echo "❌ Extraction failed"
    exit 1
fi

# ── Summary ──

echo
echo "🎯 EMBEDDING COMPLETE"
echo "══════════════════════"
echo "📁 Final image: $(basename "$FINAL_PATH")"
echo "🧮 Hash (on-chain): $POST_HASH"
echo "💾 Size: $(du -h "$FINAL_PATH" | awk '{print $1}')"
echo
echo "🔓 To extract payload:"
echo "steghide extract -sf \"$FINAL_PATH\" -p \"$PASSPHRASE\""
echo
echo "📝 Tomb bury compatibility:"
echo "tomb bury -k key.tomb \"$FINAL_PATH\""
echo
echo "Next steps:"
echo "1. Pin $FINAL_PATH to IPFS"
echo "2. Deploy smart contract with hash: $POST_HASH"
echo "3. Mint NFT with IPFS metadata"

# ── Optional: Tomb bury demonstration ──

if command -v tomb &> /dev/null && [[ "${TOMB_DEMO:-}" == "1" ]]; then
    echo
    echo "🏺 Tomb bury demonstration..."

    TOMB_KEY="$OUTPUT_DIR/deltaverse.tomb.key"

    # Create a dummy key for demo
    echo "dummy_tomb_key_$(date +%s)" > "$TOMB_KEY"

    if tomb bury -k "$TOMB_KEY" "$FINAL_PATH"; then
        echo "✅ Tomb key buried in image"
        echo "🔓 Extract with: tomb exhume -k recovered.key \"$FINAL_PATH\""
    else
        echo "⚠️  Tomb bury failed (expected - needs proper key)"
    fi

    rm -f "$TOMB_KEY"
fi

echo
echo "🌟 True DELTA VERSE ready for blockchain deployment!"