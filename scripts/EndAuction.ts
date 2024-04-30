import { ethers, getNamedAccounts, deployments } from "hardhat";

async function main() {
  const [tokenOwner] = await ethers.getSigners();
  const treasuryBondAuction = await ethers.getContractAt(
    "TreasuryBondAuction",
    "0xEFE2eC15ed01ffECb037792B3601F5645ae89c9a",
  );
  await treasuryBondAuction.connect(tokenOwner).endAuction();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
