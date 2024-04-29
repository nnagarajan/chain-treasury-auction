// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./BondToken.sol";
import "./PriceConverter.sol";
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

    uint public auctionEndTime;
    uint public minimumBid;
    uint private ethFactor;
    uint public bondPrice; // Price of one bond in wei

    address public auctioneer;

    PriceConverter private priceConverter;
    BondToken public newBond;

    mapping(address => uint256) public fundsByBidder;

    Bid[] private bids;
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
        uint256 _bondMaturityInYears,
        address _priceFeed,
        uint _ethFactor
    ) {
        auctioneer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minimumBid = _minimumBid;
        newBond = new BondToken(_bondName, _bondName, _bondMaturityInYears, _bondTotalSupply);
        bondPrice = 1 ether; // default bond price
        priceConverter = new PriceConverter(AggregatorV3Interface(_priceFeed));
        ethFactor = _ethFactor;
    }

    // Modifier to restrict access to the auctioneer
    modifier onlyAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can perform this action");
        _;
    }

    function allBids() public view onlyAuctioneer returns (Bid[] memory) {
        return bids;
    }

    function allWinningBids() public view onlyAuctioneer returns (Winner[] memory) {
        return winningBids;
    }

    // Function to place a bid with yield and notional parameters
    function placeBid(uint _yield, uint _notional) public payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(fundsByBidder[msg.sender] == 0, "You have already bid");
        require(
            _notional >= minimumBid,
            string.concat(
                "Bid amount ",
                Strings.toString(_notional),
                " is below minimum ",
                Strings.toString(minimumBid)
            )
        );

        require(msg.sender != auctioneer, "Only non-auctioneer can perform this action");

        uint256 ethValueOfNotional = priceConverter.getConversionRateWei(_notional * 150) / ethFactor;

        console.log(
            string.concat(
                "Bid amount in Wei ",
                Strings.toString(ethValueOfNotional),
                " transferred in Wei ",
                Strings.toString(msg.value)
            )
        );

        require(
            msg.value > 0 && msg.value >= ethValueOfNotional,
            string.concat(
                "Bid amount should be atleast ",
                Strings.toString(ethValueOfNotional),
                " transferred ",
                Strings.toString(msg.value)
            )
        );

        // store the funds received
        fundsByBidder[msg.sender] = msg.value;
        // Store the bid
        bids.push(Bid({bidder: msg.sender, yield: _yield, notional: _notional, withdrawn: false}));

        emit BidPlaced(msg.sender, _yield, _notional, msg.value);
    }

    // Function to end the auction and determine the winners
    function endAuction() public onlyAuctioneer {
        require(
            block.timestamp >= auctionEndTime || totalBidsReceived() > newBond.totalSupply(),
            "Auction is still ongoing"
        );
        require(bids.length > 0, "No bids were placed");

        // Sort bids by Yield (ascending)
        sortBidsByYield();
        uint256 totalNotional = newBond.totalSupply();
        uint256 totalAllocated = 0;
        uint256 couponRate = 0;
        for (uint i = 0; i < bids.length; i++) {
            uint256 currentAllocation = 0;
            if (int256(totalNotional) - int256(totalAllocated) - int256(bids[i].notional) >= 0) {
                currentAllocation = bids[i].notional;
                console.log(
                    string.concat(
                        "Iteration ",
                        Strings.toString(i),
                        " currentAllocation ",
                        Strings.toString(currentAllocation),
                        " Yield ",
                        Strings.toString(bids[i].yield)
                    )
                );
                // Store winner
                winningBids.push(
                    Winner({bidder: bids[i].bidder, qty: bids[i].notional, bid: bids[i], price: 0, settlementAmount: 0})
                );
            } else {
                currentAllocation = totalNotional - totalAllocated;
                winningBids.push(
                    Winner({
                        bidder: bids[i].bidder,
                        qty: currentAllocation,
                        bid: bids[i],
                        price: 0,
                        settlementAmount: 0
                    })
                );
            }

            totalAllocated = totalAllocated + currentAllocation;
            if (totalAllocated == totalNotional) {
                couponRate = bids[i].yield;
                newBond.setCouponRate(couponRate);
                break;
            }
        }

        require(totalAllocated == totalNotional, "Not enough allocation made");
        console.log(string.concat("Applied Coupon Rate : ", Strings.toString(newBond.couponRate())));

        for (uint i = 0; i < winningBids.length; i++) {
            winningBids[i].price = newBond.derivedPrice(winningBids[i].bid.yield);
            console.log(
                string.concat(
                    "Winning Bid at winnerIndex : ",
                    Strings.toString(i),
                    " price ",
                    Strings.toString(winningBids[i].price)
                )
            );
            // Withdraw funds
            if (!winningBids[i].bid.withdrawn) {
                uint256 settlementAmount = priceConverter.getConversionRateWei(
                    winningBids[i].qty * winningBids[i].price
                ) / ethFactor;
                winningBids[i].settlementAmount = settlementAmount;
                console.log(
                    string.concat(
                        "SettlementAmount at winnerIndex : ",
                        Strings.toString(i),
                        " settlementAmount ",
                        Strings.toString(settlementAmount)
                    )
                );
                uint256 extraAmountInWei = fundsByBidder[winningBids[i].bid.bidder] - settlementAmount;
                if (extraAmountInWei > 0) payable(winningBids[i].bid.bidder).transfer(extraAmountInWei);
                bids[i].withdrawn = true;
                emit Withdrawal(winningBids[i].bid.bidder, settlementAmount);
            }
            // Transfer bonds
            newBond.transfer(winningBids[i].bid.bidder, winningBids[i].qty);
        }

        //Return bid amount to losing bidders
        for (uint i = 0; i < bids.length; i++) {
            if (!bids[i].withdrawn) {
                payable(bids[i].bidder).transfer(fundsByBidder[bids[i].bidder]);
            }
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

    function totalBidsReceived() public view onlyAuctioneer returns (uint256) {
        uint totalReceived = 0;
        for (uint i = 0; i < bids.length; i++) {
            totalReceived = totalReceived + bids[i].notional;
        }
        return totalReceived;
    }

    function createdBondToken() public view returns (BondToken) {
        return newBond;
    }

    function addressCreatedBondToken() public view returns (address) {
        return address(newBond);
    }

    function cancelBidAndRefundAll() public onlyAuctioneer {
        // Transfer Money to Bidders
        for (uint i = 0; i < bids.length; i++) {
            payable(bids[i].bidder).transfer(fundsByBidder[bids[i].bidder]);
        }
        // End Bid
        auctionEndTime = block.timestamp;
    }
}
