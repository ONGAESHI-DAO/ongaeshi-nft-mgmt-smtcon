const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixtureTalentMatch } = require("./testLib")

const date = new Date();
const matchDateInUnixTimestamp = Math.floor(date / 1000);
const payDate = date.setMonth(date.getMonth() + 3)
const payDateInUnixTimestamp = Math.floor(payDate / 1000);

describe("NFT Factory Test", function () {

    describe("Talent Match", function () {

        it("Add Talent Match", async function () {
            const { gtContract, TalenMatch, courseNFT, NFTMarketplace, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);

            await courseNFT.connect(accounts[8]).approve(NFTMarketplace.address, 1);
            await NFTMarketplace.connect(accounts[8]).createListing(courseNFT.address, 1, ethers.utils.parseEther("1"));
            console.log('1');
        });
    });
});