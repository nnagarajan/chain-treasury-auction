# Treasury Bond Auction dApp

## Abstract:

The "Chain Treasury Auction" project is a decentralized application (dApp) designed to facilitate Treasury Bond Auctions on the blockchain. Utilizing smart contracts, this system ensures transparent and efficient auction processes for Treasury bonds, automating the settlement cycles and enhancing security. This project addresses the limitations of traditional bond auctions by leveraging blockchain technology to provide a decentralized, tamper-proof, and publicly verifiable platform.

- Treasury uses computer application called TAAPS (Treasury Automated Auction Processing System)
- Market participants use TAPS to place their bids, at the end of auction the results are posted on Treasury Department Bureau of public debt website.

## Auction Process

The Treasury auction process begins with an announcement by the Treasury that it will soon auction a specified quantity of a particular security. Immediately following the announcement of a forthcoming auction, dealers and other market participants begin to trade the new security on a when-issued basis. Secondary market transactions in outstanding Treasury securities typically settle on the business day after the trade date, when sellers deliver securities to buyers and receive payment. When-issued trading enables market participants to contract for the purchase and sale of a new security before the security has been auctioned. When-issued trading contributes to the Treasury’s goal of promoting competitive auctions by enhancing market transparency.

Auction market participant can submit either (a) one or more competetive bids, each specifying a minimum yeild at which the participant is prepared to by a specified quantity of notes or (b) a single noncompetitive bid, specifying the quantity of securities that it is prepared to buy at whatever price is paid by successful competitive bidders.

Treasury conducts note auctions in a "single-price" format i.e, same coupon rate for all accepted bids . After the close of bidding, it subtracts the noncompetitive 2bids from the total quantity of securities offered and then accepts competitive bids,in order of increasing yield,until it has exhausted the offering. The highest accepted yield is called the “stop.” Bids specifying yields below the stop are filled in full, bids above the stop are rejected, and bids at the stop are filled on a pro rata basis. All auction awards are made at a single price, computed from the yield at which the auction stopped.

## Settlement Cycles

Treasury issues the security T+5 from the auction date.

## Auction and settlement on chain

### Test Fixture

!["Fixture"](markdown/image-5.png "Fixture")

- Build the auction infrasture on the chain

### Token TSRY043024

![alt text](markdown/image-1.png)

### Bond Auction Contract

![alt text](markdown/image-2.png)

### Internal transactions

![alt text](markdown/image-3.png)

### Token Transfers

![alt text](markdown/image-4.png)

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

## Limitations

- Throughput of 12-15 TPS
- Only one bid allowed per bidder

## Challenges

### On chain

- No floating point data types
- Testing on sepolia needs ETH tokens. Faucets limit the drop to 0.01 - 0.5 ETH per day.

### Hardhat

- No etherscan like GUI to visulize the block. Ganache and Truffle project being deprecated.
- Need to pass contract address to run scripts
- Unable to retreive contract address after ignition script finishes
- Local hardhat network cannot execute the ignition when there are multiple dependent contracts in one ignition file
- When a withdrawal is initiated within the contract method, the To address is the contract address instead of Contract Owner.
- BondToken when created seperately, the owner is the contract creator and during the Auction End the trasfer doesn't complete as the balances are held in contract address the transfer doesn't complete as the
  ` balances[msg.sender] = _totalSupply;`

## Conclusion

References:

- https://www.newyorkfed.org/medialibrary/media/research/current_issues/ci11-2.html
- https://www.treasurydirect.gov/auctions/upcoming
- https://github.com/PatrickAlphaC/hardhat-fund-me-fcc
- https://github.com/brynbellomy/solidity-auction
- https://www.youtube.com/watch?v=LlgajyUiLBs
- https://ethereum.stackexchange.com/questions/83785/what-fixed-or-float-point-math-libraries-are-available-in-solidity
- https://www.nasdaq.com/articles/time-relative%3A-where-trade-speed-matters-and-where-it-doesnt-2019-05-30
