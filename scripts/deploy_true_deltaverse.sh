#!/bin/bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════════════
# TRUE DELTA VERSE - COMPLETE DEPLOYMENT ORCHESTRATOR
# ══════════════════════════════════════════════════════════════════════
#
# Coordinates the full deployment process:
#   1. Image generation with real binary encoding
#   2. Steganographic payload embedding
#   3. IPFS pinning (image + metadata)
#   4. Smart contract deployment (EVM + Algorand)
#   5. NFT minting and verification
#
# DELTAVERSE (c) PYTHAI
# ══════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/output"

# ── Configuration ──────────────────────────────────────────────────────

# Deployment mode
MODE="${1:-full}"  # full, image-only, contracts-only, verify-only

# Network selection
EVM_NETWORK="${EVM_NETWORK:-polygon}"  # polygon, base, ethereum
ALGORAND_NETWORK="${ALGORAND_NETWORK:-testnet}"  # testnet, mainnet

# Steganography
STEG_PASSPHRASE="${STEG_PASSPHRASE:-deltaverse2026}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Logging Functions ──────────────────────────────────────────────────

log_phase() {
    echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}PHASE: $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}\n"
}

log_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

log_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# ── Prerequisites Check ────────────────────────────────────────────────

check_prerequisites() {
    log_phase "PREREQUISITES CHECK"

    # Python with PIL
    log_step "Checking Python and PIL..."
    python3 -c "from PIL import Image, ImageDraw, ImageFont; print('PIL available')" 2>/dev/null || \
        log_error "Python PIL required: pip install Pillow"
    log_success "Python PIL ready"

    # Steghide (for steganography)
    log_step "Checking steghide..."
    if command -v steghide >/dev/null 2>&1; then
        log_success "steghide available: $(steghide --version 2>&1 | head -1 | awk '{print $2}')"
    else
        log_warning "steghide not installed - steganographic layer will be skipped"
        log_info "Install with: sudo apt-get install steghide"
    fi

    # Tomb (optional - for tomb bury mode)
    log_step "Checking tomb..."
    if command -v tomb >/dev/null 2>&1; then
        log_success "tomb available: $(tomb --version | head -1 | awk '{print $2}')"
    else
        log_warning "tomb not available - steghide-only mode"
    fi

    # Node.js/tsx (for TypeScript scripts)
    log_step "Checking Node.js and tsx..."
    if command -v tsx >/dev/null 2>&1; then
        log_success "tsx available"
    else
        log_warning "tsx not found - Algorand minting unavailable"
        log_info "Install with: npm install -g tsx"
    fi

    # Forge (for smart contract deployment)
    log_step "Checking Foundry..."
    if command -v forge >/dev/null 2>&1; then
        log_success "forge available: $(forge --version | head -1 | awk '{print $2}')"
    else
        log_warning "forge not found - EVM deployment unavailable"
        log_info "Install from: https://getfoundry.sh"
    fi

    # Environment variables
    log_step "Checking environment..."

    # Required for contract deployment
    if [[ -n "${PRIVATE_KEY:-}" ]]; then
        log_success "PRIVATE_KEY configured"
    else
        log_warning "PRIVATE_KEY not set - contract deployment will be skipped"
    fi

    # Required for IPFS pinning
    if [[ -n "${PINATA_API_KEY:-}" && -n "${PINATA_SECRET_API_KEY:-}" ]]; then
        log_success "Pinata credentials configured"
    else
        log_warning "Pinata credentials not set - IPFS pinning will use placeholder CIDs"
        log_info "Set: PINATA_API_KEY and PINATA_SECRET_API_KEY"
    fi

    # Optional for Algorand
    if [[ -n "${ALGORAND_MNEMONIC:-}" ]]; then
        log_success "Algorand wallet configured"
    else
        log_warning "ALGORAND_MNEMONIC not set - Algorand deployment will be skipped"
    fi
}

# ── Phase 1: Image Generation ──────────────────────────────────────────

