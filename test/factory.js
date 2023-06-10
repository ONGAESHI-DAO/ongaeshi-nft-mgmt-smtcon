const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixture } = require("./testLib")

describe("NFT Factory Test", function () {

  describe("Deploy NFT", function () {
    it("Deploy NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      const courseTokenObj = await ethers.getContractFactory("CourseToken");
      const teacherShares = [
        {
          teacher: accounts[0].address,
          shares: 4500
        },
        {
          teacher: accounts[1].address,
          shares: 3000
        },
        {
          teacher: accounts[2].address,
          shares: 2500
        }
      ]
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(1);
      await courseFactory.deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, teacherShares);
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(2);
      const deployedNFT = await courseTokenObj.attach(await courseFactory.deployedAddresses(1));
      expect(await deployedNFT.name()).to.equal("Token 1");
      expect(await deployedNFT.symbol()).to.equal("T1");
      expect(await deployedNFT.baseURI()).to.equal("test://uri1/");
      expect((await deployedNFT.price()).toString()).to.equal(ethers.utils.parseEther("1").toString());
      expect(await deployedNFT.currentSupply()).to.equal(0);
      expect(await deployedNFT.supplyLimit()).to.equal(100);
      expect(await deployedNFT.treasury()).to.equal(accounts[9].address);
      const contractTeacherShares = await deployedNFT.getSubTeachers();
      expect(contractTeacherShares.length).to.equal(3);
      expect(contractTeacherShares[0].teacher).to.equal(accounts[0].address);
      expect(contractTeacherShares[0].shares).to.equal(4500);
      expect(contractTeacherShares[1].teacher).to.equal(accounts[1].address);
      expect(contractTeacherShares[1].shares).to.equal(3000);
      expect(contractTeacherShares[2].teacher).to.equal(accounts[2].address);
      expect(contractTeacherShares[2].shares).to.equal(2500);

    });

    it("Not Admin Deploy NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await expect(
        courseFactory.connect(accounts[0]).deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, defaultTeacherShares)
      ).to.be.revertedWith("admin: wut?");
    });

    it("New Admin Deploy NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await courseFactory.setAdmin(accounts[0].address, true);
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(1);
      await courseFactory.connect(accounts[0]).deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, defaultTeacherShares)
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(2);
    });

    it("Ex Admin Deploy NFT", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);
      await courseFactory.setAdmin(accounts[0].address, true);
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(1);
      await courseFactory.connect(accounts[0]).deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, defaultTeacherShares)
      expect((await courseFactory.getAllDeployedTokens()).length).to.equal(2);
      await courseFactory.setAdmin(accounts[0].address, false);
      await expect(
        courseFactory.connect(accounts[0]).deployCourseToken("Token 2", "T2", "test://uri2/", ethers.utils.parseEther("2"), ethers.utils.parseEther("0.2"), 200, accounts[9].address, defaultTeacherShares)
      ).to.be.revertedWith("admin: wut?");
    });
  });

  describe("Factory Emit Event", function () {
    it("Emits Course Deployed Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await expect(
        courseFactory.deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, defaultTeacherShares)
      ).to.emit(courseTokenEvent, "CourseDeployed").withArgs(await courseFactory.deployedAddresses(1), owner.address);

    });

    it("Emits Teacher Added Event", async function () {
      const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixture);

      await expect(
        courseFactory.deployCourseToken("Token 1", "T1", "test://uri1/", ethers.utils.parseEther("1"), ethers.utils.parseEther("0.1"), 100, accounts[9].address, defaultTeacherShares)
      ).to.emit(courseTokenEvent, "TeacherAdded").withArgs(await courseFactory.deployedAddresses(1), anyValue);

    });
  });
});
