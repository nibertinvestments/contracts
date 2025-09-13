# Secure Smart Contracts Library

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.30-blue.svg)](https://solidity.readthedocs.io/)

A comprehensive collection of security-focused Solidity smart contracts implementing advanced encryption, access control, and token reflection reward systems. These contracts provide enterprise-grade security features with gas-optimized implementations for decentralized applications.

## 🏗️ Architecture Overview

This repository contains five core components that work together to provide a complete secure contract ecosystem:

### Core Components

| Contract | Purpose | Key Features |
|----------|---------|--------------|
| **EncryptionA.sol** | Gas-efficient encryption library | ECIES with secp256k1, XOR-based symmetric encryption, 24-hour decryption windows |
| **EncryptionManager.sol** | Central encryption management | Dual-owner pattern, PIN protection, backup wallet systems |
| **WorkingLockManager.sol** | Interface locking system | Granular access controls, emergency lockdown capabilities |
| **LockableContract.sol** | Base lockable functionality | Modular locking integration, internal operation permissions |
| **ReflectionLibrary.sol** | Token reflection rewards | Configurable fee structures, batch operations, gas-optimized calculations |

### Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layer Stack                     │
├─────────────────────────────────────────────────────────────┤
│  Application Layer    │  Your DApp / Token Contract        │
├─────────────────────────────────────────────────────────────┤
│  Access Control       │  LockableContract + Modifiers      │ 
├─────────────────────────────────────────────────────────────┤
│  Lock Management      │  WorkingLockManager                 │
├─────────────────────────────────────────────────────────────┤
│  Encryption Layer     │  EncryptionManager                  │
├─────────────────────────────────────────────────────────────┤
│  Cryptographic Core   │  EncryptionA Library                │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security Features

### Advanced Owner Management
- **Dual-Owner Pattern**: Mutable deployer owner + immutable final owner
- **Two-Phase Ownership Transfer**: Prevents accidental ownership loss
- **Backup Wallet System**: 12-hour emergency recovery window
- **PIN Protection**: 6-digit PIN verification with secure hash storage

### Cryptographic Protection
- **ECIES Encryption**: Elliptic Curve Integrated Encryption Scheme with secp256k1
- **MAC Verification**: Message Authentication Codes prevent data tampering
- **Time-Locked Decryption**: 24-hour decryption windows for enhanced security
- **Ephemeral Key Generation**: Fresh keys for each encryption operation

### Granular Access Controls
- **Interface Locking**: Selective function disabling without full contract shutdown
- **Emergency Lockdown**: Complete contract freezing capabilities
- **Internal Operations**: Bypass locks for authorized internal contract calls
- **Time-Based Security**: Deployment timestamp validation and time windows

## 🚀 Getting Started

### Prerequisites

- Solidity compiler 0.8.30 or compatible
- Ethereum development environment (Hardhat, Foundry, or Truffle)
- Node.js 16+ (for most development tools)

### Basic Integration

#### 1. Inherit from LockableContract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./LockableContract.sol";

contract MySecureToken is LockableContract {
    constructor(
        address _workingLockManager,
        address _encryptionManager
    ) LockableContract(_workingLockManager, _encryptionManager) {
        // Your token initialization
    }
    
    function transfer(address to, uint256 amount) 
        public 
        notLocked 
        returns (bool) 
    {
        // Your transfer logic with automatic lock protection
    }
}
```

#### 2. Deploy Supporting Infrastructure

```solidity
// Deploy in order:
// 1. EncryptionManager
EncryptionManager encryptionManager = new EncryptionManager();

// 2. WorkingLockManager  
WorkingLockManager lockManager = new WorkingLockManager(address(encryptionManager));

// 3. Your contract with lock protection
MySecureToken token = new MySecureToken(address(lockManager), address(encryptionManager));
```

#### 3. Configure Security Settings

```solidity
// Set final owner (must be a contract)
encryptionManager.setOwner(finalOwnerContract, 123456); // 6-digit PIN

// Setup backup wallet (12-hour window after owner is set)
encryptionManager.setBackupWallet(backupWalletAddress);
```

## 💰 Token Reflection Integration

For tokens implementing reflection rewards, integrate the ReflectionLibrary:

```solidity
import "./ReflectionLibrary.sol";

contract MyReflectionToken {
    using ReflectionRewards for ReflectionRewards._AccountData;
    using ReflectionRewards for ReflectionRewards._FeeConfig;
    using ReflectionRewards for ReflectionRewards._ReflectionState;
    
    ReflectionRewards._FeeConfig private feeConfig;
    ReflectionRewards._ReflectionState private reflectionState;
    mapping(address => ReflectionRewards._AccountData) private accounts;
    
    function initializeReflection(
        uint256 creatorFeeBps,      // e.g., 200 = 2%
        uint256 reflectionFeeBps,   // e.g., 300 = 3%  
        uint256 liquidityFeeBps,    // e.g., 100 = 1%
        uint256 burnFeeBps,         // e.g., 100 = 1%
        address creatorAddress,
        address liquidityPool
    ) external onlyOwner {
        feeConfig.initializeFees(
            creatorFeeBps,
            reflectionFeeBps, 
            liquidityFeeBps,
            burnFeeBps,
            creatorAddress,
            liquidityPool
        );
    }
}
```

## 📖 Detailed Documentation

### Contract APIs

#### EncryptionA Library
- `encrypt()`: Encrypt data with ECIES and store with timestamp
- `decrypt()`: Decrypt data within 24-hour window with PIN verification
- `_ecmul()`: Elliptic curve point multiplication for key operations

#### EncryptionManager Contract  
- `setOwner()`: Set immutable final owner with PIN protection
- `setBackupWallet()`: Configure emergency backup wallet
- `lockContract()`: Encrypt and lock target contract
- `unlockContract()`: Decrypt and unlock target contract

#### WorkingLockManager Contract
- `lockInterface()`: Lock contract interface functions
- `unlockInterface()`: Unlock contract interface functions  
- `triggerFullLockdown()`: Emergency full contract lockdown

#### LockableContract Base
- `notLocked` modifier: Prevents function execution when locked
- `allowInternal` modifier: Allows internal calls when interface-locked

#### ReflectionLibrary
- Fee configuration and validation
- Reflection calculation and distribution
- Batch operations for gas efficiency
- Exclusion management for special accounts

## 🛣️ Development Roadmap

### Current Status: Foundation Complete ✅
- [x] Core encryption and access control architecture
- [x] Gas-optimized cryptographic operations
- [x] Comprehensive security features
- [x] Token reflection reward system
- [x] Modular contract design

### Near Term (Q2 2024)
- [ ] **Testing Infrastructure**: Comprehensive unit and integration tests
- [ ] **Formal Verification**: Mathematical proofs of security properties
- [ ] **Gas Optimization**: Further reduce transaction costs
- [ ] **Documentation**: Complete API documentation and tutorials

### Medium Term (Q3-Q4 2024)  
- [ ] **Security Audit**: Professional third-party security review
- [ ] **Governance Integration**: DAO compatibility and voting mechanisms
- [ ] **Multi-Chain Support**: Cross-chain encryption and lock management
- [ ] **Developer Tools**: SDK and integration libraries

### Long Term (2025+)
- [ ] **Advanced Cryptography**: Post-quantum encryption research
- [ ] **Ecosystem Growth**: Partner integrations and use cases
- [ ] **Protocol Optimization**: Ethereum L2 and scaling solutions
- [ ] **Enterprise Features**: Advanced compliance and reporting tools

## ⚠️ Security Considerations

### Important Notes
- **Block Timestamp Dependency**: Time-based functions use `block.timestamp` which may vary due to block time fluctuations
- **Owner Centralization**: Single owner has significant control - ensure proper owner transition procedures  
- **PIN Security**: 6-digit PINs provide limited entropy - suitable only as additional verification layer
- **Contract Upgrades**: No upgrade mechanisms - deploy new versions for updates
- **Gas Limits**: Batch operations include size limits to prevent gas exhaustion

### Best Practices
1. **Always test on testnets** before mainnet deployment
2. **Use time windows carefully** - account for block time variations
3. **Secure owner private keys** with hardware wallets or multi-sig
4. **Plan backup wallet access** within deployment time windows
5. **Monitor gas costs** for complex cryptographic operations

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:
- Code style and standards
- Testing requirements  
- Security review process
- Documentation standards

### Development Setup

1. Clone the repository
```bash
git clone https://github.com/nibertinvestments/contracts.git
cd contracts
```

2. Install development dependencies (when using Hardhat/Foundry)
```bash
npm install  # or yarn install
```

3. Compile contracts
```bash
npx hardhat compile  # or forge build
```

4. Run tests
```bash
npx hardhat test  # or forge test
```

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔍 Security Audits

Currently seeking professional security audits. If you're a security researcher or auditing firm interested in reviewing these contracts, please contact us.

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/nibertinvestments/contracts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nibertinvestments/contracts/discussions)
- **Security**: Please report security vulnerabilities privately

---

*Built with ❤️ for the decentralized future. Secure by design, optimized for gas efficiency.*
