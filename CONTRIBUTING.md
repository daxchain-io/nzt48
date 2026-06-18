# Contributing

NZT-48 is a small experimental coin repo. It is public so people can inspect
the contract, deployment records, tests, and behavior, but it is not intended
to be a general-purpose community project.

## Contribution Policy

Contributions are maintainer-directed. Unsolicited pull requests may be closed
without review, especially if they change contract behavior, deployment records,
token framing, project metadata, or repository automation.

Before opening a pull request, coordinate with a maintainer. A good contribution
should be small, easy to review, and directly related to one of these areas:

- clearer documentation of the coin's behavior
- tests that pin the existing weird ERC20 semantics
- local development workflow improvements for Anvil or Foundry
- corrections to deployment metadata

## Pull Requests

Pull requests should:

- pass `forge fmt --check`
- pass `forge build`
- pass `forge test -vvv`
- avoid changing canonical deployment addresses or historical broadcast records
- avoid adding private keys, RPC secrets, API keys, mnemonics, or wallet material

The live Mainnet and Sepolia deployments are already canonical. New deployments
are not expected, except for local Anvil experiments or explicitly approved test
work.

## Maintainer Workflow

Maintainers may push directly to `main` for small trusted changes. Larger or
riskier changes should use a pull request so CI and review history stay visible.
