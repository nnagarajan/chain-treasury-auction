import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

import TreasuryBondAuction from "../ignition/modules/TreasuryBondAuction";

describe("TreasuryBondAuction", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFixture() {
    /*
     Hardhat Ignition adds an `ignition` object to the Hardhat Runtime Environment
     that exposes a `deploy()` method. The `deploy()` method takes an Ignition
     module and returns the results of the Ignition module, where each
     returned future has been converted into an *ethers* contract instance.
    */
    const { treasuryBondAuction } = await hre.ignition.deploy(
      TreasuryBondAuction
    );

    const [tokenOwner, otherAccount] = await hre.ethers.getSigners();

    return { treasuryBondAuction, tokenOwner, otherAccount };
  }

  describe("Place Bid", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount } =
        await loadFixture(deployTokenFixture);

      await treasuryBondAuction.connect(otherAccount).placeBid(8, 50);
      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(50);
    });
  });

  describe("Place Multiple Bids", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount } =
        await loadFixture(deployTokenFixture);

      await treasuryBondAuction.connect(otherAccount).placeBid(8, 50);
      await treasuryBondAuction.connect(otherAccount).placeBid(5, 100);
      await treasuryBondAuction.connect(otherAccount).placeBid(9, 50);
      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(200);
    });
  });
});
