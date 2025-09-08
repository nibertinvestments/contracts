# Copilot Instructions for Contracts Repository

## Repository Overview

This repository contains security-focused Solidity smart contracts implementing encryption, access control, and token reflection reward systems. The primary focus is on secure contract management with advanced owner controls, backup mechanisms, and cryptographic protection.

## Core Architecture

### Key Components

1. **EncryptionA.sol** - Gas-efficient encryption library using ECIES with secp256k1
2. **EncryptionManager.sol** - Central contract encryption/decryption management
3. **WorkingLockManager.sol** - Interface locking with owner-controlled security protocols
4. **LockableContract.sol** - Base contract that can be locked/unlocked via managers
5. **ReflectionLibrary.sol** - Token reflection rewards with configurable fee structures

### Security Architecture

- **Owner Management**: Implements dual-owner pattern (mutable deployer owner + immutable final owner)
- **Backup Systems**: 12-hour backup wallet setup window for emergency recovery
- **PIN Protection**: 6-digit PIN verification with hash storage
- **Time Locks**: 24-hour decryption windows and deployment-based timeouts
- **Encryption**: ECIES-based contract data encryption with MAC verification

## Coding Standards

### Solidity Version
- Primary version: `0.8.30` (exact)
- Some contracts use `^0.8.30` (compatible)
- Always specify exact pragma for production contracts

### Code Style Guidelines

1. **Naming Conventions**:
   - Private variables: prefix with underscore (`_variable`)
   - Public state variables: camelCase without prefix
   - Constants: UPPER_SNAKE_CASE with underscore prefix
   - Functions: camelCase
   - Events: PascalCase

2. **Documentation**:
   - Use NatSpec comments (`@title`, `@dev`, `@param`, `@return`)
   - Document security considerations and assumptions
   - Include warnings about time-based functions and block.timestamp usage

3. **State Variables**:
   - Group by visibility (public, private)
   - Use `immutable` for deployment-time constants
   - Consider gas-efficient data types (e.g., `uint48` for timestamps)

### Gas Optimization Patterns

1. **Efficient Data Types**:
   - Use `uint48` for timestamps (sufficient until year ~8.9 million)
   - Use `bool` inverse logic for gas efficiency (`newOwnerNotSet` vs `newOwnerSet`)

2. **Mappings**:
   - Use descriptive key-value naming: `mapping(bytes32 dataId => EncryptionA.Ciphertext ciphertext)`
   - Prefer mappings over arrays for lookups

3. **Constants**:
   - Define reusable constants (`_MAX_FEE_BPS`, `_PRECISION`, `_MAX_BATCH_SIZE`)
   - Use for limits and mathematical precision

### Security Patterns

1. **Access Control**:
   - Always use `require` statements with descriptive error messages
   - Implement modifier-based access control (`onlyOwner`)
   - Validate addresses are not zero and contracts have code

2. **Owner Management**:
   - Implement two-phase ownership transfer
   - Use backup wallet systems with time windows
   - Validate new owners are contracts when required

3. **Input Validation**:
   - Validate PIN ranges (≤ 999999 for 6-digit PINs)
   - Check addresses are not zero: `require(_address != address(0), "Invalid address")`
   - Verify contract addresses have bytecode: `require(_address.code.length > 0, "Not a contract")`
   - Validate timestamp windows for time-sensitive operations
   - Check public key validity: `require(_pubKeyX != bytes32(0) && _pubKeyY != bytes32(0), "Invalid public key")`

4. **Cryptographic Safety**:
   - Use `keccak256` for hashing
   - Implement MAC verification for encrypted data
   - Include proper key validation for elliptic curve operations

### Error Handling

- Use descriptive error messages that help with debugging
- Keep error messages concise but informative
- Common patterns:
  - Access control: "Only owner", "Unauthorized: Only owner or backup wallet"
  - State validation: "New owner already set", "Contract interface is locked"
  - Input validation: "Invalid PIN: Must be 6 digits", "Invalid recipient public key"
  - Time validation: "Decryption window expired", "Backup window expired"
  - Data integrity: "Invalid MAC: Data tampered", "Data ID already used"

## Development Guidelines

### Testing Approach
- Focus on security-critical functions (owner changes, encryption/decryption)
- Test edge cases for time-based functions
- Verify proper access control enforcement
- Test cryptographic operations with known vectors

### Deployment Considerations
- Set immutable variables correctly during deployment
- Initialize owner state properly
- Consider gas costs for complex cryptographic operations
- Plan for owner transition and backup wallet setup timing

### Library Usage
- Libraries should be `internal` functions only
- Emit events from libraries for transparency
- Use libraries for reusable cryptographic and mathematical operations
- Maintain consistent error handling across library functions

## Common Patterns

### Owner Pattern
```solidity
address public owner; // Mutable deployer owner
address public newOwner; // Final owner, immutable via flag
bool private newOwnerSet; // Prevents changes after finalization

modifier onlyOwner() {
    require(msg.sender == owner || (newOwner != address(0) && msg.sender == newOwner), "Only owner");
    _;
}
```

### Time-Based Security
```solidity
uint256 public immutable deploymentTimestamp;
require(block.timestamp <= deploymentTimestamp + 12 hours, "Window expired");
require(block.timestamp <= _ciphertext.timestamp + 24 hours, "Decryption window expired");
```

### Encrypted Data Storage
```solidity
mapping(bytes32 => EncryptionA.Ciphertext) private encryptedData;
// Always check timestamp == 0 to prevent data ID reuse
require(encryptedData[_dataId].timestamp == 0, "Data ID already used");
```

### Interface Definitions
```solidity
interface IEncryptionManager {
    function lockContract(address _targetContract, bytes32 _dataId, bytes32 _data, bytes32 _recipientPubKeyX, bytes32 _recipientPubKeyY, bytes32 _ephemeralPrivKey) external;
    function unlockContract(address _targetContract, bytes32 _dataId, bytes32 _recipientPrivKey, uint256 _pin) external returns (bytes32);
    function isContractLocked(address _targetContract) external view returns (bool);
}
```

### Import Structure
```solidity
// Use relative imports for local contracts
import "./EncryptionA.sol";
import "./EncryptionManager.sol";
```

### Locking Modifiers
```solidity
modifier notLocked() {
    require(!workingLockManager.isInterfaceLocked(address(this)), "Contract interface is locked");
    _;
}

modifier allowInternal() {
    require(!encryptionManager.isContractLocked(address(this)) || msg.sender == address(this), "Contract locked");
    _;
}
```

## Security Considerations

1. **Block Timestamp Dependency**: Code uses `block.timestamp` for timelocks - document that this may vary due to block time fluctuations
2. **Owner Centralization**: Single owner has significant control - ensure proper owner transition procedures
3. **PIN Security**: 6-digit PINs have limited entropy - suitable only for additional verification layer
4. **Contract Upgrade**: No upgrade mechanisms - deploy new versions for updates
5. **Gas Limits**: Batch operations include size limits to prevent gas exhaustion

## When Contributing

- Follow existing patterns for owner management and access control
- Add comprehensive tests for new security-sensitive functions
- Document any new cryptographic assumptions or requirements
- Consider gas costs and optimize for common operations
- Maintain backward compatibility when possible
- Update this documentation for significant architectural changes