// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/TrueDeltaVerse.sol";

/**
 * @title Deploy True DELTA VERSE
 * @dev Deployment script for the self-verifying True DELTA VERSE NFT
 * @author Professor Codephreak / PYTHAI
 */
contract DeployTrueDeltaVerse is Script {
    // ── Verification Hashes (from image generation) ──

    // Pre-steganography hash - visual binary layer only
    bytes32 constant PRE_STEG_HASH = 0x8634ad295a4c0c8327085e9e9cc30eabd2074210f062a3abc1deaef9e9e3a50f;

    // Post-steganography hash - includes hidden payload (UPDATE after steghide embed)
    bytes32 constant POST_STEG_HASH = 0x0000000000000000000000000000000000000000000000000000000000000000; // TODO: Update after steghide

    // DELTAVERSE manifesto hash
    bytes32 constant MANIFESTO_HASH = keccak256(
        "The Delta Verse represents an innovative and immersive creative realm where the boundaries between participants and artificial intelligence seamlessly blur, giving rise to imaginariums that bridge, evolve, and transform dynamic environments. In this visionary concept, the power of human imagination converges with the computational prowess of AI, resulting in an ever-shifting landscape of storytelling, art, and experience."
    );

    // ── Metadata URIs ──

    // Contract metadata (collection-level)
    string constant CONTRACT_URI = "ipfs://QmTrueDeltaVerseContract"; // TODO: Update with real IPFS CID

    // Token metadata template (will be set per token)
    string constant TOKEN_URI_TEMPLATE = "ipfs://QmTrueDeltaVerseToken"; // TODO: Update with real IPFS CID

    // ── Configuration ──

    // Royalty recipient (5% royalties)
    address constant ROYALTY_RECIPIENT = 0xbC62D5e6e3555438061a3D12b7Cd94AaBEe07346; // Original creator from manifest

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        console.log("=== Deploying True DELTA VERSE ===");
        console.log("Deployer:", msg.sender);
        console.log("Chain ID:", block.chainid);
        console.log();

        // Validation checks
        require(PRE_STEG_HASH != bytes32(0), "Pre-steg hash required");
        require(ROYALTY_RECIPIENT != address(0), "Royalty recipient required");

        // Deploy the contract
        console.log("Deploying TrueDeltaVerse contract...");

        TrueDeltaVerse trueDeltaVerse = new TrueDeltaVerse(
            PRE_STEG_HASH,
            POST_STEG_HASH,      // Will be updated later if needed
            MANIFESTO_HASH,
            ROYALTY_RECIPIENT,
            CONTRACT_URI
        );

        console.log("TrueDeltaVerse deployed at:", address(trueDeltaVerse));
        console.log();

        // Verify deployment
        console.log("=== Verification ===");
        console.log("Pre-steg hash:   ", vm.toString(PRE_STEG_HASH));
        console.log("Post-steg hash:  ", vm.toString(POST_STEG_HASH));
        console.log("Manifesto hash:  ", vm.toString(MANIFESTO_HASH));
        console.log("Royalty to:      ", ROYALTY_RECIPIENT);
        console.log("Contract URI:    ", trueDeltaVerse.contractURI());
        console.log();

        (address originalContract, uint256 originalChainId) = trueDeltaVerse.getOriginalReference();
        console.log("Original reference:");
        console.log("  Contract:      ", originalContract);
        console.log("  Chain ID:      ", originalChainId);
        console.log();

        // Optional: Mint genesis token if deployer wants immediate minting
        bool mintGenesis = vm.envOr("MINT_GENESIS", false);
        if (mintGenesis) {
            address genesisRecipient = vm.envOr("GENESIS_RECIPIENT", msg.sender);
            string memory genesisTokenURI = vm.envOr("GENESIS_TOKEN_URI", TOKEN_URI_TEMPLATE);

            console.log("Minting genesis token...");
            console.log("Recipient:       ", genesisRecipient);
            console.log("Token URI:       ", genesisTokenURI);

            trueDeltaVerse.mintGenesis(genesisRecipient, genesisTokenURI);

            console.log("Genesis token minted successfully");
            console.log("Token ID:        ", trueDeltaVerse.GENESIS_TOKEN_ID());
            console.log("Total supply:    ", trueDeltaVerse.totalSupply(trueDeltaVerse.GENESIS_TOKEN_ID()));
            console.log();
        }

        vm.stopBroadcast();

        // ── Post-deployment instructions ──

        console.log("=== Next Steps ===");
        console.log("1. Update POST_STEG_HASH after running steganography embedding:");
        console.log("   - Run: ./scripts/embed_steganography.sh");
        console.log("   - Update POST_STEG_HASH in this script with final image hash");
        console.log("   - Call trueDeltaVerse.updateHashes() with new post-steg hash");
        console.log();
        console.log("2. Pin metadata to IPFS:");
        console.log("   - Contract metadata at:", CONTRACT_URI);
        console.log("   - Token metadata at:   ", TOKEN_URI_TEMPLATE);
        console.log();
        console.log("3. Verify the contract on block explorer");
        console.log();
        console.log("4. Run verification script:");
        console.log("   python3 scripts/verify_deltaverse.py <image_path> -c", address(trueDeltaVerse));
        console.log();

        // ── Export deployment info ──

        string memory deploymentInfo = string(abi.encodePacked(
            "{\n",
            '  "contract_address": "', vm.toString(address(trueDeltaVerse)), '",\n',
            '  "chain_id": ', vm.toString(block.chainid), ',\n',
            '  "deployer": "', vm.toString(msg.sender), '",\n',
            '  "pre_steg_hash": "', vm.toString(PRE_STEG_HASH), '",\n',
            '  "post_steg_hash": "', vm.toString(POST_STEG_HASH), '",\n',
            '  "manifesto_hash": "', vm.toString(MANIFESTO_HASH), '",\n',
            '  "royalty_recipient": "', vm.toString(ROYALTY_RECIPIENT), '",\n',
            '  "contract_uri": "', CONTRACT_URI, '",\n',
            '  "original_contract": "', vm.toString(originalContract), '",\n',
            '  "original_chain_id": ', vm.toString(originalChainId), '\n',
            "}"
        ));

        vm.writeFile("./deployment.json", deploymentInfo);
        console.log("Deployment info saved to: deployment.json");

        console.log();
        console.log("*** True DELTA VERSE deployment complete! ***");
        console.log("Evolution from decorative binary to self-verifying truth layers achieved.");
    }

    // ── Helper Functions ──

    /**
     * @dev Update the post-steganography hash after embedding
     * @param contractAddress Deployed contract address
     * @param newPostStegHash New hash after steganographic embedding
     */
    function updatePostStegHash(address contractAddress, bytes32 newPostStegHash) external {
        require(contractAddress != address(0), "Invalid contract address");
        require(newPostStegHash != bytes32(0), "Invalid hash");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TrueDeltaVerse trueDeltaVerse = TrueDeltaVerse(contractAddress);

        console.log("Updating post-steganography hash...");
        console.log("Contract:        ", contractAddress);
        console.log("New post-steg:   ", vm.toString(newPostStegHash));

        // Get current hashes
        (bytes32 currentPre, , bytes32 currentManifesto) = trueDeltaVerse.getVerificationHashes();

        // Update with new post-steg hash, keep others the same
        trueDeltaVerse.updateHashes(currentPre, newPostStegHash, currentManifesto);

        console.log("Hash updated successfully");

        vm.stopBroadcast();
    }
}