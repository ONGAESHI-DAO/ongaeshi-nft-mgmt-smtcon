const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixture } = require("./testLib")

const SUPPLY_MAX = 100;
describe("NFT Test", function () {

  describe("Mint Logic", function () {
    it("Mint NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await gtContract.connect(accounts[4]).approve(courseNFT.address, ethers.utils.parseEther("11"));
      const balBefore = await gtContract.balanceOf(accounts[4].address);

      await courseNFT.connect(accounts[4]).mint(1);
      expect(await courseNFT.ownerOf(0)).to.equal(accounts[4].address);  // Check owner of nft token id 0 is minter
      await courseNFT.connect(accounts[4]).mint(10);
      expect(await courseNFT.balanceOf(accounts[4].address)).to.equal(11);

      const balAfter = await gtContract.balanceOf(accounts[4].address);
      expect(balBefore.sub(balAfter).toString()).to.equal(ethers.utils.parseEther("11").toString())
    });

    it("Admin Mint NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await courseNFT.connect(owner).mintByAdmin(1, accounts[0].address);
      expect(await courseNFT.ownerOf(0)).to.equal(accounts[0].address);
      await courseNFT.connect(owner).mintByAdmin(20, accounts[0].address);
      expect(await courseNFT.balanceOf(accounts[0].address)).to.equal(21);
    });

    it("Mint To Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await gtContract.connect(accounts[0]).approve(courseNFT.address, ethers.utils.parseEther("100"));
      await courseNFT.connect(accounts[0]).mint(SUPPLY_MAX);
      expect(await courseNFT.balanceOf(accounts[0].address)).to.equal(SUPPLY_MAX);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX);
      expect(await courseNFT.currentSupply()).to.equal(SUPPLY_MAX);

    });

    it("Mint Over Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await gtContract.connect(accounts[0]).approve(courseNFT.address, ethers.utils.parseEther("101"));
      await expect(courseNFT.connect(accounts[0]).mint(SUPPLY_MAX + 1)).to.be.revertedWith("Mint request exceeds supply limit");
    });

    it("Admin Mint Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await courseNFT.connect(owner).mintByAdmin(SUPPLY_MAX, accounts[0].address);
      expect(await courseNFT.balanceOf(accounts[0].address)).to.equal(SUPPLY_MAX);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX);
      expect(await courseNFT.currentSupply()).to.equal(SUPPLY_MAX);
    });

    it("Admin Mint Over Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await expect(courseNFT.connect(owner).mintByAdmin(SUPPLY_MAX + 1, accounts[0].address)).to.be.revertedWith("Mint request exceeds supply limit");
    });

    it("Increase Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await courseNFT.increaseSupplyLimit(20);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX + 20);
      await courseNFT.mintByAdmin(SUPPLY_MAX + 20, accounts[0].address);
      await expect(courseNFT.mintByAdmin(1, accounts[0].address)).to.be.revertedWith("Mint request exceeds supply limit");
      await courseNFT.increaseSupplyLimit(20);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX + 40);
      await courseNFT.mintByAdmin(1, accounts[0].address); // call does not revert
    });

    it("Decrease Limit", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await courseNFT.decreaseSupplyLimit(20);
      expect(await courseNFT.supplyLimit()).to.equal(SUPPLY_MAX - 20);
      await expect(courseNFT.mintByAdmin(SUPPLY_MAX, accounts[0].address)).to.be.revertedWith("Mint request exceeds supply limit");
    });

    it("Decrease Limit Reverts", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await expect(courseNFT.decreaseSupplyLimit(SUPPLY_MAX + 1)).to.be.revertedWith("Input greater than supplyLimit");
      await courseNFT.mintByAdmin(SUPPLY_MAX - 50, accounts[0].address);
      await expect(courseNFT.decreaseSupplyLimit(51)).to.be.revertedWith("Request would decrease supply limit lower than current Supply");
    });

    it("Change Price", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      expect((await courseNFT.price()).toString()).to.equal(ethers.utils.parseEther("1").toString());
      await courseNFT.setPrice(ethers.utils.parseEther("2"));
      expect((await courseNFT.price()).toString()).to.equal(ethers.utils.parseEther("2").toString());

      await gtContract.connect(accounts[4]).approve(courseNFT.address, ethers.utils.parseEther("20"));
      const balBefore = await gtContract.balanceOf(accounts[4].address);
      await courseNFT.connect(accounts[4]).mint(10);
      expect(await courseNFT.balanceOf(accounts[4].address)).to.equal(10);
      const balAfter = await gtContract.balanceOf(accounts[4].address);
      expect(balBefore.sub(balAfter).toString()).to.equal(ethers.utils.parseEther("20").toString())

    });

    it("Teacher Shares", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      expect((await courseNFT.price()).toString()).to.equal(ethers.utils.parseEther("1").toString());

      await gtContract.connect(accounts[4]).approve(courseNFT.address, ethers.utils.parseEther("10"));
      const balBefore0 = await gtContract.balanceOf(accounts[0].address);
      const balBefore1 = await gtContract.balanceOf(accounts[1].address);
      const balBefore2 = await gtContract.balanceOf(accounts[2].address);

      await courseNFT.connect(accounts[4]).mint(10);
      const balAfter0 = await gtContract.balanceOf(accounts[0].address);
      const balAfter1 = await gtContract.balanceOf(accounts[1].address);
      const balAfter2 = await gtContract.balanceOf(accounts[2].address);

      expect(balAfter0.sub(balBefore0).toString()).to.equal(ethers.utils.parseEther("5").toString());
      expect(balAfter1.sub(balBefore1).toString()).to.equal(ethers.utils.parseEther("4").toString());
      expect(balAfter2.sub(balBefore2).toString()).to.equal(ethers.utils.parseEther("1").toString());

    });


  });

  describe("NFT Emit Event", function () {
    it("Mint Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await gtContract.connect(accounts[4]).approve(courseNFT.address, ethers.utils.parseEther("1"));
      await expect(
        courseNFT.connect(accounts[4]).mint(1)
      ).to.emit(courseTokenEvent, "TokenMint");
      await expect(
        courseNFT.mintByAdmin(1, accounts[0].address)
      ).to.emit(courseTokenEvent, "TokenMint");
    });

    it("Price Updated Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await expect(
        courseNFT.setPrice(ethers.utils.parseEther("2"))
      ).to.emit(courseTokenEvent, "PriceUpdated");
    });

    it("Supply Limit Updated Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await expect(
        courseNFT.increaseSupplyLimit(1)
      ).to.emit(courseTokenEvent, "SupplyLimitUpdated");

      await expect(
        courseNFT.decreaseSupplyLimit(2)
      ).to.emit(courseTokenEvent, "SupplyLimitUpdated");
    });

    it("Teacher Paid Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await gtContract.connect(accounts[4]).approve(courseNFT.address, ethers.utils.parseEther("1"));
      await expect(
        courseNFT.connect(accounts[4]).mint(1)
      ).to.emit(courseTokenEvent, "TeacherPaid");
    });


  });
});
