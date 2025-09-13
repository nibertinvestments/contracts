# Contributing Guidelines

Thank you for your interest in contributing to the Secure Smart Contracts Library! This document provides guidelines for contributing to this security-focused Solidity project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Security Guidelines](#security-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)

## 🤝 Code of Conduct

### Our Standards

- **Respectful Communication**: Be considerate and respectful in all interactions
- **Collaborative Approach**: Work together towards common goals
- **Constructive Feedback**: Provide helpful, actionable feedback
- **Inclusive Environment**: Welcome contributors of all experience levels
- **Security Focus**: Prioritize security in all contributions

## 🚀 Getting Started

### Prerequisites

- **Solidity Knowledge**: Understanding of Solidity 0.8.30+ features
- **Security Awareness**: Familiarity with smart contract security best practices
- **Git Proficiency**: Comfortable with Git workflows and GitHub
- **Testing Experience**: Knowledge of smart contract testing frameworks

### Development Environment Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/nibertinvestments/contracts.git
   cd contracts
   ```

2. **Install Development Tools** (Choose your preferred framework)
   
   **Option A: Hardhat**
   ```bash
   npm init -y
   npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
   npx hardhat init
   ```
   
   **Option B: Foundry**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   forge init --force
   ```

3. **Install Additional Tools**
   ```bash
   # Static analysis
   pip install slither-analyzer
   
   # Formatter
   npm install --save-dev prettier prettier-plugin-solidity
   ```

### Project Structure Understanding

```
contracts/
├── EncryptionA.sol           # Core encryption library
├── EncryptionManager.sol     # Central encryption management
├── WorkingLockManager.sol    # Interface locking system
├── LockableContract.sol      # Base lockable functionality
├── ReflectionLibrary.sol     # Token reflection rewards
├── README.md                 # Project documentation
├── SECURITY.md              # Security considerations
├── CONTRIBUTING.md          # This file
└── LICENSE                  # MIT license
```

## 🔄 Development Workflow

### Issue Tracking

1. **Check Existing Issues**: Look for existing issues before creating new ones
2. **Use Issue Templates**: Follow the provided templates for consistency
3. **Label Appropriately**: Use relevant labels (bug, enhancement, security, etc.)
4. **Provide Context**: Include clear descriptions and reproduction steps

### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Create bugfix branch  
git checkout -b bugfix/issue-description

# Create security fix branch
git checkout -b security/vulnerability-fix
```

### Commit Guidelines

#### Commit Message Format
```
type(scope): subject

body (optional)

footer (optional)
```

#### Types
- **feat**: New feature or enhancement
- **fix**: Bug fix
- **security**: Security-related changes
- **docs**: Documentation updates
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring without functional changes
- **test**: Adding or updating tests
- **gas**: Gas optimization improvements

#### Examples
```bash
git commit -m "feat(encryption): add batch encryption support"
git commit -m "fix(manager): resolve owner validation edge case"
git commit -m "security(locks): strengthen access control validation"
git commit -m "gas(reflection): optimize token distribution loops"
```

## 📝 Coding Standards

### Solidity Version
- **Primary**: `pragma solidity 0.8.30;` (exact for production)
- **Compatible**: `pragma solidity ^0.8.30;` (for development)

### Code Style

#### 1. Naming Conventions
```solidity
// Private variables: underscore prefix
uint256 private _balance;
bytes32 private _dataHash;

// Public state variables: camelCase
address public owner;
bool public isLocked;

// Constants: UPPER_SNAKE_CASE with underscore prefix
uint256 private constant _MAX_FEE_BPS = 10000;
uint48 private constant _MAX_PIN = 999999;

// Functions: camelCase
function setOwner(address _newOwner) external;
function getEncryptedData() external view returns (bytes32);

// Events: PascalCase
event OwnerSet(address indexed newOwner);
event DataEncrypted(bytes32 indexed dataId);
```

#### 2. Code Organization
```solidity
contract ExampleContract {
    // 1. Type declarations (structs, enums)
    struct AccountData { ... }
    
    // 2. State variables (grouped by visibility)
    // Public first
    address public owner;
    bool public isInitialized;
    
    // Private last
    mapping(address => uint256) private _balances;
    bytes32 private _secretHash;
    
    // 3. Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // 4. Modifiers
    modifier onlyOwner() { ... }
    
    // 5. Constructor
    constructor(address _initialOwner) { ... }
    
    // 6. External functions
    // 7. Public functions  
    // 8. Internal functions
    // 9. Private functions
}
```

#### 3. Documentation Requirements
```solidity
/**
 * @title Contract Title
 * @dev Brief description of contract purpose and key features
 * @notice User-facing description for end users
 */
contract ExampleContract {
    
    /**
     * @dev Detailed function description
     * @param _param Parameter description
     * @return Description of return value
     * @notice User-friendly function description
     */
    function exampleFunction(uint256 _param) external returns (bool) {
        // Implementation
    }
}
```

### Gas Optimization Patterns

#### 1. Efficient Data Types
```solidity
// Use appropriate sized types
uint48 public timestamp;    // Sufficient until year ~8.9 million
uint16 public counter;      // For small counters (0-65535)

// Pack structs efficiently
struct PackedData {
    uint128 amount;     // 16 bytes
    uint64 timestamp;   // 8 bytes  
    uint32 rate;        // 4 bytes
    bool isActive;      // 1 byte (rounds to 32 bytes total)
}
```

#### 2. Storage Optimization
```solidity
// Use mappings for key-value lookups
mapping(address account => uint256 balance) private _balances;

// Use constants for reused values
uint256 private constant _PRECISION = 1e18;

// Batch operations to reduce gas costs
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
    require(recipients.length == amounts.length, "Length mismatch");
    require(recipients.length <= _MAX_BATCH_SIZE, "Batch too large");
    // Implementation
}
```

## 🧪 Testing Requirements

### Test Categories

#### 1. Unit Tests
- Test individual functions in isolation
- Cover all public and external functions
- Test edge cases and error conditions
- Verify gas consumption for optimization

#### 2. Integration Tests
- Test interaction between contracts
- Verify end-to-end workflows
- Test manager and lockable contract integration
- Validate encryption/decryption flows

#### 3. Security Tests
- Test access control mechanisms
- Verify time-window validations
- Test cryptographic operations
- Validate PIN and owner management

#### 4. Gas Tests
- Benchmark gas usage for critical functions
- Test gas limits for batch operations
- Optimize gas-heavy cryptographic functions

### Testing Standards

```solidity
// Example test structure
contract EncryptionManagerTest {
    EncryptionManager private manager;
    address private owner = makeAddr("owner");
    address private newOwner = makeAddr("newOwner"); 
    
    function setUp() public {
        vm.startPrank(owner);
        manager = new EncryptionManager();
        vm.stopPrank();
    }
    
    function testSetOwner_Success() public {
        // Arrange
        uint256 pin = 123456;
        
        // Act
        vm.prank(owner);
        manager.setOwner(newOwner, pin);
        
        // Assert
        assertEq(manager.newOwner(), newOwner);
        // Additional assertions
    }
    
    function testSetOwner_RevertIfNotOwner() public {
        // Test access control
        vm.expectRevert("Only current owner can set new owner");
        vm.prank(makeAddr("attacker"));
        manager.setOwner(newOwner, 123456);
    }
}
```

### Test Coverage Requirements

- **Minimum Coverage**: 90% line coverage
- **Critical Functions**: 100% branch coverage
- **Security Functions**: 100% coverage including edge cases
- **Error Conditions**: All revert conditions tested

## 🔐 Security Guidelines

### Security Review Process

#### 1. Self-Review Checklist
- [ ] Access control properly implemented
- [ ] Input validation for all parameters
- [ ] Proper error handling and revert messages
- [ ] No potential for reentrancy attacks
- [ ] Gas optimization doesn't compromise security
- [ ] Time-based functions handle edge cases
- [ ] Cryptographic operations are secure

#### 2. Common Security Patterns

```solidity
// Input validation
function setOwner(address _newOwner, uint256 _pin) external {
    require(msg.sender == owner, "Only owner");
    require(_newOwner != address(0), "Invalid address");
    require(_newOwner.code.length > 0, "Not a contract");
    require(_pin <= 999999, "Invalid PIN: Must be 6 digits");
    // Implementation
}

// Time window validation  
function decrypt(...) external {
    require(block.timestamp <= _ciphertext.timestamp + 24 hours, 
           "Decryption window expired");
    // Implementation
}

// Reentrancy protection (when needed)
modifier nonReentrant() {
    require(!_locked, "Reentrant call");
    _locked = true;
    _;
    _locked = false;
}
```

#### 3. Security Testing

```solidity
// Test access control
function testOnlyOwnerCanSetOwner() public {
    vm.expectRevert("Only owner");
    vm.prank(makeAddr("attacker"));
    manager.setOwner(newOwner, 123456);
}

// Test time windows
function testDecryptionWindowExpiry() public {
    // Setup encryption
    // Fast forward past 24 hours
    vm.warp(block.timestamp + 24 hours + 1);
    
    vm.expectRevert("Decryption window expired");
    manager.unlockContract(target, dataId, privKey, pin);
}
```

## 📚 Documentation Standards

### Code Documentation

#### 1. NatSpec Comments
```solidity
/**
 * @title EncryptionManager
 * @dev Central contract for managing encryption and decryption operations
 *      with dual-owner pattern and backup wallet support
 * @notice This contract handles secure encryption of data with time-based decryption windows
 */

/**
 * @dev Encrypts data and locks target contract
 * @param _targetContract Address of contract to lock
 * @param _dataId Unique identifier for the encrypted data
 * @param _data The data to encrypt (32 bytes)
 * @param _recipientPubKeyX X coordinate of recipient's public key
 * @param _recipientPubKeyY Y coordinate of recipient's public key  
 * @param _ephemeralPrivKey Private key for ephemeral key generation
 * @notice Locks the target contract until decryption with correct PIN
 * @custom:security Only owner or new owner can call this function
 */
