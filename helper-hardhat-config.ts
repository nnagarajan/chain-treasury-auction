export interface networkConfigItem {
    ethUsdPriceFeed?: string
    blockConfirmations?: number
  }
  
  export interface networkConfigInfo {
    [key: string]: networkConfigItem
  }
  
  export const networkConfig: networkConfigInfo = {
    localhost: {},
    hardhat: {},
    // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
    // Default one is ETH/USD contract on Kovan
    sepolia: {
      ethUsdPriceFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
      blockConfirmations: 6,
    },
  }
  
  export const developmentChains = ["hardhat", "localhost"]