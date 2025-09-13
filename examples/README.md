# Examples

This directory contains practical examples demonstrating how to use the Secure Smart Contracts Library.

## 📁 Files

### [`SecureReflectionToken.sol`](SecureReflectionToken.sol)
A complete implementation of an ERC-20 token with reflection rewards and security features.

**Features:**
- ✅ Full ERC-20 compatibility
- ✅ Reflection rewards with configurable fees
- ✅ Security lock integration (interface + full contract locks)
- ✅ Gas-optimized operations
- ✅ Comprehensive access controls
- ✅ Admin functions for fee and reflection management

**Usage:**
```solidity
// Deploy with security managers
SecureReflectionToken token = new SecureReflectionToken(
    lockManagerAddress,
    encryptionManagerAddress,
    "My Token",
    "MYTOKEN",
    ethers.utils.parseEther("1000000")
);

// Configure reflection fees
token.initializeReflection(
    200,  // 2% creator fee
    300,  // 3% reflection fee
    100,  // 1% liquidity fee
    100,  // 1% burn fee
    creatorAddress,
    liquidityPoolAddress
);
```

### [`deploy.js`](deploy.js)
Hardhat deployment script demonstrating proper deployment sequence and configuration.

**Features:**
- ✅ Step-by-step deployment process
- ✅ Security configuration guidance
- ✅ Error handling and validation
- ✅ Deployment summary and documentation
- ✅ Next steps guidance

**Usage:**
```bash
npx hardhat run examples/deploy.js --network mainnet
```

## 🚀 Quick Start

### 1. Basic Integration

The simplest way to add security features to your contract:

```solidity
import "../LockableContract.sol";

contract MyContract is LockableContract {
    constructor(address _lockManager, address _encryptionManager) 
        LockableContract(_lockManager, _encryptionManager) 
    {
        // Your initialization
    }
    
    function myFunction() external notLocked {
        // This function is automatically protected from locks
    }
}
```

### 2. Advanced Integration

For contracts needing internal operations during locks:

```solidity
function emergencyFunction() external allowInternal {
    // This function works even when interface is locked
    // but blocks when fully locked
}

function adminFunction() external allowInternal {
    require(msg.sender == owner, "Only owner");
    // Admin functions that bypass interface locks
}
```

### 3. Reflection Token Integration

For tokens with reflection rewards:

```solidity
using ReflectionRewards for ReflectionRewards._AccountData;
using ReflectionRewards for ReflectionRewards._FeeConfig;
using ReflectionRewards for ReflectionRewards._ReflectionState;

// In your transfer function
(uint256 netAmount, uint256 fees) = feeConfig.processTransaction(
    reflectionState,
    accounts,
    from,
    to,
    amount
);
```

## 🔐 Security Examples

### Lock Management

```solidity
// Lock contract interface only
lockManager.lockInterface(
    targetContract,
    dataId,
    secretData,
    recipientPubKeyX,
    recipientPubKeyY,
    ephemeralPrivKey
);

// Full contract lockdown
encryptionManager.lockContract(
    targetContract,
    dataId,
    secretData,
    recipientPubKeyX,
    recipientPubKeyY,
    ephemeralPrivKey
);

// Unlock with PIN
lockManager.unlockInterface(
    targetContract,
    dataId,
    recipientPrivKey,
    pin
);
```

### Owner Management

```solidity
// Set final immutable owner (one-time only)
encryptionManager.setOwner(finalOwnerContract, 123456);

// Setup backup wallet (within 12 hours)
encryptionManager.setBackupWallet(backupAddress);

// Update deployer owner (before final owner is set)
encryptionManager.updateOwner(newDeployerAddress);
```

## 🧪 Testing Examples

### Unit Tests

```javascript
describe("SecureReflectionToken", function() {
    it("Should prevent transfers when locked", async function() {
        await lockManager.lockInterface(token.address, dataId, data, pubKeyX, pubKeyY, ephemeralKey);
        
        await expect(
            token.transfer(user.address, amount)
        ).to.be.revertedWith("Contract interface is locked");
    });
    
    it("Should process reflection fees correctly", async function() {
        const balanceBefore = await token.balanceOf(user.address);
        await token.transfer(user.address, amount);
        const balanceAfter = await token.balanceOf(user.address);
        
        expect(balanceAfter.sub(balanceBefore)).to.be.closeTo(
            amount.mul(97).div(100), // 3% total fees
            ethers.utils.parseEther("0.01")
        );
    });
});
```

### Integration Tests

```javascript
describe("Integration Tests", function() {
    it("Should maintain functionality across lock/unlock cycle", async function() {
        // Normal operation
        await token.transfer(user.address, amount);
        
        // Lock interface
        await lockManager.lockInterface(token.address, dataId, data, pubKeyX, pubKeyY, ephemeralKey);
        
        // Should fail
        await expect(token.transfer(user2.address, amount)).to.be.reverted;
        
        // Unlock
        await lockManager.unlockInterface(token.address, dataId, privKey, pin);
        
        // Should work again
        await expect(token.transfer(user2.address, amount)).to.not.be.reverted;
    });
});
```

## 📊 Gas Usage Examples

| Operation | Gas Cost | Notes |
|-----------|----------|-------|
| Deploy SecureReflectionToken | ~2,500,000 | With reflection library |
| Transfer (no fees) | ~65,000 | Standard ERC-20 |
| Transfer (with reflection) | ~95,000 | Including fee processing |
| Lock Interface | ~55,000 | ECIES encryption + storage |
| Unlock Interface | ~50,000 | Decryption + PIN verification |
| Initialize Reflection | ~45,000 | One-time setup |

## 🔍 Common Patterns

### Error Handling

```solidity
// Descriptive error messages
require(amount > 0, "Transfer amount must be positive");
require(to != address(0), "Transfer to zero address");
require(balanceOf(from) >= amount, "Transfer amount exceeds balance");

// Access control
require(msg.sender == owner, "Only owner can perform this action");
require(!isContractLocked(address(this)), "Contract is locked");
```

### Event Emission

```solidity
// Standard events
emit Transfer(from, to, amount);
emit Approval(owner, spender, amount);

// Security events
emit ContractLocked(targetContract, dataId);
emit OwnerSet(newOwner);

// Reflection events
emit ReflectionDistributed(amount, recipients);
```

### Gas Optimization

```solidity
// Efficient data types
uint48 timestamp = uint48(block.timestamp);
uint16 feeBps = 300; // For values < 65536

// Batch operations
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
    require(recipients.length <= 100, "Batch too large");
    for (uint256 i = 0; i < recipients.length; i++) {
        _transfer(msg.sender, recipients[i], amounts[i]);
    }
}
```

## 🛠️ Development Tools

### Recommended Setup

```bash
# Install Hardhat
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers

# Install testing tools
npm install --save-dev @openzeppelin/test-helpers chai

# Install security tools
pip install slither-analyzer
npm install --save-dev @consensys/mythx-cli
```

### VS Code Extensions

- Solidity (Juan Blanco)
- Hardhat Solidity (Nomic Foundation)
- Ethereum Security Bundle

---

For more examples and patterns, see the main [README.md](../README.md) and [API Documentation](../API.md).