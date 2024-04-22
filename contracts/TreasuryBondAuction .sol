// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import './BondToken.sol';

contract TreasuryBondAuction {
    // Structure to represent a bid
    struct Bid {
        address bidder;
        uint yield; // Yield of the bid
        uint notional; // Notional amount of the bid
        uint amount; // amount in wei
        bool withdrawn; // flag indicating if the bid has been withdrawn
    }

    // Structure to represent a winner
    struct Winner {
        address bidder;
        uint amount; // amount in wei
    }

    address public auctioneer;
    uint public auctionEndTime;
    uint public minimumBid;
    address public bondToken; // ERC20 bond token address
    uint public bondPrice; // Price of one bond in wei

    Bid[] private bids;
    Winner[] public winningBids;

    // Events to emit upon various actions
    event BidPlaced(address indexed bidder, uint yield, uint notional, uint amount);
    event AuctionEnded(Winner[] winners);
    event Withdrawal(address indexed bidder, uint amount);

    // Constructor to initialize the auction and create the bond token
    constructor(
        uint _auctionDuration,
        uint _minimumBid,
        string memory _bondName,
        string memory _bondSymbol,
        uint256 _bondTotalSupply
    ) {
        auctioneer = msg.sender;
        auctionEndTime = block.timestamp + _auctionDuration;
        minimumBid = _minimumBid;
        BondToken newBond = new BondToken(_bondName, _bondSymbol, _bondTotalSupply);
        bondToken = address(newBond);
        bondPrice = 1 ether; // default bond price
    }

    // Modifier to restrict access to the auctioneer
    modifier onlyAuctioneer() {
        require(msg.sender == auctioneer, "Only auctioneer can perform this action");
        _;
    }

    // Function to place a bid with yield and notional parameters
    function placeBid(uint _yield, uint _notional) public payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value >= minimumBid, "Bid amount is below minimum");

        // Store the bid
        bids.push(Bid({
            bidder: msg.sender,
            yield: _yield,
            notional: _notional,
            amount: msg.value,
            withdrawn: false
        }));

        emit BidPlaced(msg.sender, _yield, _notional, msg.value);
    }

    // Function to end the auction and determine the winners
    function endAuction() public onlyAuctioneer {
        require(block.timestamp >= auctionEndTime, "Auction is still ongoing");
        require(bids.length > 0, "No bids were placed");

        // Sort bids by amount (descending)
        sortBids();

        // Withdraw funds and transfer bonds to the winners
        for (uint i = 0; i < 3 && i < bids.length; i++) {
            // Withdraw funds
            if (!bids[i].withdrawn) {
                payable(bids[i].bidder).transfer(bids[i].amount);
                bids[i].withdrawn = true;
                emit Withdrawal(bids[i].bidder, bids[i].amount);
            }

            // Transfer bonds
            BondToken(bondToken).transfer(bids[i].bidder, bids[i].notional);

            // Store winner
            winningBids[i] = Winner({
                bidder: bids[i].bidder,
                amount: bids[i].amount
            });
        }

        emit AuctionEnded(winningBids);
    }

    // Function to sort bids by amount (descending)
    function sortBids() internal {
        for (uint i = 0; i < bids.length; i++) {
            for (uint j = i + 1; j < bids.length; j++) {
                if (bids[i].amount < bids[j].amount) {
                    Bid memory temp = bids[i];
                    bids[i] = bids[j];
                    bids[j] = temp;
                }
            }
        }
    }
}
