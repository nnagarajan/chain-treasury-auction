import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import hre from "hardhat";


const MockV3AggregatorModule = buildModule("MockV3Aggregator", (m) => {    
    const chainId = hre.network.config.chainId;
  
    const DECIMALS = "18";
    const INITIAL_PRICE = "2000000000000000000000"; // 2000

    const MockV3Aggregator = m.contract("MockV3Aggregator", [
        DECIMALS,
        INITIAL_PRICE,
    ]);
    
    return { MockV3Aggregator };
  });
  
  export default MockV3AggregatorModule;