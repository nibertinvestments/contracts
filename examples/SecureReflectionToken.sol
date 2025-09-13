// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../LockableContract.sol";
import "../ReflectionLibrary.sol";

/**
 * @title SecureReflectionToken
 * @dev Example implementation of a reflection token with security features
 * @notice This token implements reflection rewards with advanced security controls
 */
contract SecureReflectionToken is LockableContract {
    using ReflectionRewards for ReflectionRewards._AccountData;
    using ReflectionRewards for ReflectionRewards._FeeConfig;
    using ReflectionRewards for ReflectionRewards._ReflectionState;
    
    // Token metadata
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    // Reflection system
    ReflectionRewards._FeeConfig private feeConfig;
    ReflectionRewards._ReflectionState private reflectionState;
    mapping(address => ReflectionRewards._AccountData) private accounts;
    
    // Standard ERC20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Reflection-specific events
    event ReflectionConfigured(uint256 creatorFee, uint256 reflectionFee, uint256 liquidityFee, uint256 burnFee);
    event AccountExcludedFromReflection(address indexed account);
    event AccountIncludedInReflection(address indexed account);
    event AccountExcludedFromFees(address indexed account);
    event AccountIncludedInFees(address indexed account);
    
    /**
     * @dev Constructor for SecureReflectionToken
     * @param _workingLockManager Address of the WorkingLockManager contract
     * @param _encryptionManager Address of the EncryptionManager contract
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _totalSupply Initial total supply (with decimals)
     */
    constructor(
        address _workingLockManager,
        address _encryptionManager,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) LockableContract(_workingLockManager, _encryptionManager) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        
        // Assign initial supply to deployer
        accounts[msg.sender].reflectedBalance = _totalSupply;
        reflectionState.totalExcludedSupply = _totalSupply;
        
        // Exclude deployer from fees initially
        accounts[msg.sender].isExcludedFromFees = true;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    /**
     * @dev Initialize reflection fee system
     * @param creatorFeeBps Creator fee in basis points (e.g., 200 = 2%)
     * @param reflectionFeeBps Reflection fee in basis points (e.g., 300 = 3%)
     * @param liquidityFeeBps Liquidity fee in basis points (e.g., 100 = 1%)
     * @param burnFeeBps Burn fee in basis points (e.g., 100 = 1%)
     * @param creatorAddress Address to receive creator fees
     * @param liquidityPool Address of liquidity pool
     */
    function initializeReflection(
        uint256 creatorFeeBps,
        uint256 reflectionFeeBps,
        uint256 liquidityFeeBps,
        uint256 burnFeeBps,
        address creatorAddress,
        address liquidityPool
    ) external allowInternal {
        require(msg.sender == address(this) || msg.sender == owner(), "Unauthorized");
        
        feeConfig.initializeFees(
            creatorFeeBps,
            reflectionFeeBps,
            liquidityFeeBps,
            burnFeeBps,
            creatorAddress,
            liquidityPool
        );
        
        emit ReflectionConfigured(creatorFeeBps, reflectionFeeBps, liquidityFeeBps, burnFeeBps);
    }
    
    /**
     * @dev Transfer tokens with lock protection
     * @param to Recipient address
     * @param amount Amount to transfer
     * @return Success status
     */
    function transfer(address to, uint256 amount) 
        external 
        notLocked 
        returns (bool) 
    {
        return _transfer(msg.sender, to, amount);
    }
    
    /**
     * @dev Transfer tokens on behalf of another address with lock protection
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     * @return Success status
     */
    function transferFrom(address from, address to, uint256 amount)
        external
        notLocked
        returns (bool)
    {
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        
        _approve(from, msg.sender, currentAllowance - amount);
        return _transfer(from, to, amount);
    }
    
    /**
     * @dev Approve spending allowance
     * @param spender Address allowed to spend
     * @param amount Amount approved for spending
     * @return Success status
     */
    function approve(address spender, uint256 amount) 
        external 
        notLocked 
        returns (bool) 
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev Get token balance of an account
     * @param account Account to check
     * @return Token balance
     */
    function balanceOf(address account) public view returns (uint256) {
        return accounts[account].getBalance(reflectionState);
    }
    
    /**
     * @dev Get spending allowance
     * @param owner Token owner
     * @param spender Approved spender
     * @return Approved amount
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return accounts[owner].allowances[spender];
    }
    
    /**
     * @dev Exclude account from reflection rewards (admin function)
     * @param account Account to exclude
     */
    function excludeFromReflection(address account) external allowInternal {
        require(msg.sender == address(this) || msg.sender == owner(), "Unauthorized");
        accounts[account].excludeFromReflection(reflectionState);
        emit AccountExcludedFromReflection(account);
    }
    
    /**
     * @dev Include account in reflection rewards (admin function)
     * @param account Account to include
     */
    function includeInReflection(address account) external allowInternal {
        require(msg.sender == address(this) || msg.sender == owner(), "Unauthorized");
        accounts[account].includeInReflection(reflectionState);
        emit AccountIncludedInReflection(account);
    }
    
    /**
     * @dev Exclude account from fees (admin function)
     * @param account Account to exclude
     */
    function excludeFromFees(address account) external allowInternal {
        require(msg.sender == address(this) || msg.sender == owner(), "Unauthorized");
        accounts[account].isExcludedFromFees = true;
        emit AccountExcludedFromFees(account);
    }
    
    /**
     * @dev Include account in fees (admin function)
     * @param account Account to include
     */
    function includeInFees(address account) external allowInternal {
        require(msg.sender == address(this) || msg.sender == owner(), "Unauthorized");
        accounts[account].isExcludedFromFees = false;
        emit AccountIncludedInFees(account);
    }
    
    /**
     * @dev Get account reflection status
     * @param account Account to check
     * @return isExcludedFromReflection Whether excluded from reflection
     * @return isExcludedFromFees Whether excluded from fees
     */
    function getAccountStatus(address account) external view returns (bool isExcludedFromReflection, bool isExcludedFromFees) {
        return (accounts[account].isExcludedFromReflection, accounts[account].isExcludedFromFees);
    }
    
    /**
     * @dev Get reflection statistics
     * @return totalReflected Total tokens distributed as reflection
     * @return totalExcludedSupply Total supply excluded from reflection
     * @return reflectionPerToken Current reflection rate per token
     */
    function getReflectionStats() external view returns (uint256 totalReflected, uint256 totalExcludedSupply, uint256 reflectionPerToken) {
        return (reflectionState.totalReflected, reflectionState.totalExcludedSupply, reflectionState.reflectionPerToken);
    }
    
    /**
     * @dev Internal transfer function with reflection processing
     * @param from Sender address
     * @param to Recipient address
     * @param amount Amount to transfer
     * @return Success status
     */
    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(balanceOf(from) >= amount, "Transfer amount exceeds balance");
        
        // Process transaction with fees and reflection
        (uint256 netAmount, uint256 totalFees) = feeConfig.processTransaction(
            reflectionState,
            accounts,
            from,
            to,
            amount
        );
        
        // Update balances
        uint256 fromBalance = balanceOf(from);
        uint256 toBalance = balanceOf(to);
        
        accounts[from].updateBalance(fromBalance - amount, reflectionState);
        accounts[to].updateBalance(toBalance + netAmount, reflectionState);
        
        emit Transfer(from, to, netAmount);
        
        // Emit fee transfers if applicable
        if (totalFees > 0) {
            emit Transfer(from, address(this), totalFees);
        }
        
        return true;
    }
    
    /**
     * @dev Internal approval function
     * @param owner Token owner
     * @param spender Approved spender
     * @param amount Approved amount
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        accounts[owner].allowances[spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Get the contract owner (for access control)
     * @return Owner address
     */
    function owner() public view returns (address) {
        // This should be implemented based on your ownership pattern
        // For this example, we'll use a simple approach
        return address(0); // Implement proper owner tracking
    }
}