```

#### 2. README Updates
- Update README.md for new features
- Include usage examples
- Document integration patterns
- Update roadmap sections

#### 3. Security Documentation
- Document security assumptions
- Update threat models
- Include mitigation strategies
- Maintain security considerations

## 🔄 Pull Request Process

### Before Submitting

1. **Code Quality**
   - [ ] Code follows style guidelines
   - [ ] All tests pass
   - [ ] Gas optimization considered
   - [ ] Security review completed

2. **Documentation**
   - [ ] Code is properly documented
   - [ ] README updated if needed
   - [ ] SECURITY.md updated for security changes
   - [ ] CHANGELOG updated

3. **Testing**
   - [ ] New tests added for new functionality
   - [ ] All existing tests still pass
   - [ ] Edge cases tested
   - [ ] Gas benchmarks updated

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Security fix
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated  
- [ ] Gas benchmarks updated
- [ ] Manual testing completed

## Security Checklist
- [ ] No new security vulnerabilities introduced
- [ ] Access controls properly implemented
- [ ] Input validation added
- [ ] Security documentation updated

## Additional Notes
Any additional context or notes for reviewers
```

### Review Process

1. **Automated Checks**: CI/CD pipeline runs tests and static analysis
2. **Peer Review**: At least one other contributor reviews code
3. **Security Review**: Security-focused review for sensitive changes
4. **Gas Analysis**: Gas consumption analysis for optimization
5. **Documentation Review**: Ensure documentation is complete and accurate

### Merge Requirements

- [ ] All automated checks pass
- [ ] At least one approving review
- [ ] All conversations resolved
- [ ] Branch is up to date with main
- [ ] Security review completed (for security-related changes)

## 🏷️ Release Process

### Version Numbering
Follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Security review completed
- [ ] Gas benchmarks updated
- [ ] CHANGELOG updated
- [ ] Version tags created

## 🆘 Getting Help

### Resources
- **Documentation**: Check README.md and inline documentation
- **Issues**: Search existing GitHub issues
- **Discussions**: Use GitHub Discussions for questions
- **Security**: Follow responsible disclosure for security issues

### Contact
- **General Questions**: GitHub Discussions
- **Bug Reports**: GitHub Issues
- **Security Issues**: Private security reporting
- **Feature Requests**: GitHub Issues with enhancement label

---

Thank you for contributing to the Secure Smart Contracts Library! Your contributions help build a more secure decentralized ecosystem.