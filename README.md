# Treasry Bond Auction Project

Contract Hash: 0xEFE2eC15ed01ffECb037792B3601F5645ae89c9a
https://sepolia.etherscan.io/address/0xEFE2eC15ed01ffECb037792B3601F5645ae89c9a

Contract Hash: 0x82D815b5b245c53aDab9F80dA9cF14F3058399d8
https://sepolia.etherscan.io/address/0x82D815b5b245c53aDab9F80dA9cF14F3058399d8

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/TreasuryBondAuction.ts --network localhost --reset

hh run scripts/PlaceBid.ts --network localhost

npx hardhat ignition deploy ./ignition/modules/TreasuryBondAuction.ts --network sepolia --reset --verify
hh run scripts/PlaceBid.ts --network sepolia
hh run scripts/EndAuction.ts --network sepolia
hh run scripts/CancelAuction.ts --network sepolia
```

```r
findPriceInWei<-function(qty,price,factor=100,ethUsd=3308){
   ((qty*price) * 1e18)/ethUsd/factor
}

derivedPrice<-function(bidYield,maturityInYears,couponRate){
    r = (100 + bidYield) * maturityInYears;
    return ((couponRate * 100) / bidYield) * 100 * (10000 - (1e24 / r)) + 1e28 / r;
}

derivedPrice<-function(bidYield,maturityInYears,couponRate){
  r = (10000 + bidYield) ^ maturityInYears;
  a= ((couponRate * 100) / bidYield) * 100 * (10000 - (1e44 / r))
  b= 1e48 / r
  return( a + b );
}

findPriceInWei<-function(qty,price,factor=10000,ethUsd=3308){
  ((qty*price) * 1e18)/ethUsd/factor
}

derivedPrice<-function(bidYield,maturityInYears,couponRate){
  r = (1 + bidYield/100) ^ maturityInYears;
  a= (couponRate / bidYield) * 100 * (1 - (1 / r))
  b= 100 / r
  return( a + b );
}
```
