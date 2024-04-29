import { ethers, getNamedAccounts, deployments } from "hardhat"

async function main() {
  const [tokenOwner, otherAccount1, otherAccount2,otherAccount3] = await ethers.getSigners(); 
  const treasuryBondAuction =  await ethers.getContractAt("TreasuryBondAuction","0xC358dE3159E8f3f914bEcb341Ae0A3c2FC97Da52"); 

  await treasuryBondAuction.connect(otherAccount1).placeBid(819, 30, { value: ethers.parseEther((0.00005 * 3).toFixed(7).toString()) });
//   await treasuryBondAuction.connect(otherAccount2).placeBid(823, 25, { value: ethers.parseEther((0.00005 * 3.5).toFixed(7).toString()) });
//   await treasuryBondAuction.connect(otherAccount3).placeBid(822, 20, { value: hre.ethers.parseEther((0.00005 * 2).toFixed(7).toString()) });
  console.log(await treasuryBondAuction.connect(tokenOwner).totalBidsReceived());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

  //0.747805338988354773
  //0.74795533898835477
