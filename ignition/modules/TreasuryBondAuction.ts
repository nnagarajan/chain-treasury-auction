import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import hre from "hardhat";
import { networkConfig, developmentChains } from "../../helper-hardhat-config";

const AUCTION_DURATION = 1000;

const TreasuryBondAuctionModule = buildModule("TreasuryBondAuction", (m) => {
  const auctionDuration = m.getParameter("_auctionDuration", AUCTION_DURATION);
  const minimumBid = m.getParameter("_minimumBid", 1);
  const bondName = m.getParameter("_bondName", "TREAS1");
  const bondTotalSupply = m.getParameter("_bondTotalSupply", 100);
  const bondMaturityInYears = m.getParameter("_bondMaturityInYears", 10);
  const chainId = hre.network.config.chainId;

  const DECIMALS = "18";
  const INITIAL_PRICE = "2000000000000000000000"; // 2000
  let mockV3AggregatorContract;
  if (chainId == 31337) {
    mockV3AggregatorContract = m.contract("MockV3Aggregator", [
      DECIMALS,
      INITIAL_PRICE,
    ]);
  } else {
    mockV3AggregatorContract = networkConfig[hre.network.name].ethUsdPriceFeed!;
  }

  const treasuryBondAuction = m.contract("TreasuryBondAuction", [
    auctionDuration,
    minimumBid,
    bondName,
    bondTotalSupply,
    bondMaturityInYears,
    mockV3AggregatorContract,
  ]);

  return { treasuryBondAuction };
});

export default TreasuryBondAuctionModule;