generate_images() {
    log_phase "IMAGE GENERATION"

    # Generate True DELTA VERSE coin
    log_step "Generating True DELTA VERSE coin with real binary..."
    cd "$PROJECT_DIR"
    python3 scripts/generate_true_deltaverse.py

    if [[ -f "$OUTPUT_DIR/true_deltaverse.jpg" ]]; then
        log_success "True DELTA VERSE coin generated"

        # Get image stats
        local size=$(du -h "$OUTPUT_DIR/true_deltaverse.jpg" | cut -f1)
        local hash=$(sha256sum "$OUTPUT_DIR/true_deltaverse.jpg" | cut -d' ' -f1)
        log_info "Size: $size, SHA-256: ${hash:0:16}..."
    else
        log_error "Image generation failed"
    fi

    # Generate Cypherian Weaver (if not exists)
    if [[ ! -f "$OUTPUT_DIR/cypherian_weaver.png" ]]; then
        log_step "Generating Cypherian Weaver visualization..."
        python3 scripts/generate_cypherian_weaver.py
        log_success "Cypherian Weaver generated"
    else
        log_info "Cypherian Weaver already exists"
    fi
}

# ── Phase 2: Steganographic Embedding ──────────────────────────────────

embed_steganography() {
    log_phase "STEGANOGRAPHIC EMBEDDING"

    if ! command -v steghide >/dev/null 2>&1; then
        log_warning "steghide not available - skipping steganographic layer"

        # Copy original as final for consistency
        cp "$OUTPUT_DIR/true_deltaverse.jpg" "$OUTPUT_DIR/true_deltaverse_final.jpg"
        log_info "Using original image as final (no steganography)"
        return
    fi

    log_step "Embedding steganographic payload..."
    cd "$PROJECT_DIR"

    # Run steganographic embedding with passphrase
    STEG_PASSPHRASE="$STEG_PASSPHRASE" ./scripts/embed_steganography.sh

    if [[ -f "$OUTPUT_DIR/true_deltaverse_final.jpg" ]]; then
        log_success "Steganographic embedding complete"

        # Verify extraction works
        log_step "Testing payload extraction..."
        local temp_extract="/tmp/test_extract.json"
        if steghide extract -sf "$OUTPUT_DIR/true_deltaverse_final.jpg" -xf "$temp_extract" -p "$STEG_PASSPHRASE" -f 2>/dev/null; then
            log_success "Payload extraction verified"
            rm -f "$temp_extract"
        else
            log_warning "Payload extraction test failed"
        fi

        # Update manifest with post-steg hash
        local post_hash=$(sha256sum "$OUTPUT_DIR/true_deltaverse_final.jpg" | cut -d' ' -f1)
        log_info "Post-steganography hash: ${post_hash:0:16}..."

        # Update manifest.json
        python3 -c "
import json
with open('$OUTPUT_DIR/manifest.json', 'r') as f:
    manifest = json.load(f)
manifest['post_steg_sha256'] = '$post_hash'
with open('$OUTPUT_DIR/manifest.json', 'w') as f:
    json.dump(manifest, f, indent=2)
print('📄 Manifest updated with post-steg hash')
"
    else
        log_error "Steganographic embedding failed"
    fi
}

# ── Phase 3: IPFS Pinning ──────────────────────────────────────────────

pin_to_ipfs() {
    log_phase "IPFS PINNING"

    if [[ -z "${PINATA_API_KEY:-}" || -z "${PINATA_SECRET_API_KEY:-}" ]]; then
        log_warning "Pinata credentials not configured - using placeholder CIDs"

        # Create placeholder deployment info
        cat > "$OUTPUT_DIR/ipfs-deployment.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "provider": "placeholder",
  "assets": {
    "image": {
      "cid": "QmPlaceholderImageCID",
      "url": "ipfs://QmPlaceholderImageCID"
    },
    "metadata": {
      "erc1155": {},
      "arc3": {},
      "contract": {}
    },
    "cids": {
      "image": "QmPlaceholderImageCID",
      "erc1155_metadata": "QmPlaceholderERC1155",
      "arc3_metadata": "QmPlaceholderARC3",
      "contract_metadata": "QmPlaceholderContract"
    }
  },
  "note": "Placeholder CIDs - configure Pinata credentials for real deployment"
}
EOF
        log_info "Placeholder IPFS deployment created"
        return
    fi

    log_step "Pinning assets to IPFS via Pinata..."
    cd "$PROJECT_DIR"

    if command -v tsx >/dev/null 2>&1; then
        tsx scripts/pin_to_ipfs.ts
        log_success "IPFS pinning complete"
    else
        log_error "tsx required for IPFS pinning script"
    fi
}

