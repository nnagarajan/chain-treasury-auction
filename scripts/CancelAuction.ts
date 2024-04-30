import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
  const [tokenOwner, otherAccount1, otherAccount2, otherAccount3] = await ethers.getSigners();
  const treasuryBondAuction = await ethers.getContractAt(
    "TreasuryBondAuction",
    "0xEFE2eC15ed01ffECb037792B3601F5645ae89c9a",
  );

  await treasuryBondAuction.connect(tokenOwner).cancelAndReleaseAllFunds();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
