import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
  const [tokenOwner, otherAccount1, otherAccount2, otherAccount3] = await ethers.getSigners();
  const treasuryBondAuction = await ethers.getContractAt(
    "TreasuryBondAuction",
    "0x288F6e238BCED1638201f3eaBF0e2FB311cE50CF",
  );

  await treasuryBondAuction.connect(tokenOwner).cancelAndReleaseAllFunds();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
