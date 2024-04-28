import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  const [tokenOwner] = await ethers.getSigners(); 
  const treasuryBondAuction =  await ethers.getContractAt("TreasuryBondAuction","0x610178dA211FEF7D417bC0e6FeD39F05609AD788")    
  await treasuryBondAuction.connect(tokenOwner).endAuction();  
  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })