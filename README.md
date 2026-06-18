# NZT-48

> Another ERC20 from the boys in the kitchen.

NZT-48 is an experimental token contract with a deliberately strange balance
rule: an account with no materialized token balance reads as holding a default
amount.

The default amount starts at `5,000 * 10 ** decimals()`. When a transfer touches
an account with no materialized balance, the contract mints the default amount
to that account before applying the transfer. The default can be changed by an
account with `TOKEN_MANAGER`.

This repository is private while the contract is being separated from the older
`dax-yield` working tree.

## Build

```sh
forge build
```

## Test

```sh
forge test
```

## Deploy

Set `DEFAULT_ADMIN` to the account that should receive the admin, burner,
minter, pauser, and token-manager roles.

```sh
DEFAULT_ADMIN=0x... forge script script/NZT48.s.sol:DeployNZT48 \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast
```
