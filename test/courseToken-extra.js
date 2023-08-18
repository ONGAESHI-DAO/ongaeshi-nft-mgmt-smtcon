const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixtureWithoutGT } = require("./testLib")

const SUPPLY_MAX = 100;
const BASE_URI = "test://uri/";
const loanID_1 = "9csh28dnnairbdhwovhe";
const loanID_2 = "jd3jdbig5efn6cuiyw2r";
const loanID_3 = "6fbju4jfbg84hufv804w";
describe("NFT Test", function () {

  describe("Mint Logic", function () {

    it("Admin Mint NFT", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(1, accounts[0].address);
      expect(await courseNFT.ownerOf(1)).to.equal(accounts[0].address);
      await courseNFT.mintByAdmin(20, accounts[0].address);
      expect(await courseNFT.balanceOf(accounts[0].address)).to.equal(21);
    });

    it("Admin Mint Limit", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(SUPPLY_MAX, accounts[0].address);
      expect(await courseNFT.balanceOf(accounts[0].address)).to.equal(SUPPLY_MAX);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX);
      expect(await courseNFT.currentSupply()).to.equal(SUPPLY_MAX);
    });

    it("Admin Mint Over Limit", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await expect(courseNFT.mintByAdmin(SUPPLY_MAX + 1, accounts[0].address)).to.be.revertedWith("Mint request exceeds supply limit");
    });

  });

  describe("Misc Logic", function () {

    it("Lending", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(3, accounts[0].address);

      await courseNFT.lendToken(1, ethers.utils.toUtf8Bytes(loanID_1));
      await courseNFT.lendToken(2, ethers.utils.toUtf8Bytes(loanID_2));
      expect(ethers.utils.toUtf8String(await courseNFT.isLended(1))).to.equal(loanID_1);
      expect(ethers.utils.toUtf8String(await courseNFT.isLended(2))).to.equal(loanID_2);
      expect(await courseNFT.isLended(3)).to.equal(ethers.constants.AddressZero);
      await expect(courseNFT.lendToken(1, ethers.utils.toUtf8Bytes(loanID_2))).to.be.revertedWith("Token already lended");
      await courseNFT.returnToken(2, 0, false);
      expect(ethers.utils.toUtf8String(await courseNFT.isLended(1))).to.equal(loanID_1);
      expect(await courseNFT.isLended(2)).to.equal(ethers.constants.AddressZero);
      expect(await courseNFT.isLended(3)).to.equal(ethers.constants.AddressZero);
      await expect(courseNFT.lendToken(42, ethers.utils.toUtf8Bytes(loanID_3))).to.be.revertedWith("Token does not exists");
    });

    it("Repair by Admin", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(1, accounts[0].address);

      await courseNFT.lendToken(1, ethers.utils.toUtf8Bytes(loanID_3));
      await courseNFT.returnToken(1, ethers.utils.parseEther("5"), false);
      expect((await courseNFT.repairCost(1)).toString()).to.equal(ethers.utils.parseEther("5").toString());
      expect(await courseNFT.needRepairMap(1)).to.equal(true);

      await expect(courseNFT.lendToken(1, ethers.utils.toUtf8Bytes(loanID_3))).to.be.revertedWith("Token needs repair");
      await courseNFT.repairTokenByAdmin(1);
      expect((await courseNFT.repairCost(1)).toString()).to.equal(ethers.utils.parseEther("0").toString());
      expect(await courseNFT.needRepairMap(1)).to.equal(false);
      await courseNFT.lendToken(1, ethers.utils.toUtf8Bytes(loanID_3)); // this should work
    });

    it("Transfer by Admin", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(1, accounts[0].address);

      expect(await courseNFT.ownerOf(1)).to.equal(accounts[0].address);
      await courseNFT.adminTransferFrom(accounts[0].address, accounts[1].address, 1);
      expect(await courseNFT.ownerOf(1)).to.equal(accounts[1].address);

      await expect(courseNFT.connect(accounts[1]).transferFrom(accounts[1].address, accounts[2].address, 1)).to.be.revertedWith("Transfers have been disabled for this NFT");
    });

    it("Transfer", async function () {
      const { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureWithoutGT);
      await courseNFT.mintByAdmin(1, accounts[0].address);

      expect(await courseNFT.ownerOf(1)).to.equal(accounts[0].address);
      await expect(courseNFT.connect(accounts[0]).transferFrom(accounts[0].address, accounts[1].address, 1)).to.be.revertedWith("Transfers have been disabled for this NFT");

      await courseNFT.setTransferEnabled(true);
      await courseNFT.connect(accounts[0]).transferFrom(accounts[0].address, accounts[1].address, 1);
      expect(await courseNFT.ownerOf(1)).to.equal(accounts[1].address);
      await expect(courseNFT.adminTransferFrom(accounts[1].address, accounts[2].address, 1)).to.be.revertedWith("Transfers Enabled, use owner or approved functions");



    });


  });

});
