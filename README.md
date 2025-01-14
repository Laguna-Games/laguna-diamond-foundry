# Laguna Labs Diamond Template
EIP-2535 Diamond implementation using Foundry.

![Visibility: OPEN SOURCE](https://img.shields.io/badge/visibility-OPEN_SOURCE-green)


Developed by [Laguna Labs](https://lagunalabs.co) for [Neo Olympus](https://lagunalabs.co/neoolympus).

Adapted from the Diamond 3 reference implementation by Nick Mudge:
[https://github.com/mudgen/diamond-3-hardhat](https://github.com/mudgen/diamond-3-hardhat)

---

## Setup (Build on this project)

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
2. Initialize a new project: `forge init`
3. Install project dependencies: `forge install`
    1. If lib/forge-std is empty: `forge install foundry-rs/forge-std`
4. Install laguna-diamond-factory: `forge install Laguna-Games/laguna-diamond-foundry`

---

## Setup (Source development)

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
2. Install project dependencies: `forge install`
   1. If lib/forge-std is empty: `forge install foundry-rs/forge-std`
3. Make a copy of [dotenv.example](dotenv.example) and rename it to `.env`
   1. Edit [.env](.env)
   2. Import or generate a wallet to Foundry (see `cast wallet --help`)
      - Fill in `DEPLOYER_ADDRESS` for a deployer wallet address you will use, and validate it with the `--account <account_name>` option in commands
   3. Fill in any API keys for Etherscan, Polygonscan, Arbiscan, etc.
4. Load environment variables: `source .env`
5. Compile and test the project: `forge test`

---

## Update
Pull latest library dependencies.
```shell
$ git submodule update --recursive
```

---

## Build
Compile the smart contracts.

```shell
$ forge build --force
```

---

## Test
Run unit tests with forking.
```shell
$ forge test
```

---

## Deploy a new diamond

Optionally, declare any pre-deployed facet contracts to use. If not set, a new facet will be deployed. The addresses below are deployed for anyone to use on Ethereum mainnet: 
```shell
export DIAMOND_CUT_FACET=0xa91394bbaB32Fe452B020C34f93601B7B3E46988
export DIAMOND_LOUPE_FACET=0x13B6D97803B63DfA5664F1dEB43b2cf45041B3EF
export DIAMOND_OWNER_FACET=0xec665862F187eCf59589eF5f46745A77383a273E
export DIAMOND_PROXY_FACET=0x2784b41Af0a74AF4ECd60c062834a865D88Fb034
export SUPPORTS_INTERFACE_FACET=0xB86Dd140C15c5DF7D4Dc9429d5E0a5fF7d537C6C
export CUT_DIAMOND_IMPLEMENTATION=0x20a8098a05306A1744999116e97626E5AEaa61e0
```


```shell
export RPC_API="<http endpoint>"
export EXPLORER_API="<blockscout endpoint>"

forge script --broadcast --rpc-url "$RPC_API" --account "owner" --verify --verifier blockscout --verifier-url "$EXPLORER_API" script/Deploy.s.sol
```
