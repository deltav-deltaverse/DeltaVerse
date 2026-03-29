# True DELTA VERSE - Metadata Templates

This directory contains JSON metadata templates for the True DELTA VERSE NFT collection.

## Templates

### 📄 `erc1155-metadata.json`
**ERC-1155 compliant metadata** for EVM deployments (Polygon, Ethereum, Base)
- OpenSea compatible attributes and properties
- Three-layer verification instructions
- Evolution story from original DELTA VERSE
- Complete technical specifications
- Usage guide for verification

### 📄 `arc3-metadata.json`
**ARC-3 compliant metadata** for Algorand deployment
- Native `image_integrity` field for SHA-256 verification
- Algorand-specific benefits highlighted
- Cross-chain evolution narrative
- Zero-fee verification instructions
- Localization support ready

### 📄 `contract-metadata.json`
**Collection-level metadata** for both EVM and Algorand
- Complete collection description and roadmap
- Creator information and royalty details
- DELTAVERSE ecosystem integration
- Lore and character background (Cypherian Weaver)
- Legal and licensing information

## Template Variables

All templates use `{{VARIABLE}}` syntax for dynamic replacement:

### Image & CIDs
- `{{IMAGE_CID}}` - IPFS CID of the final steganographed image
- `{{BANNER_CID}}` - Collection banner image CID
- `{{LOCALIZATION_CID}}` - Localization files CID

### Verification Hashes
- `{{PRE_STEG_HASH}}` - SHA-256 before steganographic embedding
- `{{POST_STEG_HASH}}` - SHA-256 after steganographic embedding
- `{{MANIFESTO_HASH}}` - SHA-256 of the DELTAVERSE manifesto
- `{{METADATA_HASH}}` - SHA-256 of the metadata JSON (ARC-3)

### Asset Information
- `{{ASSET_ID}}` - Algorand asset ID (after minting)
- `{{FILE_SIZE}}` - Image file size in bytes
- `{{TIMESTAMP}}` - ISO timestamp of creation

## Usage

### 1. Manual Replacement
```bash
# Replace template variables with actual values
sed 's/{{IMAGE_CID}}/QmActualImageCID/g' erc1155-metadata.json > metadata.json
```

### 2. Script Integration
Templates are automatically processed by:
- `pin_to_ipfs.ts` - Builds and uploads metadata with real values
- `mint_algorand.ts` - Uses ARC-3 template for Algorand deployment
- `DeployTrueDeltaVerse.s.sol` - References contract metadata CID

### 3. Verification
After deployment, verify templates contain:
- ✅ Correct verification instructions for all three layers
- ✅ Proper IPFS CID references
- ✅ Accurate hash values
- ✅ Valid JSON structure
- ✅ Standard compliance (ERC-1155/ARC-3)

## Standards Compliance

### ERC-1155 Metadata Standard
- ✅ Required: `name`, `description`, `image`
- ✅ Optional: `external_url`, `animation_url`, `attributes`
- ✅ Properties: Custom verification data
- ✅ OpenSea: Compatible trait format

### ARC-3 Metadata Standard
- ✅ Required: `name`, `image`
- ✅ Integrity: `image_integrity` with SHA-256
- ✅ Properties: Algorand-specific data
- ✅ Localization: Multi-language ready

### Collection Standards
- ✅ Creator verification and royalties
- ✅ External links and social media
- ✅ Legal and licensing information
- ✅ Ecosystem integration details

## Verification Instructions

Each template includes complete verification guides:

1. **Visual Binary Layer**: Read and decode visible binary digits
2. **Steganographic Layer**: Extract hidden payload via steghide/tomb
3. **On-Chain Layer**: Verify image hash against smart contract/asset

The templates serve as both metadata and user documentation for the complete verification process.

---

**DELTAVERSE (c) PYTHAI**
*True DELTA VERSE: Where every pixel proves its purpose*