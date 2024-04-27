import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI: bigint = 1_000_000_000n;

const LockModule = buildModule("TreasuryBondAuction", (m) => {
  const auctionDuration = m.getParameter("_auctionDuration", 1000);
  const minimumBid = m.getParameter("_minimumBid", 1);
  const bondName = m.getParameter("_bondName", "TREAS1");
  const bondName = m.getParameter("_bondName", "TREAS1");

  const lock = m.contract("Lock", [unlockTime], {
    value: lockedAmount,
  });

  return { lock };
});

export default LockModule;

uint _auctionDuration,
uint _minimumBid,
string memory _bondName,
string memory _bondSymbol,
uint256 _bondTotalSupply,
uint256 _bondMaturityInYears
