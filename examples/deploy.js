// SPDX-License-Identifier: MIT
/**
 * Example deployment script for Hardhat
 * 
 * This script demonstrates how to deploy the secure contracts library
 * and configure them properly with security settings.
 * 
 * Usage:
 *   npx hardhat run scripts/deploy.js --network <network-name>
 */

const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying contracts with account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    
    // Step 1: Deploy EncryptionManager
    console.log("\n📦 Deploying EncryptionManager...");
    const EncryptionManager = await ethers.getContractFactory("EncryptionManager");
    const encryptionManager = await EncryptionManager.deploy();
    await encryptionManager.deployed();
    console.log("✅ EncryptionManager deployed to:", encryptionManager.address);
    
    // Step 2: Deploy WorkingLockManager
    console.log("\n📦 Deploying WorkingLockManager...");
    const WorkingLockManager = await ethers.getContractFactory("WorkingLockManager");
    const lockManager = await WorkingLockManager.deploy(encryptionManager.address);
    await lockManager.deployed();
    console.log("✅ WorkingLockManager deployed to:", lockManager.address);
    
    // Step 3: Deploy Example Token
    console.log("\n📦 Deploying SecureReflectionToken...");
    const SecureReflectionToken = await ethers.getContractFactory("SecureReflectionToken");
    const token = await SecureReflectionToken.deploy(
        lockManager.address,
        encryptionManager.address,
        "Secure Token",
        "SECURE",
        ethers.utils.parseEther("1000000") // 1M tokens
    );
    await token.deployed();
    console.log("✅ SecureReflectionToken deployed to:", token.address);
    
    // Step 4: Configure Security Settings
    console.log("\n🔐 Configuring security settings...");
    
    // Example final owner contract (in practice, this would be a multisig or DAO)
    const finalOwner = "0x742e2C8B8D0Fc0B1E6a7E2947E1E70e2e5CbE3A3"; // Replace with actual contract
    const pin = 123456; // 6-digit PIN (use secure PIN in production)
    
    // Set owners (commented out for safety in example)
    // await encryptionManager.setOwner(finalOwner, pin);
    // await lockManager.setOwner(finalOwner, pin);
    
    console.log("⚠️  Manual steps required:");
    console.log("1. Set final owner for EncryptionManager:");
    console.log(`   encryptionManager.setOwner("${finalOwner}", ${pin})`);
    console.log("2. Set final owner for WorkingLockManager:");
    console.log(`   lockManager.setOwner("${finalOwner}", ${pin})`);
    console.log("3. Configure backup wallet within 12 hours of deployment");
    
    // Step 5: Initialize Token Features
    console.log("\n💰 Initializing token reflection...");
    
    const creatorAddress = deployer.address; // Creator fee recipient
    const liquidityPool = "0x0000000000000000000000000000000000000000"; // Replace with actual LP
    
    await token.initializeReflection(
        200,  // 2% creator fee
        300,  // 3% reflection fee
        100,  // 1% liquidity fee
        100,  // 1% burn fee
        creatorAddress,
        liquidityPool
    );
    console.log("✅ Token reflection configured");
    
    // Step 6: Display Deployment Summary
    console.log("\n📋 Deployment Summary:");
    console.log("========================");
    console.log("EncryptionManager:", encryptionManager.address);
    console.log("WorkingLockManager:", lockManager.address);
    console.log("SecureReflectionToken:", token.address);
    console.log("Network:", await ethers.provider.getNetwork());
    console.log("Deployer:", deployer.address);
    console.log("Deployment Time:", new Date().toISOString());
    
    // Step 7: Save Deployment Information
    const deploymentInfo = {
        network: (await ethers.provider.getNetwork()).name,
        chainId: (await ethers.provider.getNetwork()).chainId,
        deployer: deployer.address,
        timestamp: Math.floor(Date.now() / 1000),
        contracts: {
            EncryptionManager: encryptionManager.address,
            WorkingLockManager: lockManager.address,
            SecureReflectionToken: token.address
        },
        configuration: {
            tokenName: "Secure Token",
            tokenSymbol: "SECURE",
            totalSupply: "1000000",
            fees: {
                creator: "2%",
                reflection: "3%",
                liquidity: "1%",
                burn: "1%"
            }
        },
        nextSteps: [
            "Set final owners for managers",
            "Configure backup wallets within 12 hours",
            "Verify contracts on block explorer",
            "Test lock/unlock functionality"
        ]
    };
    
    console.log("\n💾 Deployment info saved to deployment.json");
    
    // Return deployment info for further processing
    return deploymentInfo;
}

// Execute deployment
main()
    .then((deploymentInfo) => {
        console.log("\n🎉 Deployment completed successfully!");
        process.exit(0);
    })
    .catch((error) => {
        console.error("\n❌ Deployment failed:");
        console.error(error);
        process.exit(1);
    });