# ── Phase 4: Smart Contract Deployment ─────────────────────────────────

deploy_contracts() {
    log_phase "SMART CONTRACT DEPLOYMENT"

    # EVM Deployment (Polygon/Base/Ethereum)
    if command -v forge >/dev/null 2>&1 && [[ -n "${PRIVATE_KEY:-}" ]]; then
        log_step "Deploying TrueDeltaVerse.sol to $EVM_NETWORK..."
        cd "$PROJECT_DIR"

        # Set network-specific RPC
        case "$EVM_NETWORK" in
            polygon)
                RPC_URL="${POLYGON_RPC_URL:-https://polygon-rpc.com}"
                ;;
            base)
                RPC_URL="${BASE_RPC_URL:-https://mainnet.base.org}"
                ;;
            ethereum)
                RPC_URL="${ETHEREUM_RPC_URL:-https://eth.llamarpc.com}"
                ;;
            *)
                log_error "Unsupported EVM network: $EVM_NETWORK"
                ;;
        esac

        # Deploy with forge
        if forge script script/DeployTrueDeltaVerse.s.sol --rpc-url "$RPC_URL" --broadcast --verify; then
            log_success "EVM contract deployed to $EVM_NETWORK"
        else
            log_warning "EVM deployment failed"
        fi
    else
        log_warning "Skipping EVM deployment (missing forge or PRIVATE_KEY)"
    fi

    # Algorand Deployment
    if command -v tsx >/dev/null 2>&1 && [[ -n "${ALGORAND_MNEMONIC:-}" ]]; then
        log_step "Minting ARC-3 NFT on Algorand $ALGORAND_NETWORK..."
        cd "$PROJECT_DIR"

        ALGORAND_NETWORK="$ALGORAND_NETWORK" tsx scripts/mint_algorand.ts
        log_success "Algorand ARC-3 minted"
    else
        log_warning "Skipping Algorand deployment (missing tsx or ALGORAND_MNEMONIC)"
    fi
}

# ── Phase 5: Verification ──────────────────────────────────────────────

run_verification() {
    log_phase "VERIFICATION"

    local final_image="$OUTPUT_DIR/true_deltaverse_final.jpg"
    if [[ ! -f "$final_image" ]]; then
        final_image="$OUTPUT_DIR/true_deltaverse.jpg"
    fi

    log_step "Running three-layer verification..."
    cd "$PROJECT_DIR"

    python3 scripts/verify_deltaverse.py "$final_image" --json > "$OUTPUT_DIR/verification_results.json"

    # Display results
    local status=$(python3 -c "import json; print(json.load(open('$OUTPUT_DIR/verification_results.json'))['overall_status'])")

    case "$status" in
        authentic)
            log_success "VERIFICATION: All layers authentic ✅"
            ;;
        suspicious)
            log_warning "VERIFICATION: Some layers failed ⚠️"
            ;;
        error)
            log_error "VERIFICATION: Errors encountered ❌"
            ;;
    esac

    # Show layer breakdown
    python3 -c "
import json
with open('$OUTPUT_DIR/verification_results.json') as f:
    results = json.load(f)

print()
print('Layer Results:')
for layer, data in results['layers'].items():
    status = data.get('status', 'unknown')
    emoji = '✅' if status == 'pass' else '❌' if status == 'fail' else '⚠️'
    print(f'  {emoji} {layer}: {status}')
"
}

# ── Deployment Summary ─────────────────────────────────────────────────

