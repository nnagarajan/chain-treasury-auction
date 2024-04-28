import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  const [tokenOwner, otherAccount1, otherAccount2,otherAccount3] = await ethers.getSigners(); 
  const treasuryBondAuction =  await ethers.getContractAt("TreasuryBondAuction","0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0"); 

  await treasuryBondAuction.connect(otherAccount1).placeBid(8,1, { value: ethers.parseEther("0.0005") });
//   await treasuryBondAuction.connect(otherAccount2).placeBid(5,2, { value: ethers.parseEther("0.0010") });
//   await treasuryBondAuction.connect(otherAccount3).placeBid(7,1, { value: ethers.parseEther("0.0005") });
  console.log(await treasuryBondAuction.connect(tokenOwner).totalBidsReceived());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })