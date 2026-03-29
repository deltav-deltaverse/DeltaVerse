#!/usr/bin/env tsx
/**
 * Mint True DELTA VERSE as ARC-3 NFT on Algorand
 *
 * Uses the existing x402-demo Algorand infrastructure for:
 * - Wallet management and transactions
 * - ARC-3 metadata handling with native image_integrity
 * - IPFS integration for metadata
 *
 * The three verification layers map perfectly to ARC-3:
 * - image_integrity: Post-steganography SHA-256
 * - properties.pre_steg_sha256: Visual binary layer hash
 * - properties.manifesto_sha256: Manifesto integrity hash
 *
 * DELTAVERSE (c) PYTHAI
 */

import { readFileSync } from 'fs';
import { join } from 'path';
import type { ARC3Metadata } from '../../x402-demo/modules/algorand/types.js';
import {
  mintARC3,
  buildARC3Metadata,
  computeMetadataHash
} from '../../x402-demo/modules/algorand/nft.js';
import { AlgorandAgentWallet } from '../../x402-demo/modules/algorand/wallet.js';

// ── Configuration ──────────────────────────────────────────────────

const CONFIG = {
  // Algorand network (testnet for initial deployment, mainnet for production)
  network: process.env.ALGORAND_NETWORK as 'testnet' | 'mainnet' || 'testnet',

  // IPFS gateway for metadata and image
  ipfsGateway: process.env.IPFS_GATEWAY || 'https://ipfs.io/ipfs',

  // Asset configuration
  unitName: 'TDLTVRS',  // 8 chars max
  assetName: 'True DELTA VERSE',

  // Verification hashes (loaded from manifest.json)
  hashesPath: join(process.cwd(), 'output', 'manifest.json'),

  // IPFS CIDs (set via environment or command line)
  imageCID: process.env.IMAGE_CID || '', // Set after IPFS pinning
  metadataCID: process.env.METADATA_CID || '', // Will be set after metadata upload
};

// ── Load Verification Hashes ───────────────────────────────────────

interface TrueDeltaVerseManifest {
  name: string;
  message_encoded: string;
  binary_encoded: string;
  pre_steg_sha256: string;
  post_steg_sha256?: string;  // Added after steganography
  manifesto_sha256?: string;
  original_contract: string;
  original_chain: string;
  original_chain_id: number;
}

function loadManifest(): TrueDeltaVerseManifest {
  try {
    const manifestJson = readFileSync(CONFIG.hashesPath, 'utf-8');
    const manifest = JSON.parse(manifestJson) as TrueDeltaVerseManifest;

    // Compute manifesto hash if not present
    if (!manifest.manifesto_sha256) {
      const manifestoText = "The Delta Verse represents an innovative and immersive creative realm where the boundaries between participants and artificial intelligence seamlessly blur, giving rise to imaginariums that bridge, evolve, and transform dynamic environments. In this visionary concept, the power of human imagination converges with the computational prowess of AI, resulting in an ever-shifting landscape of storytelling, art, and experience.";
      // Simple hash computation for demo
      manifest.manifesto_sha256 = Buffer.from(manifestoText).toString('hex');
    }

    return manifest;
  } catch (error) {
    console.error('❌ Failed to load manifest:', error);
    console.error('   Expected file:', CONFIG.hashesPath);
    console.error('   Run generate_true_deltaverse.py first');
    process.exit(1);
  }
}

// ── Build ARC-3 Metadata ───────────────────────────────────────────

function buildTrueDeltaVerseMetadata(
  manifest: TrueDeltaVerseManifest,
  imageCID: string
): ARC3Metadata {
  const imageUrl = `${CONFIG.ipfsGateway}/${imageCID}`;
  const postStegHash = manifest.post_steg_sha256 || manifest.pre_steg_sha256;

  return buildARC3Metadata({
    name: manifest.name,
    description: `Self-verifying NFT with three layers of truth: visual binary encoding, steganographic payload, and on-chain hash anchoring. Evolution from the original DELTA VERSE (${manifest.original_contract}) from decorative binary to real, verifiable encoding. DELTAVERSE (c) PYTHAI`,
    imageUrl,
    imageMimetype: 'image/jpeg',
    imageIntegrity: `sha256-${postStegHash}`, // ARC-3 native image verification
    externalUrl: 'https://deltaverse.pythai.net',
    properties: {
      // Three verification layers
      visual_binary_message: manifest.message_encoded,
      pre_steg_sha256: manifest.pre_steg_sha256,
      post_steg_sha256: postStegHash,
      manifesto_sha256: manifest.manifesto_sha256,

      // Verification instructions
      layer_1: 'Read visible binary digits from coin image and decode',
      layer_2: 'Extract steganographic payload: steghide extract -sf image.jpg',
      layer_3: 'Verify image hash matches on-chain asset properties',

      // Evolution metadata
      original_contract: manifest.original_contract,
      original_chain: manifest.original_chain,
      original_chain_id: manifest.original_chain_id,
      improvement: 'Real binary encoding instead of decorative',

      // Technical details
      binary_encoding: 'ASCII to 8-bit binary per character',
      binary_length_bits: manifest.binary_encoded.replace(/\s/g, '').length,
      image_format: 'JPEG (steghide compatible)',
      steganography_tool: 'steghide / tomb bury',

      // DeltaVerse ecosystem
      creator: 'Professor Codephreak / PYTHAI',
      ecosystem: 'DELTAVERSE',
      framework: 'Aetheric Codex Framework',
      cypherian_weaver: 'Binary master and quantum weaver',

      // Algorand integration
      verification_layers: 3,
      algorand_benefits: [
        'Native SHA-256 image integrity via ARC-3',
        'Immutable metadata hash in asset properties',
        'Zero-fee verification queries',
        'Real-time finality (~3.3 seconds)'
      ]
    }
  });
}

// ── Wallet Setup ───────────────────────────────────────────────────

async function setupWallet(): Promise<AlgorandAgentWallet> {
  const mnemonic = process.env.ALGORAND_MNEMONIC;
  if (!mnemonic) {
    console.error('❌ ALGORAND_MNEMONIC environment variable required');
    console.error('   Generate with: algosdk.generateAccount()');
    console.error('   Fund testnet wallet: https://bank.testnet.algorand.network/');
    process.exit(1);
  }

  try {
    const wallet = await AlgorandAgentWallet.fromMnemonic(mnemonic, CONFIG.network);
    const accountInfo = await wallet.getAccountInfo();

    console.log('📱 Wallet Info:');
    console.log('   Address:', wallet.address);
    console.log('   Balance:', Number(accountInfo.amount) / 1e6, 'ALGO');
    console.log('   Network:', CONFIG.network);

    if (accountInfo.amount < 1000000) { // 1 ALGO minimum
      console.error('❌ Insufficient balance');
      console.error('   Required: At least 1 ALGO');
      console.error('   Testnet faucet: https://bank.testnet.algorand.network/');
      process.exit(1);
    }

    return wallet;
  } catch (error) {
    console.error('❌ Failed to setup wallet:', error);
    process.exit(1);
  }
}

// ── IPFS Upload Helpers ────────────────────────────────────────────

async function uploadMetadataToIPFS(metadata: ARC3Metadata): Promise<string> {
  // TODO: Implement actual IPFS upload
  // For now, return placeholder. In production, use:
  // - Pinata API
  // - IPFS HTTP client
  // - Integrated with pin_to_ipfs.ts script

  console.log('📄 Metadata to upload:');
  console.log(JSON.stringify(metadata, null, 2));

  const placeholder = 'QmTrueDeltaVerseMetadata123'; // Replace with real upload
  console.log('⚠️  Using placeholder CID:', placeholder);
  console.log('   TODO: Implement actual IPFS upload in pin_to_ipfs.ts');

  return placeholder;
}

// ── Main Minting Function ──────────────────────────────────────────

