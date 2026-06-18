# NZT-48

> Another ERC20 from the boys in the kitchen.

NZT-48 is an experimental ERC20 for playing with a strange idea: everybody
already has some.

Most ERC20s start at zero and wait for someone to send you tokens. NZT-48 does
the opposite. If an ordinary address has no materialized balance, `balanceOf`
reports the default balance anyway. The default starts at `5,000 NZT-48`.

That makes it a toy coin, a little on-chain oddity, and a good thing to poke at
when you want to see what assumptions wallets, indexers, contracts, and people
make about balances.

## Live Coin

NZT-48 has already been deployed on Ethereum Mainnet and Sepolia. These are the
canonical deployments.

| Network | Contract |
| --- | --- |
| Ethereum Mainnet | [`0x30a580e9fcbdec9784122963cc3762afba57f10d`](https://etherscan.io/address/0x30a580e9fcbdec9784122963cc3762afba57f10d) |
| Sepolia | [`0x30a580e9fcbdec9784122963cc3762afba57f10d`](https://sepolia.etherscan.io/address/0x30a580e9fcbdec9784122963cc3762afba57f10d) |

The deployment receipts, ABI, explorer links, and legacy deployed source live in
[`deployments/`](deployments/README.md). The live deployments were created from
that legacy source; the source in `src/` is the cleaned-up standalone version
for this repo and local experiments.

No additional canonical deployments are planned. The deploy script remains here
so the coin can still be launched into Anvil or another throwaway network for
testing.

## What Happens

Fresh accounts look funded:

```text
balanceOf(alice) -> 5,000 NZT-48
totalSupply()    -> 0 NZT-48
```

That is the central trick. Alice appears to have tokens even though no real
balance has been written for Alice yet.

When Alice transfers to Bob, the contract materializes the default for each
untouched side before applying the transfer:

```text
alice transfers 100 NZT-48 to bob

alice: 5,000 materialized, then sends 100 -> 4,900
bob:   5,000 materialized, then receives 100 -> 5,100
supply: 10,000 materialized
```

If Bob was already materialized, Bob does not get another default bump. If Alice
later drains her materialized balance to exactly zero, she looks fresh again:

```text
alice balance becomes 0
balanceOf(alice) -> 5,000 NZT-48
```

That is intentional. NZT-48 is play money. You can run out, and then the coin
still says: nice try, have some more.

## Weird Edges

- A zero-value transfer can still wake up untouched accounts.
- A self-transfer from a fresh account materializes that account once.
- `totalSupply()` only counts materialized balances, not every address's virtual
  default.
- The zero address is boring: `balanceOf(address(0))` returns `0`.
- Contracts that assume `balanceOf(account) == 0` means "this account has never
  had tokens" will learn something about themselves.

## Try It

Read the live contract:

```sh
cast call 0x30a580e9fcbdec9784122963cc3762afba57f10d \
  "balanceOf(address)(uint256)" \
  0x0000000000000000000000000000000000000001 \
  --rpc-url "$MAINNET_RPC_URL"
```

Run the walkthrough tests:

```sh
forge test -vvv
```

Play locally with Anvil:

```sh
anvil
```

In another terminal:

```sh
OWNER=0x... forge script script/NZT48.s.sol:DeployNZT48 \
  --rpc-url http://127.0.0.1:8545 \
  --private-key "$ANVIL_PRIVATE_KEY" \
  --broadcast
```

For local experiments, use one of Anvil's funded development keys. Do not use a
mainnet key for local play.

## License And Contributions

The active standalone source in this repo is MIT licensed. Contribution policy
is intentionally narrow: this is a public artifact for an experimental coin, not
a broad community roadmap. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and
[`SECURITY.md`](SECURITY.md).
