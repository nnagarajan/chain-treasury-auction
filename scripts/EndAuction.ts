import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  const [tokenOwner] = await ethers.getSigners(); 
  const treasuryBondAuction =  await ethers.getContractAt("TreasuryBondAuction","0xC358dE3159E8f3f914bEcb341Ae0A3c2FC97Da52")    
  await treasuryBondAuction.connect(tokenOwner).endAuction();  
  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })