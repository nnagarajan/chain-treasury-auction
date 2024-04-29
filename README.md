# Treasry Bond Auction Project

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/TreasuryBondAuction.ts --network localhost --reset
npx hardhat ignition deploy ./ignition/modules/TreasuryBondAuction.ts --network sepolia --reset --verify
hh run scripts/PlaceBid.ts --network localhost
hh run scripts/PlaceBid.ts --network sepolia
hh run scripts/EndAuction.ts --network localhost
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
