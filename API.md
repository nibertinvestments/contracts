# API Documentation

This document provides comprehensive API documentation for all contracts in the Secure Smart Contracts Library.

## 📋 Table of Contents

- [EncryptionA Library](#encryptiona-library)
- [EncryptionManager Contract](#encryptionmanager-contract)
- [WorkingLockManager Contract](#workinglockmanager-contract)
- [LockableContract Base](#lockablecontract-base)
- [ReflectionLibrary](#reflectionlibrary)
- [Interface Definitions](#interface-definitions)

## 🔐 EncryptionA Library

Gas-efficient encryption library using ECIES with secp256k1 and XOR-based symmetric encryption.

### Data Structures

#### Ciphertext
```solidity
struct Ciphertext {
    bytes32 ephemeralPubKeyX;  // X coordinate of ephemeral public key
    bytes32 ephemeralPubKeyY;  // Y coordinate of ephemeral public key  
    bytes32 ciphertext;        // XOR-encrypted data
    bytes32 mac;               // Message authentication code
    uint256 timestamp;         // Encryption timestamp
}
```

### Functions

#### encrypt()
```solidity
function encrypt(
    bytes32 _data,
    bytes32 _recipientPubKeyX,
    bytes32 _recipientPubKeyY, 
    bytes32 _ephemeralPrivKey
) internal returns (Ciphertext memory)
```

**Description**: Encrypts data using ECIES with the recipient's public key.

**Parameters**:
- `_data`: The 32-byte data to encrypt
- `_recipientPubKeyX`: X coordinate of recipient's public key
- `_recipientPubKeyY`: Y coordinate of recipient's public key
- `_ephemeralPrivKey`: Private key for ephemeral key generation

**Returns**: `Ciphertext` struct containing encrypted data and metadata

**Events**: `EncryptionPerformed(address indexed sender, bytes32 indexed recipientPubKeyX, bytes32 ciphertext)`

**Requirements**:
- Recipient public key coordinates must not be zero
- Ephemeral private key must be valid

---

#### decrypt()
```solidity
function decrypt(
    Ciphertext memory _ciphertext,
    bytes32 _recipientPrivKey,
    uint256 _pin,
    bytes32 _pinHash,
    address _owner,
    address _backupWallet
) internal returns (bytes32)
```

**Description**: Decrypts data within 24-hour window with PIN verification and access control.

**Parameters**:
- `_ciphertext`: The ciphertext struct to decrypt
- `_recipientPrivKey`: Private key corresponding to encryption public key
- `_pin`: 6-digit PIN for verification
- `_pinHash`: Hash of the correct PIN for verification
- `_owner`: Contract owner address
- `_backupWallet`: Backup wallet address

**Returns**: Decrypted 32-byte data

**Events**: `DecryptionPerformed(address indexed caller, bytes32 indexed recipientPubKeyX, bytes32 plaintext)`

**Requirements**:
- Caller must be owner or backup wallet
- Must be within 24-hour decryption window
- PIN must be 6 digits or less (≤ 999999)
- PIN hash must match provided hash
- MAC must be valid (prevents data tampering)

---

### Internal Functions

#### _ecmul()
```solidity
function _ecmul(bytes32 _scalar) internal view returns (bytes32 x, bytes32 y)
function _ecmul(bytes32 _pointX, bytes32 _pointY, bytes32 _scalar) internal view returns (bytes32 x, bytes32 y)
```

**Description**: Elliptic curve point multiplication using secp256k1 curve.

**Gas Cost**: ~3000 gas per operation

---

## 🔒 EncryptionManager Contract

Central contract for managing encryption/decryption operations with dual-owner pattern.

### State Variables

```solidity
address public owner;                    // Mutable deployer owner
address public newOwner;                 // Final owner (immutable once set)
address public backupWallet;            // Backup wallet for emergency access
bytes32 private pinHash;                 // Hash of 6-digit PIN
uint256 public immutable deploymentTimestamp;  // Contract deployment time
bool private newOwnerSet;                // Prevents owner changes after finalization
mapping(bytes32 => EncryptionA.Ciphertext) private encryptedData;  // Encrypted data storage
mapping(address => bool) public isContractLocked;  // Contract lock status
```

### Functions

#### Constructor
```solidity
constructor()
```

**Description**: Initializes contract with deployer as initial owner and records deployment timestamp.

---

#### setOwner()
```solidity
function setOwner(address _newOwner, uint256 _pin) external
```

**Description**: Sets the final immutable owner with PIN protection. Can only be called once.

**Parameters**:
- `_newOwner`: Address of the new owner (must be a contract)
- `_pin`: 6-digit PIN for future verification

**Events**: `OwnerSet(address indexed newOwner)`, `PinSet(address indexed newOwner)`

**Requirements**:
- Only current owner can call
- New owner not already set
- New owner must be a contract (non-zero address with bytecode)
- PIN must be 6 digits or less

---

#### updateOwner()
```solidity
function updateOwner(address _newDeployerOwner) external
```

**Description**: Updates the mutable deployer owner (only before final owner is set).

**Parameters**:
- `_newDeployerOwner`: New deployer owner address

**Requirements**:
- Only current owner can call
- New owner not already set (final owner)
- Valid non-zero address

---

#### setBackupWallet()
```solidity
function setBackupWallet(address _backupWallet) external
```

**Description**: Sets backup wallet for emergency access within 12-hour window.

**Parameters**:
- `_backupWallet`: Address of backup wallet

**Events**: `BackupWalletSet(address indexed backupWallet)`

**Requirements**:
- New owner must be set first
- Only new owner can call
- Must be within 12 hours of deployment
- Valid non-zero address

---

#### lockContract()
```solidity
function lockContract(
    address _targetContract,
    bytes32 _dataId,
    bytes32 _data,
    bytes32 _recipientPubKeyX,
    bytes32 _recipientPubKeyY,
    bytes32 _ephemeralPrivKey
) external
```

**Description**: Encrypts data and locks target contract until decryption.

**Parameters**:
- `_targetContract`: Address of contract to lock
- `_dataId`: Unique identifier for encrypted data
- `_data`: 32-byte data to encrypt
- `_recipientPubKeyX`: X coordinate of recipient's public key
- `_recipientPubKeyY`: Y coordinate of recipient's public key
- `_ephemeralPrivKey`: Private key for ephemeral key generation

**Events**: `ContractLocked(address indexed targetContract, bytes32 indexed dataId)`

**Requirements**:
- Only owner or new owner can call
- Data ID must not already be used
- Valid recipient public key
- Valid target contract address

---

#### unlockContract()
```solidity
function unlockContract(
    address _targetContract,
    bytes32 _dataId,
    bytes32 _recipientPrivKey,
    uint256 _pin
) external returns (bytes32)
```

**Description**: Decrypts data and unlocks target contract with PIN verification.

**Parameters**:
- `_targetContract`: Address of contract to unlock
- `_dataId`: Identifier of encrypted data
- `_recipientPrivKey`: Private key for decryption
- `_pin`: 6-digit PIN for verification

**Returns**: Decrypted 32-byte data

**Events**: `ContractUnlocked(address indexed targetContract, bytes32 indexed dataId)`

**Requirements**:
- Encrypted data must exist for data ID
- Must be within 24-hour decryption window
- Valid PIN verification
- Authorized caller (owner or backup wallet)

---

#### View Functions

```solidity
function isContractLocked(address _targetContract) external view returns (bool)
```

**Description**: Returns whether a contract is currently locked.

---

## 🔧 WorkingLockManager Contract

Manages interface locking with owner-controlled security protocols and partial lockdown capabilities.

### State Variables

```solidity
address public owner;                    // Mutable deployer owner
address public newOwner;                 // Final owner (immutable once set)
address public _backupWallet;           // Backup wallet
bytes32 private _pinHash;                // PIN hash
uint48 public immutable deploymentTimestamp;  // Deployment timestamp (gas-optimized)
bool private newOwnerNotSet;             // Inverse logic for gas efficiency
mapping(bytes32 => EncryptionA.Ciphertext) private _encryptedData;  // Encrypted data
mapping(address => bool) public _isInterfaceLocked;  // Interface lock status
EncryptionManager public immutable encryptionManager;  // Reference to encryption manager
```

### Functions

#### Constructor
```solidity
constructor(address _encryptionManager) payable
```

**Description**: Initializes with reference to EncryptionManager contract.

**Parameters**:
- `_encryptionManager`: Address of EncryptionManager contract

**Requirements**:
- EncryptionManager address must be valid contract

---

#### setOwner()
```solidity
function setOwner(address _newOwner, uint256 _pin) external onlyOwner
```

**Description**: Sets final owner with PIN protection.

**Parameters**:
- `_newOwner`: New owner address (must be contract)
- `_pin`: 6-digit PIN

**Requirements**:
- New owner not already set
- Valid contract address
- PIN within valid range

---

#### setBackupWallet()
```solidity
function setBackupWallet(address _backupWallet) external
```

**Description**: Sets backup wallet within 12-hour window.

**Requirements**:
- Owner must be set first
- Must be within deployment window
- Only new owner can call

---

#### lockInterface()
```solidity
function lockInterface(
    address _targetContract,
    bytes32 _dataId,
    bytes32 _data,
    bytes32 _recipientPubKeyX,
    bytes32 _recipientPubKeyY,
    bytes32 _ephemeralPrivKey
) external onlyOwner
```

**Description**: Locks contract interface functions while allowing internal operations.

**Events**: `InterfaceLocked(address indexed targetContract, bytes32 indexed dataId)`

---

#### unlockInterface()
```solidity
function unlockInterface(
    address _targetContract,
    bytes32 _dataId,
    bytes32 _recipientPrivKey,
    uint256 _pin
) external returns (bytes32)
```

**Description**: Unlocks contract interface with PIN verification.

**Events**: `InterfaceUnlocked(address indexed targetContract, bytes32 indexed dataId)`

---

#### triggerFullLockdown()
```solidity
function triggerFullLockdown(
    address _targetContract,
    bytes32 _dataId,
    bytes32 _data,
    bytes32 _recipientPubKeyX,
    bytes32 _recipientPubKeyY,
    bytes32 _ephemeralPrivKey
) external onlyOwner
```

**Description**: Triggers both interface lock and full contract lockdown via EncryptionManager.

**Events**: `FullLockdownTriggered(address indexed targetContract, bytes32 indexed dataId)`

---

#### View Functions

```solidity
function isInterfaceLocked(address _targetContract) external view returns (bool)
```

---

## 🔗 LockableContract Base

Base contract providing lockable functionality for integration with lock managers.

### State Variables

```solidity
IWorkingLockManager public workingLockManager;  // Interface lock manager
IEncryptionManager public encryptionManager;    // Full lock manager
```

### Modifiers

#### notLocked
```solidity
modifier notLocked()
```

**Description**: Prevents function execution when contract interface or full contract is locked.

**Requirements**:
- Interface must not be locked via WorkingLockManager
- Contract must not be fully locked via EncryptionManager

---

#### allowInternal
```solidity
modifier allowInternal()
```

**Description**: Allows internal contract calls even when interface is locked, but blocks when fully locked.

**Requirements**:
- Contract must not be fully locked via EncryptionManager
- Internal calls (msg.sender == address(this)) are allowed even when interface-locked

---

### Functions

#### Constructor
```solidity
constructor(address _workingLockManager, address _encryptionManager)
```

**Description**: Initializes contract with lock manager references.

---

#### Lock Trigger Functions

```solidity
function triggerInterfaceLock(...) external
function triggerFullLockdown(...) external
```

**Description**: Wrapper functions to trigger locks via respective managers.

---

## 💎 ReflectionLibrary

Comprehensive library for implementing token reflection rewards with configurable fees.

### Data Structures

#### _FeeConfig
```solidity
struct _FeeConfig {
    uint256 creatorFeeBps;      // Creator fee in basis points
    uint256 reflectionFeeBps;   // Reflection fee in basis points  
    uint256 liquidityFeeBps;    // Liquidity pool fee in basis points
    uint256 burnFeeBps;         // Burn fee in basis points
    uint256 totalFeeBps;        // Cached total fee
    address creatorAddress;     // Creator fee recipient
    address liquidityPool;      // Liquidity pool address
    bool isInitialized;         // Initialization flag
}
```

#### _AccountData
```solidity
struct _AccountData {
    uint256 reflectedBalance;           // Balance including reflections
    uint256 excludedBalance;            // Balance excluded from reflection
    uint256 lastReflectionPerToken;     // Last reflection checkpoint
    bool isExcludedFromFees;            // Fee exemption status
    bool isExcludedFromReflection;      // Reflection exemption status
}
```

#### _ReflectionState
```solidity
struct _ReflectionState {
    uint256 totalReflected;         // Total reflected tokens
    uint256 totalExcludedSupply;    // Supply excluded from reflection
    uint256 reflectionPerToken;     // Reflection rate per token
}
```

### Main Functions

#### initializeFees()
```solidity
function initializeFees(
    _FeeConfig storage config,
    uint256 creatorFeeBps,
    uint256 reflectionFeeBps,
    uint256 liquidityFeeBps,
    uint256 burnFeeBps,
    address creatorAddress,
    address liquidityPool
) internal
```

**Description**: Initializes fee configuration for the token.

**Requirements**:
- Total fees must not exceed 100% (10000 basis points)
- All addresses must be valid
- Can only be called once

---

#### processTransaction()
```solidity
function processTransaction(
    _FeeConfig storage feeConfig,
    _ReflectionState storage reflectionState,
    mapping(address => _AccountData) storage accounts,
    address from,
    address to,
    uint256 amount
) internal returns (uint256 netAmount, uint256 totalFees)
```

**Description**: Processes a transaction with fee calculation and reflection distribution.

**Returns**: 
- `netAmount`: Amount after fees
- `totalFees`: Total fees collected

---

#### Reflection Management

```solidity
function excludeFromReflection(...)  // Exclude account from reflections
function includeInReflection(...)    // Include account in reflections
function excludeFromFees(...)        // Exclude account from fees
function includeInFees(...)          // Include account in fees
```

#### Batch Operations

```solidity
function batchExcludeFromReflection(...)  // Batch reflection exclusion
function batchExcludeFromFees(...)        // Batch fee exclusion
```

**Gas Limit**: Maximum 100 accounts per batch to prevent gas limit issues.

---

## 🔌 Interface Definitions

### IEncryptionManager
```solidity
interface IEncryptionManager {
    function lockContract(address _targetContract, bytes32 _dataId, bytes32 _data, bytes32 _recipientPubKeyX, bytes32 _recipientPubKeyY, bytes32 _ephemeralPrivKey) external;
    function unlockContract(address _targetContract, bytes32 _dataId, bytes32 _recipientPrivKey, uint256 _pin) external returns (bytes32);
    function isContractLocked(address _targetContract) external view returns (bool);
}
```

### IWorkingLockManager
```solidity
interface IWorkingLockManager {
    function lockInterface(address _targetContract, bytes32 _dataId, bytes32 _data, bytes32 _recipientPubKeyX, bytes32 _recipientPubKeyY, bytes32 _ephemeralPrivKey) external;
    function unlockInterface(address _targetContract, bytes32 _dataId, bytes32 _recipientPrivKey, uint256 _pin) external returns (bytes32);
    function triggerFullLockdown(address _targetContract, bytes32 _dataId, bytes32 _data, bytes32 _recipientPubKeyX, bytes32 _recipientPubKeyY, bytes32 _ephemeralPrivKey) external;
    function isInterfaceLocked(address _targetContract) external view returns (bool);
}
```

---

## 📊 Gas Usage Reference

| Operation | Estimated Gas | Notes |
|-----------|---------------|-------|
| Encryption | ~50,000 | ECIES with MAC generation |
| Decryption | ~45,000 | Includes PIN verification |
| Lock Contract | ~55,000 | Encryption + storage update |
| Unlock Contract | ~50,000 | Decryption + storage update |
| Set Owner | ~30,000 | First-time setup |
| Reflection Transfer | ~80,000 | With fee processing |
| Batch Operations (10 items) | ~200,000 | Linear scaling |

## 🔍 Error Reference

### Common Error Messages

| Error | Contract | Meaning |
|-------|----------|---------|
| "Only owner" | All | Access control violation |
| "New owner already set" | Managers | Owner finalization prevents changes |
| "Invalid PIN: Must be 6 digits" | All | PIN validation failure |
| "Decryption window expired" | EncryptionA | 24-hour window exceeded |
| "Data ID already used" | Managers | Prevents data ID reuse |
| "Contract interface is locked" | LockableContract | Interface functions disabled |
| "Invalid recipient public key" | EncryptionA | Zero or invalid key coordinates |

---

For implementation examples and integration patterns, see the main [README.md](README.md).