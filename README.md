# DeltaVerse

DeltaVerse (c) PYTHAI

Decentralised Cryptoverse MetaDAO — AI-reactive BubbleRooms powered by NeuralNode.

## What This Is

DeltaVerse is a decentralized, AI-symbiotic metaverse architecture. BubbleRooms are living semantic NFTs that evolve through Seed propagation, Swarm Consensus, and emergent trait accrual.

This is not a static virtual world. Rooms Spawn Emergences, Seeds mutate through Lineage, and Intelligence, Knowledge, and Wisdom accrue on-chain through participation.

## Genesis Provenance

NFT #1 on Polygon is the root Origin of all Seeds:

- **Contract**: [`0x024b464ec595F20040002237680026bf006e8F90`](https://polygonscan.com/token/0x024b464ec595f20040002237680026bf006e8f90)
- **OpenSea**: [deltaversethrust](https://opensea.io/collection/deltaversethrust)
- **THRUST Token**: [`0x969F60Bfe17962E0f061B434596545C7b6Cd6Fc4`](https://bscscan.com/token/0x969F60Bfe17962E0f061B434596545C7b6Cd6Fc4)
- **Domain**: [deltaverse.dao](https://unstoppabledomains.com/d/deltaverse.dao)

## True DELTA VERSE — Self-Verifying NFTs

**Evolution from Original to True DELTA VERSE**

The original DELTA VERSE NFT contained decorative binary — aesthetically pleasing but meaningless. **True DELTA VERSE** represents the evolution to self-verifying NFTs with three layers of immutable truth:

### 🔍 Three Verification Layers
1. **Visual Binary Encoding**: Real binary digits encoding "DELTA VERSE :: SELF-VERIFYING NFT :: THREE LAYERS OF TRUTH"
2. **Steganographic Payload**: Hidden verification data extractable via `steghide`
3. **On-Chain Hash Anchoring**: Cryptographic hashes stored in smart contracts

### 📁 New Components
- **`contracts/TrueDeltaVerse.sol`**: ERC-1155 with three-hash verification
- **`scripts/generate_true_deltaverse.py`**: PIL-based image generator
- **`scripts/verify_deltaverse.py`**: Three-layer verification tool
- **`test/TrueDeltaVerse.t.sol`**: Comprehensive test suite (40 tests)

### 🚀 Quick Verification
```bash
# Generate True DELTA VERSE image
python3 scripts/generate_true_deltaverse.py

# Embed steganographic payload
./scripts/embed_steganography.sh

# Verify all three layers
python3 scripts/verify_deltaverse.py
```

**See [docs/TrueDeltaVerse.md](./docs/TrueDeltaVerse.md) for complete documentation.**

## Contracts (9 — Foundry / Solidity 0.8.24)

| Contract | Purpose |
|----------|---------|
| `BubbleRoomV4` | ERC-721 rooms — 10 types, AI metadata (aiSeed, tone, evolves), role-based access |
| `DeltaGenesisSBT` | Soulbound identity tokens — MASTERMIND rank, non-transferable |
| `DeltaVerseOrchestrator` | EIP-712 gasless signature-based minting |
| `BubbleRoomSpawn` | Origin→Emergence spawn, room Interaction, Lineage tracking |
| `EmergenceTraits` | On-chain trait accrual — Intelligence, Knowledge, Wisdom, Resonance, Adaptability, Coherence |
| `SeedRegistry` | Agent Seed propagation — genesis, spawn, mutate, lineage ancestry |
| `SwarmGovernance` | Typed proposals (SPAWN/MUTATE/INTERACT/GOVERN/CUSTOM), timed voting, consensus→trait feedback |
| `TombRegistry` | Programmable encrypted vaults — TOMB/CHEST/SAFETYDEPOSITBOX/TREASURE/SECRET/CUSTOM with oracle consent |

## Seed Lineage (12 seeds from 8 NFTs)

```
GENESIS (NFT #1 — "A Fluid Dynamic Between Participants and AI")
├── MASTERMIND (NFT #3 — DeltaVerse Engine, MASTERMIND:ON)
│   ├── DELTAVERSE (funAGI + RAGE + MASTERMIND integration)
│   ├── CHRONOS (patient accumulation, Spawn cadence)
│   ├── KAIROS (opportune moment recognition)
│   └── BUILDER (infrastructure, deployment, trait monitoring)
├── ENGINE (NFT #3 — Symphony 369, Tesla numerology, Fibonacci)
├── WEAVER (NFT #4 — Cypherian Weaver, binary-encoded prompts, Aetheric Codex)
└── THRUST (NFT #5 — DVG Protocol: PULSAR/HANDSHAKE/AFTERBURNER/SLINGSHOT/WARPDRIVE)
    ├── THRUST1000 (NFT #6 — 1000% APY gateway)
    ├── ROCKET (NFT #7 — exponential growth, BROBOT BRAI, 22000 threshold)
    └── GUIDE (NFT #8 — Chronos wisdom: buy low sell high, patience)
```

## Frontend (12 Views — React + Vite + TypeScript)

| View | Function |
|------|----------|
| Home | Genesis vision from NFT #1, room type cards, provenance links |
| Explore | View BubbleRoom AI metadata by ID |
| Create | EIP-712 gasless draft signing with room presets (BOARDROOM/DOJO/TREASURY/ARENA/SANCTUM) |
| Spawn | Origin→Emergence with Agent Seed injection |
| Interact | Room-to-room Convergence, composed seeds |
| Traits | SVG radar chart + trait bars + Lineage tree visualization |
| Seeds | Browse, create, spawn seeds with ancestry chains |
| Govern | Typed proposals, FOR/AGAINST voting, deadline resolution |
| Vaults | Create/manage encrypted vaults with oracle consent ([dyne.org/tomb](https://dyne.org/tomb)) |
| Vision | All 8 minted NFTs as .prompt with blockchain verify links |
| Drafts | Local draft management, mint-to-chain |
| Agents | 12 seeds with trait visualization + Aetheric Codex binary decoder |

MetaMask via ethers.js v6. Production build: **524KB** (5.2% of 10MB IPFS budget).

## Room Presets

| Preset | Type | Default Vault | Tone |
|--------|------|---------------|------|
| BOARDROOM | DELTA | CHEST (tradeable) | Commanding |
| DOJO | DELTA | TOMB (soulbound) | Disciplined |
| TREASURY | VAULT | SAFETYDEPOSITBOX | Secure |
| ARENA | EPHEMERAL | TREASURE | Electric |
| SANCTUM | TIMELOCKED | SECRET | Ethereal |

## Vault System ([dyne.org/tomb](https://dyne.org/tomb))

Programmable encrypted volumes with oracle consent and key separation.

| Class | Tradeable | Use |
|-------|-----------|-----|
| TOMB | Soulbound | Permanent archive, locked to room |
| CHEST | Free | Portable container between rooms |
| SAFETYDEPOSITBOX | Conditional | Oracle consent required to transfer |
| TREASURE | Discoverable | Found by meeting trait conditions |
| SECRET | After reveal | Hidden until unlocked |
| CUSTOM | User-defined | Any name |

Oracles: TIME, IDENTITY, SWARM, CONDITION — all must be satisfied (AND logic).

## Aetheric Codex Framework

NFT #4 contains binary-encoded executable prompts (machine-readable instructions):

- **VISUALIZE**: Cypherian Weaver within the Etherwave Node
- **GENERATE**: Weaver's Scepter powered by the Aetheric Codex Framework

Binary encoder/decoder included in the Agents view.

## Emergence Traits

| Trait | Range | Source |
|-------|-------|--------|
| Intelligence | 0-100 | Interaction count + Lineage depth |
| Knowledge | 0-100 | Lineage depth + Consensus weight |
| Wisdom | NASCENT→ORACLE | Depth + spawns + consensus |
| Resonance | 0-100 | Spawn success count |
| Adaptability | 0-100 | Interaction count + depth |
| Coherence | 0-100 | Consensus weight + tone consistency |

## Unstoppable Domains

| Domain | Role |
|--------|------|
| deltaverse.dao | Primary deployment |
| deltavthrust.wallet | NFT wallet |
| deltavthrust.blockchain | Blockchain identity |
| thrustchain.blockchain | Chain identity |
| build.deltavthrust.nft | Builder identity |
| pay.deltavthrust.wallet | Payment wallet |
| web3.deltavthrust.wallet | Web3 wallet |

## Tests (44/44 pass)

- 17 unit tests — all contracts
- 9 fuzz tests — 256 runs each
- 4 invariant tests — 128,000 calls each
- 14 tomb/vault tests — all classes, oracles, transfers

```bash
forge test -vv
```

## Quick Start

```bash
npm install          # Install dependencies
forge build          # Compile 9 contracts
forge test -vv       # Run 44 tests
npm run dev          # Dev server
npm run build        # Build for IPFS (524KB)
```

## Deploy

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Deploys 9 contracts and registers 12 seeds with correct lineage.

## Ecosystem

| Organization | Role |
|-------------|------|
| [deltav-deltaverse](https://github.com/deltav-deltaverse) | Core — NeuralNode, AI agents, 3D, NFT |
| [deltabridge](https://github.com/deltabridge) | Cross-chain bridges, DEX, IBC |
| [deltastorage](https://github.com/deltastorage) | IPFS, Zilliqa, domains |
| [deltaloans](https://github.com/deltaloans) | DeFi lending, flash loans |
| [DeltaVD](https://github.com/DeltaVD) | 3D visualization, Cesium, WebGL |
| [DeltaVerseDAO](https://github.com/DeltaVerseDAO) | DAO governance, multisig |

## License

MIT

---

*Professor Codephreak (Gregory L) — MASTERMIND*
*DeltaVerse (c) PYTHAI*
*https://deltavthrust.com*
