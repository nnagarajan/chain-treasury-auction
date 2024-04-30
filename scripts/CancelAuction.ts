import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
  const [tokenOwner, otherAccount1, otherAccount2, otherAccount3] = await ethers.getSigners();
  const treasuryBondAuction = await ethers.getContractAt(
    "TreasuryBondAuction",
    "0x82D815b5b245c53aDab9F80dA9cF14F3058399d8",
  );

  await treasuryBondAuction.connect(tokenOwner).cancelAndReleaseAllFunds();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
