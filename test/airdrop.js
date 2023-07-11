const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixture } = require("./testLib")

describe("airdrop Test", function () {

    describe("airdrop", function () {

        it("airdrop", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop } = await loadFixture(deployTestEnvFixture);
            const addresses = [
                accounts[6].address,
                accounts[7].address,
                accounts[8].address,
                accounts[9].address,
                accounts[10].address,
                accounts[11].address,
                accounts[12].address,
                accounts[13].address,
                accounts[14].address,
                accounts[15].address,
                accounts[16].address,
                accounts[17].address,
                accounts[18].address
            ]
            const amounts = [
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("2"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("3"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("3"),
                ethers.utils.parseEther("1")
            ]
            await gtContract.approve(airdrop.address, ethers.utils.parseEther("18"));
            await airdrop.airdrop(addresses, amounts);
            for (let i = 0; i < addresses.length; i++) {
                expect((await gtContract.balanceOf(addresses[i])).toString()).to.equal(amounts[i].toString());
            }
        });
    });

});
