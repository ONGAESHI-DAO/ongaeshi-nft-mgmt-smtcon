const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const { deployTestEnvFixture } = require("./testLib")
  
  describe("Lock", function () {
  
    describe("Deployment", function () {
      it("Deploy correctly", async function () {
        const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts} = await loadFixture(deployTestEnvFixture);
  
        console.log(gtContract.address, courseNFT.address, TalenMatch.address, courseTokenEvent.address, owner.address);
      });
    });
  });
  