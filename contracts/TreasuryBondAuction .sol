// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import './BondToken.sol';
import './PriceConverter.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract TreasuryBondAuction {
    // Structure to represent a bid
    struct Bid {
        address bidder;
        uint yield; // Yield of the bid
        uint256 notional; // Notional amount of the bid        
        bool withdrawn; // flag indicating if the bid has been withdrawn
    }

    // Structure to represent a winner
    struct Winner {
        address bidder;
        uint qty; // amount in usd
        Bid bid;
        uint256 price;
        uint256 settlementAmount;
    }

    address public auctioneer;
    uint public auctionEndTime;
    uint public minimumBid;
    address public bondToken; // ERC20 bond token address
    BondToken private  newBond;
    uint public bondPrice; // Price of one bond in wei
    uint256 ETH_USD_PRICE = 3271;
    PriceConverter private priceConverter;

    Bid[]  private  bids;
    Winner[] private winningBids;

    // Events to emit upon various actions
    event BidPlaced(address indexed bidder, uint yield, uint notional, uint amount);
    event AuctionEnded(Winner[] winners);
    event Withdrawal(address indexed bidder, uint amount);

    // Constructor to initialize the auction and create the bond token
    constructor(
        uint _auctionDuration,
        uint _minimumBid,
        string memory _bondName,        
        uint256 _bondTotalSupply,
        uint256 _bondMaturityInYears
    ) {
        auctioneer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minimumBid = _minimumBid;
        newBond = new BondToken(_bondName, _bondName,_bondMaturityInYears,_bondTotalSupply);
        bondToken = address(newBond);
        bondPrice = 1 ether; // default bond price
        priceConverter = new PriceConverter();
    }

    // Modifier to restrict access to the auctioneer
    modifier onlyAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can perform this action");
        _;
    }

    function allBids() public view onlyAuctioneer returns(Bid[] memory){
        return bids;
    }

    function allWinningBids() public view onlyAuctioneer returns(Winner[] memory){
        return winningBids;
    }

    // Function to place a bid with yield and notional parameters
    function placeBid(uint _yield, uint _notional) public payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(_notional >= minimumBid, string.concat("Bid amount ", Strings.toString(_notional) ," is below minimum " , Strings.toString(minimumBid)));
        require(msg.sender != auctioneer, "Only non-auctioneer can perform this action");
        
        
        // Store the bid
        bids.push(Bid({
            bidder: msg.sender,
            yield: _yield,
            notional: _notional,
            withdrawn: false
        }));

        emit BidPlaced(msg.sender, _yield, _notional, msg.value);
    }

    // Function to end the auction and determine the winners
    function endAuction() public payable onlyAuctioneer {
        require(block.timestamp >= auctionEndTime || totalBidsReceived() > newBond.totalSupply(), "Auction is still ongoing");
        require(bids.length > 0, "No bids were placed");
        

        // Sort bids by Yield (ascending)
        sortBidsByYield();       
        uint256 totalNotional = newBond.totalSupply();
        uint256 totalAllocated = 0;        
        uint256 couponRate=0;
        for (uint i = 0; i < bids.length; i++) {        
            uint256 currentAllocation = 0;
            console.log("trace 111");                
            if(int256(totalNotional) - int256(totalAllocated) - int256(bids[i].notional)  >= 0){
                console.log("trace 2222");      
                currentAllocation = bids[i].notional;
                console.log(string.concat("iter ", Strings.toString(i), " ",Strings.toString(currentAllocation)));
                // Store winner
                winningBids.push( 
                    Winner({
                        bidder: bids[i].bidder,
                        qty: bids[i].notional,
                        bid: bids[i],
                        price: 0,
                        settlementAmount: 0
                    })
                );      
                console.log("trace 2222343");            
            } else {
                console.log("trace 3333");      
                currentAllocation = totalNotional - totalAllocated;
                console.log(string.concat("iter ", Strings.toString(i), " ",Strings.toString(currentAllocation)));
                winningBids.push( 
                    Winner({
                        bidder: bids[i].bidder,
                        qty: currentAllocation,
                        bid: bids[i],
                        price: 0,
                        settlementAmount:0
                    })
                );    
            }
            
            totalAllocated = totalAllocated + currentAllocation;     
            console.log("trace 1");      
            if(totalAllocated==totalNotional){
                couponRate = bids[i].yield ;
                newBond.setCouponRate(couponRate);
                break;
            }
           console.log("trace 2");      
        }

        require(totalAllocated==totalNotional, "Not enough allocation made");
        console.log("trace 3");   
        console.log(newBond.couponRate());   

        for (uint i = 0; i < winningBids.length; i++) {  
                 console.log("trace 3");    
                winningBids[i].price = newBond.derivedPrice(winningBids[i].bid.yield);
                // Withdraw funds
                if (!winningBids[i].bid.withdrawn) {
                       console.log("trace 5");   
                    //uint256 settlementAmount = priceConverter.getConversionRateWei(winningBids[i].qty * winningBids[i].price);    
                    uint256 settlementAmount = (winningBids[i].qty * winningBids[i].price * 1e10) / ETH_USD_PRICE;    
                    winningBids[i].settlementAmount = settlementAmount;
                    settlementAmount = 1 wei;                
                       console.log("trace 6");   
                    payable(winningBids[i].bid.bidder).transfer(settlementAmount);
                    bids[i].withdrawn = true;
                       console.log("trace 7");   
                    emit Withdrawal(winningBids[i].bid.bidder, settlementAmount);
                }
                   console.log("trace 8");   
                // Transfer bonds
                BondToken(bondToken).transfer(winningBids[i].bid.bidder, winningBids[i].qty);                
        }

        emit AuctionEnded(winningBids);
    }

    // Function to sort bids by yield (asc)
    function sortBidsByYield() internal {
        for (uint i = 0; i < bids.length; i++) {
            for (uint j = i + 1; j < bids.length; j++) {
                if (bids[i].yield > bids[j].yield) {
                    Bid memory temp = bids[i];
                    bids[i] = bids[j];
                    bids[j] = temp;
                }
            }
        }
    }

    function totalBidsReceived() public onlyAuctioneer view returns(uint256) {
        uint totalReceived = 0;
        for (uint i = 0; i < bids.length; i++) {
            totalReceived = totalReceived + bids[i].notional;
        }
        return totalReceived;
    }

}
