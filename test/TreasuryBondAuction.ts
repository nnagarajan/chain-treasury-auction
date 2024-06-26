import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

import TreasuryBondAuction from "../ignition/modules/TreasuryBondAuction";
import { BondToken } from "../typechain-types";

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
    const { treasuryBondAuction } = await hre.ignition.deploy(TreasuryBondAuction);
    const [tokenOwner, otherAccount1, otherAccount2, otherAccount3] = await hre.ethers.getSigners();

    return { treasuryBondAuction, tokenOwner, otherAccount1, otherAccount2, otherAccount3 };
  }

  describe("Place Bid", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount1 } = await loadFixture(deployTokenFixture);
      await treasuryBondAuction.connect(otherAccount1).placeBid(819, 1, { value: hre.ethers.parseEther("0.0005") });
      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(1);
      expect(await hre.ethers.provider.getBalance(treasuryBondAuction)).to.equal(500000000000000);
    });
  });

  describe("Place Multiple Bids", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount1, otherAccount2, otherAccount3 } = await loadFixture(
        deployTokenFixture
      );

      await treasuryBondAuction.connect(otherAccount1).placeBid(819, 1, { value: hre.ethers.parseEther("0.0005") });
      await treasuryBondAuction.connect(otherAccount2).placeBid(821, 2, { value: hre.ethers.parseEther("0.0010") });
      await treasuryBondAuction.connect(otherAccount3).placeBid(822, 1, { value: hre.ethers.parseEther("0.0005") });
      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(4);
      expect(await hre.ethers.provider.getBalance(treasuryBondAuction)).to.equal((0.0005 + 0.001 + 0.0005) * 1e18);
    });
  });

  describe("Cancel Bid And Release All Funds", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount1, otherAccount2, otherAccount3 } = await loadFixture(
        deployTokenFixture
      );
      console.log("Contract Balance: " + (await hre.ethers.provider.getBalance(treasuryBondAuction)));
      console.log("Bank 1 Balance: " + (await hre.ethers.provider.getBalance(otherAccount1)));
      console.log("Bank 2 Balance: " + (await hre.ethers.provider.getBalance(otherAccount2)));
      console.log("Bank 3 Balance: " + (await hre.ethers.provider.getBalance(otherAccount3)));
      await treasuryBondAuction.connect(otherAccount1).placeBid(819, 1, { value: hre.ethers.parseEther("0.0005") });
      await treasuryBondAuction.connect(otherAccount2).placeBid(821, 2, { value: hre.ethers.parseEther("0.0010") });
      await treasuryBondAuction.connect(otherAccount3).placeBid(822, 1, { value: hre.ethers.parseEther("0.0005") });
      console.log("Contract Balance: " + (await hre.ethers.provider.getBalance(treasuryBondAuction)));
      console.log("Bank 1 Balance: " + (await hre.ethers.provider.getBalance(otherAccount1)));
      console.log("Bank 2 Balance: " + (await hre.ethers.provider.getBalance(otherAccount2)));
      console.log("Bank 3 Balance: " + (await hre.ethers.provider.getBalance(otherAccount3)));
      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(4);
      expect(await hre.ethers.provider.getBalance(treasuryBondAuction)).to.equal((0.0005 + 0.001 + 0.0005) * 1e18);
      expect(await treasuryBondAuction.connect(tokenOwner).cancelAndReleaseAllFunds());
      expect(await hre.ethers.provider.getBalance(treasuryBondAuction)).to.equal(0);
      console.log("Contract Balance: " + (await hre.ethers.provider.getBalance(treasuryBondAuction)));
      console.log("Bank 1 Balance: " + (await hre.ethers.provider.getBalance(otherAccount1)));
      console.log("Bank 2 Balance: " + (await hre.ethers.provider.getBalance(otherAccount2)));
      console.log("Bank 3 Balance: " + (await hre.ethers.provider.getBalance(otherAccount3)));
    });
  });

  describe("Complete the bid", function () {
    it("Should set the right totalBidsReceived", async function () {
      const { treasuryBondAuction, tokenOwner, otherAccount1, otherAccount2, otherAccount3 } = await loadFixture(
        deployTokenFixture
      );

      expect(await hre.ethers.provider.getBalance(otherAccount1)).to.equal(10000000000000000000000n);
      expect(await hre.ethers.provider.getBalance(otherAccount2)).to.equal(10000000000000000000000n);
      expect(await hre.ethers.provider.getBalance(otherAccount3)).to.equal(10000000000000000000000n);
      await treasuryBondAuction
        .connect(otherAccount1)
        .placeBid(819, 30, { value: hre.ethers.parseEther((0.00005 * 3).toFixed(7).toString()) });
      await treasuryBondAuction
        .connect(otherAccount2)
        .placeBid(823, 25, { value: hre.ethers.parseEther((0.00005 * 3.5).toFixed(7).toString()) });
      await treasuryBondAuction
        .connect(otherAccount3)
        .placeBid(822, 20, { value: hre.ethers.parseEther((0.00005 * 2).toFixed(7).toString()) });
      // expect(await hre.ethers.provider.getBalance(otherAccount1)).to.equal(9999999306133647832547n);
      // expect(await hre.ethers.provider.getBalance(otherAccount2)).to.equal(9999998948803649743179n);
      // expect(await hre.ethers.provider.getBalance(otherAccount3)).to.equal(9999999360667459116735n);

      expect(await treasuryBondAuction.totalBidsReceived()).to.equal(75);

      const createdBondToken: BondToken = (await hre.ethers.getContractFactory("BondToken")).attach(
        await treasuryBondAuction.createdBondToken()
      );

      expect(await createdBondToken.findBalance(treasuryBondAuction.getAddress())).to.equal(50);

      expect(await hre.ethers.provider.getBalance(treasuryBondAuction)).to.equal((3 + 3.5 + 2) * 0.00005 * 1e18);

      console.log("Contract Balance: " + (await hre.ethers.provider.getBalance(treasuryBondAuction)));
      console.log("Bank 1 Balance: " + (await hre.ethers.provider.getBalance(otherAccount1)));
      console.log("Bank 2 Balance: " + (await hre.ethers.provider.getBalance(otherAccount2)));
      console.log("Bank 3 Balance: " + (await hre.ethers.provider.getBalance(otherAccount3)));
      await treasuryBondAuction.connect(tokenOwner).endAuction();

      console.log("Contract Balance: " + (await hre.ethers.provider.getBalance(treasuryBondAuction)));
      console.log("Bank 1 Balance: " + (await hre.ethers.provider.getBalance(otherAccount1)));
      console.log("Bank 2 Balance: " + (await hre.ethers.provider.getBalance(otherAccount2)));
      console.log("Bank 3 Balance: " + (await hre.ethers.provider.getBalance(otherAccount3)));

      expect(await createdBondToken.findBalance(otherAccount1)).to.equal(30);
      expect(await createdBondToken.findBalance(otherAccount3)).to.equal(20);
      expect(await createdBondToken.findBalance(treasuryBondAuction.getAddress())).to.equal(0);
    });
  });
});
