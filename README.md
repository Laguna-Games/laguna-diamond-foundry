# Laguna Labs Diamond Template
EIP-2535 Diamond implementation using Foundry.

Developed by [Laguna Labs](https://lagunalabs.co) for [Neo Olympus]().

Adapted from the Diamond 3 reference implementation by Nick Mudge:
[https://github.com/mudgen/diamond-3-hardhat](https://github.com/mudgen/diamond-3-hardhat)

---

## Setup

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
2. Install project dependencies: `forge install`
3. Make a copy of [dotenv.example](dotenv.example) and rename it to `.env`
   1. Edit [.env](.env)
   2. Import or generate a wallet to Foundry (see `cast wallet --help`)
      - Fill in `DEPLOYER_ADDRESS` for a deployer wallet address you will use, and validate it with the `--account <account_name>` option in commands
   3. Fill in any API keys for Etherscan, Polygonscan, Arbiscan, etc.
4. Compile and test the project: `forge test`

---

## Build
Compile the smart contracts.

```shell
$ forge build
```


## Test
Run unit tests with forking.
```shell
$ forge test
```