show_summary() {
    log_phase "DEPLOYMENT SUMMARY"

    echo -e "${CYAN}🏛️  TRUE DELTA VERSE DEPLOYMENT COMPLETE${NC}\n"

    # Generated files
    echo -e "${BLUE}📁 Generated Assets:${NC}"
    [[ -f "$OUTPUT_DIR/true_deltaverse.jpg" ]] && echo "   ✅ Original coin image"
    [[ -f "$OUTPUT_DIR/true_deltaverse_final.jpg" ]] && echo "   ✅ Final steganographed image"
    [[ -f "$OUTPUT_DIR/cypherian_weaver.png" ]] && echo "   ✅ Cypherian Weaver visualization"
    [[ -f "$OUTPUT_DIR/manifest.json" ]] && echo "   ✅ Generation manifest"
    [[ -f "$OUTPUT_DIR/payload.json" ]] && echo "   ✅ Steganographic payload"
    echo

    # IPFS deployment
    if [[ -f "$OUTPUT_DIR/ipfs-deployment.json" ]]; then
        echo -e "${BLUE}🌐 IPFS Deployment:${NC}"
        python3 -c "
import json
try:
    with open('$OUTPUT_DIR/ipfs-deployment.json') as f:
        data = json.load(f)

    cids = data.get('assets', {}).get('cids', {})
    for asset_type, cid in cids.items():
        print(f'   📎 {asset_type}: {cid}')
except:
    print('   ⚠️  IPFS deployment data not available')
"
        echo
    fi

    # Contract deployments
    echo -e "${BLUE}🔗 Contract Deployments:${NC}"
    [[ -f "$PROJECT_DIR/deployment.json" ]] && echo "   ✅ EVM deployment info available"
    [[ -f "$PROJECT_DIR/deployment-algorand.json" ]] && echo "   ✅ Algorand deployment info available"
    echo

    # Verification status
    if [[ -f "$OUTPUT_DIR/verification_results.json" ]]; then
        echo -e "${BLUE}🔍 Verification Status:${NC}"
        local status=$(python3 -c "import json; print(json.load(open('$OUTPUT_DIR/verification_results.json'))['overall_status'])")
        case "$status" in
            authentic) echo "   ✅ All layers verified" ;;
            suspicious) echo "   ⚠️  Some layers failed" ;;
            error) echo "   ❌ Verification errors" ;;
        esac
        echo
    fi

    # Next steps
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "   1. Review deployment files in $OUTPUT_DIR/"
    echo "   2. Update contract metadata URIs with IPFS CIDs"
    echo "   3. Mint genesis tokens on deployed contracts"
    echo "   4. Share verification scripts with community"
    echo

    echo -e "${GREEN}🌟 True DELTA VERSE evolution complete!${NC}"
    echo -e "${GREEN}   From decorative binary to self-verifying truth layers.${NC}"
}

# ── Main Execution ─────────────────────────────────────────────────────

main() {
    echo -e "${CYAN}🏛️  TRUE DELTA VERSE - DEPLOYMENT ORCHESTRATOR${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Mode: $MODE${NC}"
    echo -e "${CYAN}EVM Network: $EVM_NETWORK${NC}"
    echo -e "${CYAN}Algorand Network: $ALGORAND_NETWORK${NC}"
    echo -e "${CYAN}DELTAVERSE (c) PYTHAI${NC}"
    echo

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    case "$MODE" in
        full)
            check_prerequisites
            generate_images
            embed_steganography
            pin_to_ipfs
            deploy_contracts
            run_verification
            show_summary
            ;;
        image-only)
            check_prerequisites
            generate_images
            embed_steganography
            run_verification
            ;;
        contracts-only)
            check_prerequisites
            pin_to_ipfs
            deploy_contracts
            ;;
        verify-only)
            check_prerequisites
            run_verification
            ;;
        *)
            log_error "Invalid mode: $MODE. Use: full, image-only, contracts-only, or verify-only"
            ;;
    esac
}

# ── Entry Point ────────────────────────────────────────────────────────

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi