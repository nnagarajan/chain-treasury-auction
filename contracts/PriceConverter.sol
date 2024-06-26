// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED
 * VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

/**
 * If you are reading data feeds on L2 networks, you must
 * check the latest answer from the L2 Sequencer Uptime
 * Feed to ensure that the data is accurate in the event
 * of an L2 sequencer outage. See the
 * https://docs.chain.link/data-feeds/l2-sequencer-feeds
 * page for details.
 */

contract PriceConverter {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Sepolia
     * Aggregator: BTC/USD
     * Address: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     */
    constructor(AggregatorV3Interface _priceFeed) {
        priceFeed = _priceFeed;
    }

    /**
     * Returns the latest answer.
     */
    function getPrice() public view returns (uint256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getVersion() internal view returns (uint256) {
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getConversionRateWei(uint256 usdAmount) public view returns (uint256) {
        uint256 ethPrice = getConversionRate(1);
        uint256 amountInWei = Math.ceilDiv(usdAmount * 1e18, ethPrice);
        return amountInWei;
    }

    function getConversionRateEth(uint256 usdAmount) public view returns (uint256) {
        uint256 ethPrice = getConversionRate(1);
        uint256 amountInWei = (usdAmount * 1e18) / ethPrice;
        return amountInWei;
    }
}
