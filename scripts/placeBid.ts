import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  const [tokenOwner, otherAccount] = await ethers.getSigners(); 
  const treasuryBondAuction =  await ethers.getContractAt("TreasuryBondAuction","0x898046506fD3F6a2C8A31f6B06f7235b478e4618")    

  await treasuryBondAuction.connect(otherAccount).placeBid(8,10)
  await treasuryBondAuction.connect(otherAccount).placeBid(5,25)
  await treasuryBondAuction.connect(otherAccount).placeBid(7,100)
  console.log(await treasuryBondAuction.connect(tokenOwner).totalBidsReceived());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })