#!/usr/bin/env tsx
/**
 * Pin True DELTA VERSE assets to IPFS
 *
 * Handles upload and pinning of:
 * - Final steganographed image (JPEG)
 * - ERC-1155 metadata JSON
 * - ARC-3 metadata JSON
 * - Contract-level metadata
 *
 * Supports multiple IPFS providers:
 * - Pinata (default - requires API key)
 * - web3.storage
 * - Local IPFS node
 * - Any HTTP IPFS API
 *
 * DELTAVERSE (c) PYTHAI
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join, basename } from 'path';

// ── Types ──────────────────────────────────────────────────────────

interface IPFSProvider {
  name: string;
  upload(file: File | Buffer, filename: string, metadata?: Record<string, any>): Promise<IPFSResult>;
  uploadJSON(data: object, filename: string): Promise<IPFSResult>;
}

interface IPFSResult {
  cid: string;
  url: string;
  size: number;
  provider: string;
}

interface TrueDeltaVerseAssets {
  image: {
    path: string;
    cid?: string;
    url?: string;
  };
  metadata: {
    erc1155: object;
    arc3: object;
    contract: object;
  };
  cids: {
    image?: string;
    erc1155_metadata?: string;
    arc3_metadata?: string;
    contract_metadata?: string;
  };
}

// ── Configuration ──────────────────────────────────────────────────

const CONFIG = {
  // IPFS provider selection
  provider: process.env.IPFS_PROVIDER || 'pinata',

  // Provider credentials
  pinataApiKey: process.env.PINATA_API_KEY || '',
  pinataSecretKey: process.env.PINATA_SECRET_API_KEY || '',
  web3StorageToken: process.env.WEB3_STORAGE_TOKEN || '',

  // File paths
  outputDir: join(process.cwd(), 'output'),
  finalImagePath: join(process.cwd(), 'output', 'true_deltaverse_final.jpg'),
  manifestPath: join(process.cwd(), 'output', 'manifest.json'),

  // IPFS gateway for URL construction
  ipfsGateway: process.env.IPFS_GATEWAY || 'https://ipfs.io/ipfs',

  // Pinning options
  pinOptions: {
    name: 'True DELTA VERSE',
    keyvalues: {
      project: 'deltaverse',
      type: 'nft_asset',
      creator: 'Professor Codephreak / PYTHAI',
      copyright: 'DELTAVERSE (c) PYTHAI'
    }
  }
};

// ── Pinata Provider ────────────────────────────────────────────────

class PinataProvider implements IPFSProvider {
  name = 'Pinata';

  private apiKey: string;
  private secretKey: string;

  constructor(apiKey: string, secretKey: string) {
    this.apiKey = apiKey;
    this.secretKey = secretKey;
  }

  async upload(fileBuffer: Buffer, filename: string, metadata?: Record<string, any>): Promise<IPFSResult> {
    const url = 'https://api.pinata.cloud/pinning/pinFileToIPFS';

    const formData = new FormData();

    // Create file from buffer
    const file = new File([fileBuffer], filename, {
      type: this.getMimeType(filename)
    });
    formData.append('file', file);

    // Add metadata
    if (metadata) {
      formData.append('pinataMetadata', JSON.stringify({
        name: filename,
        keyvalues: { ...CONFIG.pinOptions.keyvalues, ...metadata }
      }));
    }

    formData.append('pinataOptions', JSON.stringify({
      cidVersion: 1
    }));

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'pinata_api_key': this.apiKey,
        'pinata_secret_api_key': this.secretKey,
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Pinata upload failed: ${response.status} ${error}`);
    }

    const result = await response.json();

    return {
      cid: result.IpfsHash,
      url: `${CONFIG.ipfsGateway}/${result.IpfsHash}`,
      size: result.PinSize,
      provider: this.name
    };
  }

  async uploadJSON(data: object, filename: string): Promise<IPFSResult> {
    const jsonStr = JSON.stringify(data, null, 2);
    const buffer = Buffer.from(jsonStr, 'utf-8');

    return this.upload(buffer, filename, { content_type: 'application/json' });
  }

  private getMimeType(filename: string): string {
    const ext = filename.split('.').pop()?.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }
}

// ── Web3.Storage Provider ──────────────────────────────────────────

class Web3StorageProvider implements IPFSProvider {
  name = 'web3.storage';

  private token: string;

  constructor(token: string) {
    this.token = token;
  }

  async upload(fileBuffer: Buffer, filename: string): Promise<IPFSResult> {
    // Simplified implementation - would need actual web3.storage client
    throw new Error('web3.storage provider not implemented yet');
  }

  async uploadJSON(data: object, filename: string): Promise<IPFSResult> {
    throw new Error('web3.storage provider not implemented yet');
  }
}

// ── Provider Factory ───────────────────────────────────────────────

function createProvider(): IPFSProvider {
  switch (CONFIG.provider) {
    case 'pinata':
      if (!CONFIG.pinataApiKey || !CONFIG.pinataSecretKey) {
        throw new Error('Pinata credentials required: PINATA_API_KEY and PINATA_SECRET_API_KEY');
      }
      return new PinataProvider(CONFIG.pinataApiKey, CONFIG.pinataSecretKey);

    case 'web3storage':
      if (!CONFIG.web3StorageToken) {
        throw new Error('Web3.Storage token required: WEB3_STORAGE_TOKEN');
      }
      return new Web3StorageProvider(CONFIG.web3StorageToken);

    default:
      throw new Error(`Unsupported IPFS provider: ${CONFIG.provider}`);
  }
}

// ── Metadata Builders ──────────────────────────────────────────────

function buildERC1155Metadata(manifest: any, imageCID: string): object {
  const imageUrl = `ipfs://${imageCID}`;

  return {
    name: 'True DELTA VERSE',
    description: `Self-verifying NFT with three layers of truth: visual binary encoding, steganographic payload, and on-chain hash anchoring. Evolution from the original DELTA VERSE (${manifest.original_contract}) from decorative binary to real, verifiable encoding.`,
    image: imageUrl,
    external_url: 'https://deltaverse.pythai.net',
    attributes: [
      { trait_type: 'Type', value: 'Self-Verifying NFT' },
      { trait_type: 'Layers', value: 'Three' },
      { trait_type: 'Binary Encoding', value: 'Real' },
      { trait_type: 'Steganography', value: 'Tomb/Steghide' },
      { trait_type: 'Creator', value: 'Professor Codephreak / PYTHAI' },
      { trait_type: 'Original Contract', value: manifest.original_contract },
      { trait_type: 'Original Chain', value: manifest.original_chain },
      { trait_type: 'Pre-Steg Hash', value: manifest.pre_steg_sha256 },
      { trait_type: 'Message Encoded', value: manifest.message_encoded }
    ],
    properties: {
      visual_binary_message: manifest.message_encoded,
      binary_length_bits: manifest.binary_length_bits,
      pre_steg_sha256: manifest.pre_steg_sha256,
      post_steg_sha256: manifest.post_steg_sha256,
      verification_layers: 3,
      steganography_tool: 'steghide',
      extraction_command: 'steghide extract -sf true_deltaverse_final.jpg -p passphrase',
      original_reference: {
        contract: manifest.original_contract,
        chain: manifest.original_chain,
        chain_id: manifest.original_chain_id
      },
      copyright: 'DELTAVERSE (c) PYTHAI'
    }
  };
}

function buildARC3Metadata(manifest: any, imageCID: string): object {
  const imageUrl = `ipfs://${imageCID}`;
  const postStegHash = manifest.post_steg_sha256 || manifest.pre_steg_sha256;

  return {
    name: 'True DELTA VERSE',
    description: `Self-verifying NFT with three layers of truth on Algorand. Visual binary encoding, steganographic payload, and native ARC-3 image integrity verification.`,
    image: imageUrl,
    image_integrity: `sha256-${postStegHash}`,
    image_mimetype: 'image/jpeg',
    external_url: 'https://deltaverse.pythai.net',
    properties: {
      visual_binary_message: manifest.message_encoded,
      pre_steg_sha256: manifest.pre_steg_sha256,
      post_steg_sha256: postStegHash,
      verification_layers: 3,
      layer_1: 'Read visible binary digits and decode',
      layer_2: 'Extract steganographic payload via steghide',
      layer_3: 'Verify image_integrity hash matches',
      algorand_benefits: [
        'Native SHA-256 image integrity',
        'Immutable asset properties',
        'Zero-fee verification',
        'Real-time finality'
      ],
      original_evolution: {
        contract: manifest.original_contract,
        chain: manifest.original_chain,
        improvement: 'Real binary encoding instead of decorative'
      },
      creator: 'Professor Codephreak / PYTHAI',
      copyright: 'DELTAVERSE (c) PYTHAI'
    }
  };
}

function buildContractMetadata(imageCID: string): object {
  return {
    name: 'True DELTA VERSE Collection',
    description: 'Evolution of the DELTA VERSE from decorative binary to self-verifying NFTs with three layers of truth. Each token contains real binary encoding that can be read and verified, hidden steganographic payloads, and on-chain hash anchoring.',
    image: `ipfs://${imageCID}`,
    external_link: 'https://deltaverse.pythai.net',
    seller_fee_basis_points: 500, // 5%
    fee_recipient: '0xbC62D5e6e3555438061a3D12b7Cd94AaBEe07346',
    collection: {
      name: 'True DELTA VERSE',
      family: 'DELTAVERSE'
    },
    properties: {
      category: 'image',
      creators: [
        {
          address: '0xbC62D5e6e3555438061a3D12b7Cd94AaBEe07346',
          share: 100
        }
      ]
    },
    attributes: [
      { trait_type: 'Collection Type', value: 'Self-Verifying NFT' },
      { trait_type: 'Verification Layers', value: '3' },
      { trait_type: 'Creator', value: 'Professor Codephreak / PYTHAI' },
      { trait_type: 'Copyright', value: 'DELTAVERSE (c) PYTHAI' }
    ]
  };
}

// ── Main Upload Function ───────────────────────────────────────────

async function uploadTrueDeltaVerseAssets(): Promise<TrueDeltaVerseAssets> {
  console.log('📡 IPFS UPLOAD - TRUE DELTA VERSE');
  console.log('════════════════════════════════════');
  console.log(`Provider: ${CONFIG.provider}`);
  console.log();

  // Initialize provider
  const provider = createProvider();

  // Load manifest
  if (!existsSync(CONFIG.manifestPath)) {
    throw new Error(`Manifest not found: ${CONFIG.manifestPath}\nRun generate_true_deltaverse.py first`);
  }

  const manifestData = JSON.parse(readFileSync(CONFIG.manifestPath, 'utf-8'));

  // Check for final image (post steganography)
  let imagePath = CONFIG.finalImagePath;
  if (!existsSync(imagePath)) {
    console.log('⚠️  Final steganographed image not found, using original');
    imagePath = join(CONFIG.outputDir, 'true_deltaverse.jpg');

    if (!existsSync(imagePath)) {
      throw new Error(`No image found at ${imagePath}\nRun generate_true_deltaverse.py first`);
    }
  }

  const result: TrueDeltaVerseAssets = {
    image: { path: imagePath },
    metadata: {
      erc1155: {},
      arc3: {},
      contract: {}
    },
    cids: {}
  };

  console.log('📁 Assets to upload:');
  console.log(`   Image: ${basename(imagePath)}`);
  console.log(`   Manifest: ${basename(CONFIG.manifestPath)}`);
  console.log();

  // 1. Upload image
  console.log('🖼️  Uploading image...');
  const imageBuffer = readFileSync(imagePath);
  const imageResult = await provider.upload(
    imageBuffer,
    basename(imagePath),
    {
      type: 'nft_image',
      layer: 'steganographic' // or 'visual' if using original
    }
  );

  result.image.cid = imageResult.cid;
  result.image.url = imageResult.url;
  result.cids.image = imageResult.cid;

  console.log(`   CID: ${imageResult.cid}`);
  console.log(`   URL: ${imageResult.url}`);
  console.log(`   Size: ${imageResult.size} bytes`);
  console.log();

  // 2. Build and upload ERC-1155 metadata
  console.log('📄 Building ERC-1155 metadata...');
  const erc1155Metadata = buildERC1155Metadata(manifestData, imageResult.cid);
  result.metadata.erc1155 = erc1155Metadata;

  const erc1155Result = await provider.uploadJSON(erc1155Metadata, 'metadata-erc1155.json');
  result.cids.erc1155_metadata = erc1155Result.cid;

  console.log(`   CID: ${erc1155Result.cid}`);
  console.log(`   URL: ${erc1155Result.url}`);
  console.log();

  // 3. Build and upload ARC-3 metadata
  console.log('📄 Building ARC-3 metadata...');
  const arc3Metadata = buildARC3Metadata(manifestData, imageResult.cid);
  result.metadata.arc3 = arc3Metadata;

  const arc3Result = await provider.uploadJSON(arc3Metadata, 'metadata-arc3.json');
  result.cids.arc3_metadata = arc3Result.cid;

  console.log(`   CID: ${arc3Result.cid}`);
  console.log(`   URL: ${arc3Result.url}`);
  console.log();

  // 4. Build and upload contract metadata
  console.log('📄 Building contract metadata...');
  const contractMetadata = buildContractMetadata(imageResult.cid);
  result.metadata.contract = contractMetadata;

  const contractResult = await provider.uploadJSON(contractMetadata, 'contract-metadata.json');
  result.cids.contract_metadata = contractResult.cid;

  console.log(`   CID: ${contractResult.cid}`);
  console.log(`   URL: ${contractResult.url}`);
  console.log();

  // Save deployment info
  const deploymentInfo = {
    timestamp: new Date().toISOString(),
    provider: provider.name,
    assets: result,
    urls: {
      image: imageResult.url,
      erc1155_metadata: erc1155Result.url,
      arc3_metadata: arc3Result.url,
      contract_metadata: contractResult.url
    },
    usage: {
      evm_deployment: `forge script script/DeployTrueDeltaVerse.s.sol --broadcast`,
      algorand_minting: `tsx scripts/mint_algorand.ts`,
      environment_vars: {
        IMAGE_CID: imageResult.cid,
        ERC1155_METADATA_CID: erc1155Result.cid,
        ARC3_METADATA_CID: arc3Result.cid,
        CONTRACT_METADATA_CID: contractResult.cid
      }
    }
  };

  const ipfsDeploymentPath = join(CONFIG.outputDir, 'ipfs-deployment.json');
  writeFileSync(ipfsDeploymentPath, JSON.stringify(deploymentInfo, null, 2));

  console.log('✅ UPLOAD COMPLETE');
  console.log('═════════════════════');
  console.log(`📁 Image CID: ${imageResult.cid}`);
  console.log(`📄 ERC-1155 CID: ${erc1155Result.cid}`);
  console.log(`📄 ARC-3 CID: ${arc3Result.cid}`);
  console.log(`📄 Contract CID: ${contractResult.cid}`);
  console.log();
  console.log('🔧 Next Steps:');
  console.log('   1. Deploy EVM contract with these CIDs');
  console.log('   2. Mint Algorand ARC-3 with ARC3_METADATA_CID');
  console.log('   3. Update environment variables for scripts');
  console.log();
  console.log(`💾 Deployment details: ${ipfsDeploymentPath}`);

  return result;
}

// ── CLI Entry Point ────────────────────────────────────────────────

async function main() {
  try {
    const result = await uploadTrueDeltaVerseAssets();

    // Export environment variables for easy copy-paste
    console.log('📋 Environment Variables:');
    console.log(`export IMAGE_CID="${result.cids.image}"`);
    console.log(`export ERC1155_METADATA_CID="${result.cids.erc1155_metadata}"`);
    console.log(`export ARC3_METADATA_CID="${result.cids.arc3_metadata}"`);
    console.log(`export CONTRACT_METADATA_CID="${result.cids.contract_metadata}"`);
    console.log();

  } catch (error) {
    console.error('❌ Upload failed:', error);
    process.exit(1);
  }
}

if (import.meta.main) {
  main();
}