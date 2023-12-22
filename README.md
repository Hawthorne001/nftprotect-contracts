<img src="https://github.com/NFT-Protect/.github/raw/main/profile/git-avatar.png" width="96">

# NFT Protect Contracts

[![CodeFactor](https://www.codefactor.io/repository/github/nftprotect/nftprotect-contracts/badge)](https://www.codefactor.io/repository/github/nftprotect/nftprotect-contracts)

This repository contains the smart contracts for NFT Protect. The system consists of several contracts responsible for various functions, including arbitration, user identity management, coupon generation and redemption, and NFT protection.

## Deployment

Contracts are deployed using the deploy.ts script. This script checks if a contract has already been deployed on the network, and if not, deploys it.
```shell
yarn build
yarn deploy --network sepolia
```

## Verification

After deployment, contracts can be verified using the verify.ts script. This script reads the contract data from contracts.json and verifies each contract on the network.
```shell
yarn verify --network sepolia
```

## Configuration

To configure contracts automatically after deployment, run the following:
```shell
yarn configure --network sepolia
```
This script performs smart contracts configuration based on contracts.json and arbitrators.json.

## ABI exporting
To export ABI run this command:
```shell
yarn export-abi
```

## Contracts
### Sepolia
- [UserDIDDummyAllowAll](https://sepolia.etherscan.io/address/0xc29da1a7998414374c05664fedc90ecbefbe5b2d)
- [ArbitratorRegistry](https://sepolia.etherscan.io/address/0x423f42f53f67356e7bc9093410303c68c8478fe7)
- [NFTProtect](https://sepolia.etherscan.io/address/0x9e652f34a8063de3627574da29c7e9baf5bb8a7d)
- [UserRegistry](https://sepolia.etherscan.io/address/0xc3dc0e74c92043a2712ce22f385f7b3d390bb695)
- [NFTPCoupons](https://sepolia.etherscan.io/address/0x142724c5bFcd293C9eFcD27Ee306Bb3Cc8bF15CD)
- [MultipleProtectHelper](https://sepolia.etherscan.io/address/0xb8debb6f543e502d7d2ddccadfee00cb86629447)

### Goerli
- [UserDIDDummyAllowAll](https://goerli.etherscan.io/address/0x53FeB2b6C816a88aB192a94113d03c5E17EB1fF2)
- [ArbitratorRegistry](https://goerli.etherscan.io/address/0x094c049f25d6ea178b3262887d37ad9da36b2355)
- [NFTProtect](https://goerli.etherscan.io/address/0x8732b75a23fefab3be8825ae87dffcb38760121f)
- [UserRegistry](https://goerli.etherscan.io/address/0x68deab39fb68a7c24d67d16b1f133809c41c008f)
- [NFTPCoupons](https://goerli.etherscan.io/address/0x6a204dDA156dafA6198A51241B21340627747402)
- [MultipleProtectHelper](https://goerli.etherscan.io/address/0xa84bc45959156e937590098c00334c632e8fe398)

## License

This project is licensed under the GNU GPL v2.1 license.
