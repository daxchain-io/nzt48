# NZT-48 Deployments

The deployments below were migrated from the older `dax-yield` working tree.
They were created from the legacy source in
`deployments/legacy-source/src/NZT48.sol`, not from the current simplified
contract in `src/NZT48.sol`.

## Current Deployments

| Network | Chain ID | Address | Transaction |
| --- | ---: | --- | --- |
| Ethereum Mainnet | 1 | [`0x30a580e9fcbdec9784122963cc3762afba57f10d`](https://etherscan.io/address/0x30a580e9fcbdec9784122963cc3762afba57f10d) | [`0x27cd33fc364d8d2f12a58bb3378a45e50e475541ebfac0300306352176a3dbbb`](https://etherscan.io/tx/0x27cd33fc364d8d2f12a58bb3378a45e50e475541ebfac0300306352176a3dbbb) |
| Sepolia | 11155111 | [`0x30a580e9fcbdec9784122963cc3762afba57f10d`](https://sepolia.etherscan.io/address/0x30a580e9fcbdec9784122963cc3762afba57f10d) | [`0xc919ba8ca2307d90ce7f2e0a16cb72ebd617764dfc5ff4f20a766cbf2bde2923`](https://sepolia.etherscan.io/tx/0xc919ba8ca2307d90ce7f2e0a16cb72ebd617764dfc5ff4f20a766cbf2bde2923) |

Both current deployments use constructor/default-admin address
`0x2e4cac1195e3f1f500AFE85d09c13d78a8636f32`.

## Migrated Files

- `deployments/nzt48.json`: compact deployment index.
- `deployments/abi/NZT48.legacy.abi.json`: ABI for the deployed legacy contract.
- `deployments/foundry/NZT48.s.sol/`: successful Foundry broadcast receipts.
- `deployments/legacy-source/`: source and script used for the legacy deployments.

The older Sepolia deployment at
[`0xdaa8b1caa8a239d2582dfc425a92db0d3b3f743e`](https://sepolia.etherscan.io/address/0xdaa8b1caa8a239d2582dfc425a92db0d3b3f743e)
is retained in `deployments/nzt48.json` and the copied Foundry receipts as
historical context.
