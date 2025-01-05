# Laguna Labs Diamond Template
EIP-2535 Diamond implementation using Foundry.

Developed by [Laguna Labs](https://lagunalabs.co) for [Neo Olympus]().

Adapted from the Diamond 3 reference implementation by Nick Mudge:
[https://github.com/mudgen/diamond-3-hardhat](https://github.com/mudgen/diamond-3-hardhat)

---

## Setup

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
```
$ git submodule update --recursive
```

---

## Build
Compile the smart contracts.

```shell
$ forge build
```

---

## Test
Run unit tests with forking.
```shell
$ forge test
```

---

## Deploy a new diamond

Optionally, declare any pre-deployed facet contracts to use. If not set, a new facet will be deployed.
```
export DIAMOND_CUT_FACET="<DiamondCutFacet address>"
export DIAMOND_LOUPE_FACET="<DiamondLoupeFacet address>"
export DIAMOND_OWNER_FACET="<DiamondOwnerFacet address>"
export DIAMOND_PROXY_FACET="<DiamondProxyFacet address>"
export SUPPORTS_INTERFACE_FACET="<SupportsInterfaceFacet address>"
export CUT_DIAMOND_IMPLEMENTATION=<CutDiamond implementation address>
```


```
export RPC_API="<http endpoint>"
export EXPLORER_API="<blockscout endpoint>"

forge script --broadcast --rpc-url "$RPC_API" --account "owner" --verify --verifier blockscout --verifier-url "$EXPLORER_API" script/Deploy.s.sol
```