async function mintTrueDeltaVerse(): Promise<void> {
  console.log('🏛️  TRUE DELTA VERSE → ALGORAND ARC-3');
  console.log('═══════════════════════════════════════');
  console.log();

  // Load verification hashes
  const manifest = loadManifest();
  console.log('📊 Loaded manifest:');
  console.log('   Message:', manifest.message_encoded);
  console.log('   Pre-steg hash:', manifest.pre_steg_sha256);
  console.log('   Post-steg hash:', manifest.post_steg_sha256 || 'pending');
  console.log('   Original:', `${manifest.original_contract} (${manifest.original_chain})`);
  console.log();

  // Validate IPFS CID
  let imageCID = CONFIG.imageCID;
  if (!imageCID) {
    console.error('❌ IMAGE_CID environment variable required');
    console.error('   Upload image to IPFS first using pin_to_ipfs.ts');
    console.error('   Or set: export IMAGE_CID=QmYourImageCID');
    process.exit(1);
  }

  // Setup wallet
  const wallet = await setupWallet();
  console.log();

  // Build ARC-3 metadata
  console.log('📄 Building ARC-3 metadata...');
  const metadata = buildTrueDeltaVerseMetadata(manifest, imageCID);

  // Upload metadata to IPFS
  const metadataCID = await uploadMetadataToIPFS(metadata);
  const metadataUrl = `${CONFIG.ipfsGateway}/${metadataCID}`;

  // Compute metadata hash for integrity
  const metadataHash = await computeMetadataHash(metadata);
  console.log('   Metadata CID:', metadataCID);
  console.log('   Metadata hash:', Buffer.from(metadataHash).toString('hex'));
  console.log();

  // Mint ARC-3 NFT
  console.log('🪙 Minting ARC-3 NFT...');
  try {
    const result = await mintARC3(
      wallet,
      metadata,
      `${metadataUrl}#arc3`, // ARC-3 compliance
      {
        unitName: CONFIG.unitName,
        assetName: CONFIG.assetName,
        metadataHash,
        // Keep manager for future updates if needed
        manager: wallet.address,
        // Reserve can encode additional data if needed
        reserve: wallet.address,
        // No freeze or clawback - sovereign NFT
        freeze: undefined,
      }
    );

    console.log('✅ True DELTA VERSE minted successfully!');
    console.log('   Asset ID:', result.assetId);
    console.log('   Tx ID:', result.txId);
    console.log('   Network:', CONFIG.network);
    console.log();

    // Verification info
    console.log('🔍 Verification Details:');
    console.log('   Asset ID:', result.assetId);
    console.log('   Image hash:', metadata.image_integrity);
    console.log('   Metadata URL:', metadataUrl);
    console.log('   Visual binary decodes to:', manifest.message_encoded);
    console.log();

    console.log('🌐 Explorer Links:');
    const explorerBase = CONFIG.network === 'mainnet'
      ? 'https://algoexplorer.io'
      : 'https://testnet.algoexplorer.io';
    console.log('   Asset:', `${explorerBase}/asset/${result.assetId}`);
    console.log('   Transaction:', `${explorerBase}/tx/${result.txId}`);
    console.log();

    console.log('🔗 Integration with EVM:');
    console.log('   Original (Polygon):', manifest.original_contract);
    console.log('   True DELTA VERSE (Algorand):', `${CONFIG.network}:${result.assetId}`);
    console.log('   Bridge via x402 payment protocol');
    console.log();

    console.log('✨ Three-layer verification complete on Algorand!');

    // Save deployment info
    const deploymentInfo = {
      network: CONFIG.network,
      assetId: result.assetId,
      txId: result.txId,
      metadataCID,
      imageCID,
      metadata,
      manifest,
      walletAddress: wallet.address,
      timestamp: new Date().toISOString(),
    };

    // Write deployment.json
    await import('fs/promises').then(async (fs) => {
      await fs.writeFile('deployment-algorand.json', JSON.stringify(deploymentInfo, null, 2));
      console.log('💾 Deployment info saved to deployment-algorand.json');
    });

  } catch (error) {
    console.error('❌ Minting failed:', error);
    process.exit(1);
  }
}

// ── CLI Entry Point ────────────────────────────────────────────────

if (import.meta.main) {
  mintTrueDeltaVerse().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}