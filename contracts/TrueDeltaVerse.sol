// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title TrueDeltaVerse
 * @dev Self-verifying NFT with three layers of truth:
 *      1. Visual binary layer - readable binary digits in image
 *      2. Steganographic layer - hidden payload via steghide/tomb
 *      3. On-chain layer - immutable hash anchoring
 *
 *      Evolution from the original DELTA VERSE (0x024b464ec595f20040002237680026bf006e8f90)
 *      from decorative binary to real, verifiable binary encoding.
 *
 * @author Professor Codephreak / PYTHAI
 * @notice DELTAVERSE (c) PYTHAI
 */
contract TrueDeltaVerse is ERC1155URIStorage, ERC1155Supply, Ownable, IERC2981 {

    // ── Constants ──

    uint256 public constant GENESIS_TOKEN_ID = 1;
    uint256 public constant ROYALTY_BASIS_POINTS = 500; // 5%

    // ── State Variables ──

    /// @notice Pre-steganography SHA-256 hash (visual layer only)
    bytes32 public preStegHash;

    /// @notice Post-steganography SHA-256 hash (includes hidden payload)
    bytes32 public postStegHash;

    /// @notice Manifesto hash for integrity verification
    bytes32 public manifestoHash;

    /// @notice Contract-level metadata URI
    string private _contractURI;

    /// @notice Original contract reference
    address public constant ORIGINAL_CONTRACT = 0x024b464ec595F20040002237680026bf006e8F90;
    uint256 public constant ORIGINAL_CHAIN_ID = 137; // Polygon

    /// @notice Royalty recipient
    address public royaltyRecipient;

    // ── Events ──

    /// @notice Emitted when someone verifies an image hash
    /// @param verifier Address performing verification
    /// @param candidateHash Hash being verified
    /// @param hashType Type of hash (pre_steg, post_steg, manifesto)
    /// @param matches Whether the hash matches the stored value
    event HashVerified(
        address indexed verifier,
        bytes32 indexed candidateHash,
        string hashType,
        bool matches
    );

    /// @notice Emitted when hashes are updated (owner only)
    /// @param preSteg New pre-steganography hash
    /// @param postSteg New post-steganography hash
    /// @param manifesto New manifesto hash
    event HashesUpdated(bytes32 preSteg, bytes32 postSteg, bytes32 manifesto);

    /// @notice Emitted when the genesis token is minted
    /// @param to Recipient of the genesis token
    /// @param tokenId Always 1 (genesis)
    /// @param tokenURI Metadata URI pointing to IPFS
    event GenesisMinted(address indexed to, uint256 indexed tokenId, string tokenURI);

    // ── Constructor ──

    /**
     * @dev Initialize the True DELTA VERSE contract
     * @param _preStegHash Pre-steganography image hash
     * @param _postStegHash Post-steganography image hash
     * @param _manifestoHash DELTAVERSE manifesto hash
     * @param _royaltyRecipient Address to receive royalties
     * @param contractURI_ Contract-level metadata URI
     */
    constructor(
        bytes32 _preStegHash,
        bytes32 _postStegHash,
        bytes32 _manifestoHash,
        address _royaltyRecipient,
        string memory contractURI_
    ) ERC1155("") Ownable(msg.sender) {
        preStegHash = _preStegHash;
        postStegHash = _postStegHash;
        manifestoHash = _manifestoHash;
        royaltyRecipient = _royaltyRecipient;
        _contractURI = contractURI_;

        emit HashesUpdated(_preStegHash, _postStegHash, _manifestoHash);
    }

    // ── Minting Functions ──

    /**
     * @dev Mint the genesis True DELTA VERSE token
     * @param to Recipient address
     * @param tokenURI Token metadata URI (IPFS)
     */
    function mintGenesis(address to, string memory tokenURI) external onlyOwner {
        require(totalSupply(GENESIS_TOKEN_ID) == 0, "Genesis already minted");
        require(bytes(tokenURI).length > 0, "Token URI required");

        _mint(to, GENESIS_TOKEN_ID, 1, "");
        _setURI(GENESIS_TOKEN_ID, tokenURI);

        emit GenesisMinted(to, GENESIS_TOKEN_ID, tokenURI);
    }

    /**
     * @dev Mint additional tokens (future evolution)
     * @param to Recipient address
     * @param tokenId Token ID (must be > 1)
     * @param amount Amount to mint
     * @param tokenURI Token metadata URI
     */
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        string memory tokenURI
    ) external onlyOwner {
        require(tokenId > GENESIS_TOKEN_ID, "Use mintGenesis for token 1");
        require(amount > 0, "Amount must be positive");
        require(bytes(tokenURI).length > 0, "Token URI required");

        _mint(to, tokenId, amount, "");
        _setURI(tokenId, tokenURI);
    }

    // ── Verification Functions ──

    /**
     * @dev Verify a candidate hash against the stored pre-steganography hash
     * @param candidateHash The hash to verify
     * @return matches Whether the hash matches
     */
    function verifyPreStegHash(bytes32 candidateHash) external returns (bool matches) {
        matches = candidateHash == preStegHash;
        emit HashVerified(msg.sender, candidateHash, "pre_steg", matches);
        return matches;
    }

    /**
     * @dev Verify a candidate hash against the stored post-steganography hash
     * @param candidateHash The hash to verify
     * @return matches Whether the hash matches
     */
    function verifyPostStegHash(bytes32 candidateHash) external returns (bool matches) {
        matches = candidateHash == postStegHash;
        emit HashVerified(msg.sender, candidateHash, "post_steg", matches);
        return matches;
    }

    /**
     * @dev Verify a candidate hash against the stored manifesto hash
     * @param candidateHash The hash to verify
     * @return matches Whether the hash matches
     */
    function verifyManifestoHash(bytes32 candidateHash) external returns (bool matches) {
        matches = candidateHash == manifestoHash;
        emit HashVerified(msg.sender, candidateHash, "manifesto", matches);
        return matches;
    }

    /**
     * @dev Verify all three hashes at once
     * @param _preSteg Pre-steganography hash
     * @param _postSteg Post-steganography hash
     * @param _manifesto Manifesto hash
     * @return preMatch Results for pre-steg hash
     * @return postMatch Results for post-steg hash
     * @return manifestoMatch Results for manifesto hash
     */
    function verifyAllHashes(
        bytes32 _preSteg,
        bytes32 _postSteg,
        bytes32 _manifesto
    ) external returns (bool preMatch, bool postMatch, bool manifestoMatch) {
        preMatch = (_preSteg == preStegHash);
        postMatch = (_postSteg == postStegHash);
        manifestoMatch = (_manifesto == manifestoHash);

        emit HashVerified(msg.sender, _preSteg, "pre_steg", preMatch);
        emit HashVerified(msg.sender, _postSteg, "post_steg", postMatch);
        emit HashVerified(msg.sender, _manifesto, "manifesto", manifestoMatch);

        return (preMatch, postMatch, manifestoMatch);
    }

    // ── Admin Functions ──

    /**
     * @dev Update stored hashes (owner only) - for corrections or upgrades
     * @param _preStegHash New pre-steganography hash
     * @param _postStegHash New post-steganography hash
     * @param _manifestoHash New manifesto hash
     */
    function updateHashes(
        bytes32 _preStegHash,
        bytes32 _postStegHash,
        bytes32 _manifestoHash
    ) external onlyOwner {
        preStegHash = _preStegHash;
        postStegHash = _postStegHash;
        manifestoHash = _manifestoHash;

        emit HashesUpdated(_preStegHash, _postStegHash, _manifestoHash);
    }

    /**
     * @dev Update contract metadata URI
     * @param newContractURI New contract metadata URI
     */
    function setContractURI(string memory newContractURI) external onlyOwner {
        _contractURI = newContractURI;
    }

    /**
     * @dev Update royalty recipient
     * @param newRecipient New royalty recipient address
     */
    function setRoyaltyRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient");
        royaltyRecipient = newRecipient;
    }

    // ── View Functions ──

    /**
     * @dev Get contract metadata URI
     */
    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    /**
     * @dev Get original contract reference
     */
    function getOriginalReference() external pure returns (address, uint256) {
        return (ORIGINAL_CONTRACT, ORIGINAL_CHAIN_ID);
    }

    /**
     * @dev Get all verification hashes
     */
    function getVerificationHashes()
        external
        view
        returns (bytes32, bytes32, bytes32)
    {
        return (preStegHash, postStegHash, manifestoHash);
    }

    /**
     * @dev Check if genesis token exists
     */
    function genesisExists() external view returns (bool) {
        return totalSupply(GENESIS_TOKEN_ID) > 0;
    }

    // ── EIP-2981 Royalties ──

    /**
     * @dev EIP-2981 royalty standard implementation
     * @param tokenId Token ID (ignored, same royalty for all)
     * @param salePrice Sale price
     * @return receiver Royalty recipient
     * @return royaltyAmount Royalty amount
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        // Silence unused parameter warning
        tokenId;

        receiver = royaltyRecipient;
        royaltyAmount = (salePrice * ROYALTY_BASIS_POINTS) / 10000;
    }

    // ── Interface Support ──

    /**
     * @dev ERC165 interface support
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    // ── Required Overrides ──

    /**
     * @dev Override required by ERC1155Supply and ERC1155URIStorage
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    /**
     * @dev Override required by ERC1155 and ERC1155URIStorage
     */
    function uri(uint256 tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(tokenId);
    }
}