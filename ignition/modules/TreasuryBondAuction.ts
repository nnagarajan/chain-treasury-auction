import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import hre from "hardhat";
import { networkConfig, developmentChains } from "../../helper-hardhat-config";

const AUCTION_DURATION = 1000;

const TreasuryBondAuctionModule = buildModule("TreasuryBondAuction", (m) => {
  const auctionDuration = m.getParameter("_auctionDuration", AUCTION_DURATION);
  const minimumBid = m.getParameter("_minimumBid", 1);
  const bondName = m.getParameter("_bondName", "TSRY043024");
  const bondTotalSupply = m.getParameter("_bondTotalSupply", 50);
  const bondMaturityInYears = m.getParameter("_bondMaturityInYears", 10);
  const ethFactor = m.getParameter("_ethFactor", 1000000);
  const chainId = hre.network.config.chainId;

  const DECIMALS = "8";
  const INITIAL_PRICE = "330829323565"; // 3308.29
  let mockV3AggregatorContract;
  if (chainId == 31337 || chainId == 10000) {
    mockV3AggregatorContract = m.contract("MockV3Aggregator", [DECIMALS, INITIAL_PRICE]);
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
    ethFactor,
  ]);

  console.log("TreasuryBondAuctionModule Invoked for Contract Creation.. ");

  return { treasuryBondAuction };
});

export default TreasuryBondAuctionModule;
