import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
  const [tokenOwner] = await ethers.getSigners();
  const treasuryBondAuction = await ethers.getContractAt(
    "TreasuryBondAuction",
    "0x288F6e238BCED1638201f3eaBF0e2FB311cE50CF",
  );
  await treasuryBondAuction.connect(tokenOwner).endAuction();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
