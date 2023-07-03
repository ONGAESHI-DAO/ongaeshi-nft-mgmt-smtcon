const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixtureTalentMatch } = require("./testLib")

describe("NFT Factory Test", function () {

    describe("Talent Match", function () {

        it("Add Talent Match", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));

            const data = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data.coach).to.equal(accounts[6].address);
            expect(data.sponsor).to.equal(accounts[7].address);
            expect(data.teacher).to.equal(accounts[8].address);
            expect(data.nftAddress).to.equal(courseNFT.address);
            expect(data.tokenId).to.equal(0);
        });

        it("Update Talent Match", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            const data = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data.coach).to.equal(accounts[6].address);
            expect(data.sponsor).to.equal(accounts[7].address);
            expect(data.teacher).to.equal(accounts[8].address);
            expect(data.nftAddress).to.equal(courseNFT.address);
            expect(data.tokenId).to.equal(0);

            await TalenMatch.updateTalentMatch(accounts[5].address, accounts[10].address, accounts[11].address, accounts[12].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            const data2 = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data2.coach).to.equal(accounts[10].address);
            expect(data2.sponsor).to.equal(accounts[11].address);
            expect(data2.teacher).to.equal(accounts[12].address);
            expect(data2.nftAddress).to.equal(courseNFT.address);
            expect(data2.tokenId).to.equal(0);

            await expect(
                TalenMatch.updateTalentMatch(accounts[6].address, accounts[10].address, accounts[11].address, accounts[12].address, courseNFT.address, 1, ethers.utils.parseEther("100"))
            ).to.be.revertedWith("match data does not exists");

        });

        it("Delete Talent Match", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            const data = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data.coach).to.equal(accounts[6].address);
            expect(data.sponsor).to.equal(accounts[7].address);
            expect(data.teacher).to.equal(accounts[8].address);
            expect(data.nftAddress).to.equal(courseNFT.address);
            expect(data.tokenId).to.equal(0);

            await TalenMatch.deleteTalentMatch(accounts[5].address);
            const data2 = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data2.coach).to.equal(ethers.constants.AddressZero);
            expect(data2.sponsor).to.equal(ethers.constants.AddressZero);
            expect(data2.teacher).to.equal(ethers.constants.AddressZero);
            expect(data2.nftAddress).to.equal(ethers.constants.AddressZero);
            expect(data2.tokenId).to.equal(0);

            await expect(
                TalenMatch.deleteTalentMatch(accounts[5].address)
            ).to.be.revertedWith("match data does not exists");
        });

        it("Confirm Talent Match", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));

            const balAdmin = await gtContract.balanceOf(owner.address);
            const bal0 = await gtContract.balanceOf(accounts[0].address); //teacher
            const bal1 = await gtContract.balanceOf(accounts[1].address); //teacher
            const bal2 = await gtContract.balanceOf(accounts[2].address); //teacher

            await gtContract.approve(TalenMatch.address, ethers.utils.parseEther("100"));
            await TalenMatch.confirmTalentMatch(accounts[5].address, ethers.utils.parseEther("100"));

            const balAdminAfter = await gtContract.balanceOf(owner.address);
            const bal0After = await gtContract.balanceOf(accounts[0].address); //teacher
            const bal1After = await gtContract.balanceOf(accounts[1].address); //teacher
            const bal2After = await gtContract.balanceOf(accounts[2].address); //teacher
            const balTalent = await gtContract.balanceOf(accounts[5].address);
            const balCoach = await gtContract.balanceOf(accounts[6].address);
            const balSponsor = await gtContract.balanceOf(accounts[7].address);

            expect(balAdmin.sub(balAdminAfter).toString()).to.equal(ethers.utils.parseEther("100").toString());
            expect(bal0After.sub(bal0)).to.equal(ethers.utils.parseEther("10").toString());
            expect(bal1After.sub(bal1)).to.equal(ethers.utils.parseEther("8").toString());
            expect(bal2After.sub(bal2)).to.equal(ethers.utils.parseEther("2").toString());
            expect(balTalent).to.equal(ethers.utils.parseEther("20").toString());
            expect(balCoach).to.equal(ethers.utils.parseEther("30").toString());
            expect(balSponsor).to.equal(ethers.utils.parseEther("30").toString());

            const data2 = await TalenMatch.matchRegistry(accounts[5].address)
            expect(data2.coach).to.equal(ethers.constants.AddressZero);
            expect(data2.sponsor).to.equal(ethers.constants.AddressZero);
            expect(data2.teacher).to.equal(ethers.constants.AddressZero);
            expect(data2.nftAddress).to.equal(ethers.constants.AddressZero);
            expect(data2.tokenId).to.equal(0);

            await expect(
                TalenMatch.confirmTalentMatch(accounts[5].address, ethers.utils.parseEther("100"))
            ).to.be.revertedWith("match does not exist");
        });

        it("Update Share Scheme", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            expect(await TalenMatch.talentShare()).to.equal(2000);
            expect(await TalenMatch.coachShare()).to.equal(3000);
            expect(await TalenMatch.sponsorShare()).to.equal(3000);
            expect(await TalenMatch.teacherShare()).to.equal(2000);

            await TalenMatch.updateShareScheme(1000, 2000, 3000, 4000);

            expect(await TalenMatch.talentShare()).to.equal(1000);
            expect(await TalenMatch.coachShare()).to.equal(2000);
            expect(await TalenMatch.sponsorShare()).to.equal(3000);
            expect(await TalenMatch.teacherShare()).to.equal(4000);

            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));

            const bal0 = await gtContract.balanceOf(accounts[0].address); //teacher
            const bal1 = await gtContract.balanceOf(accounts[1].address); //teacher
            const bal2 = await gtContract.balanceOf(accounts[2].address); //teacher

            await gtContract.approve(TalenMatch.address, ethers.utils.parseEther("100"));
            await TalenMatch.confirmTalentMatch(accounts[5].address, ethers.utils.parseEther("100"));

            const bal0After = await gtContract.balanceOf(accounts[0].address); //teacher
            const bal1After = await gtContract.balanceOf(accounts[1].address); //teacher
            const bal2After = await gtContract.balanceOf(accounts[2].address); //teacher
            const balTalent = await gtContract.balanceOf(accounts[5].address);
            const balCoach = await gtContract.balanceOf(accounts[6].address);
            const balSponsor = await gtContract.balanceOf(accounts[7].address);

            expect(bal0After.sub(bal0)).to.equal(ethers.utils.parseEther("20").toString());
            expect(bal1After.sub(bal1)).to.equal(ethers.utils.parseEther("16").toString());
            expect(bal2After.sub(bal2)).to.equal(ethers.utils.parseEther("4").toString());
            expect(balTalent).to.equal(ethers.utils.parseEther("10").toString());
            expect(balCoach).to.equal(ethers.utils.parseEther("20").toString());
            expect(balSponsor).to.equal(ethers.utils.parseEther("30").toString())

            await expect(
                TalenMatch.updateShareScheme(1000, 2001, 3000, 4000)
            ).to.be.revertedWith("Shares do not sum to 10000");
        });

        it("Admin", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));

            await expect(
                TalenMatch.connect(accounts[0]).updateShareScheme(1000, 2000, 3000, 4000)
            ).to.be.revertedWith("admin: wut?");
            await expect(
                TalenMatch.connect(accounts[0]).addTalentMatch(accounts[11].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"))
            ).to.be.revertedWith("admin: wut?");
            await expect(
                TalenMatch.connect(accounts[0]).updateTalentMatch(accounts[5].address, accounts[10].address, accounts[11].address, accounts[12].address, courseNFT.address, 0, ethers.utils.parseEther("100"))
            ).to.be.revertedWith("admin: wut?");
            await expect(
                TalenMatch.connect(accounts[0]).deleteTalentMatch(accounts[5].address)
            ).to.be.revertedWith("admin: wut?");
            await expect(
                TalenMatch.connect(accounts[0]).confirmTalentMatch(accounts[5].address, ethers.utils.parseEther("100"))
            ).to.be.revertedWith("admin: wut?");

            await TalenMatch.connect(owner).setAdmin(accounts[0].address, true);
            await TalenMatch.connect(accounts[0]).updateShareScheme(1000, 2000, 3000, 4000); // this should run

            await TalenMatch.connect(owner).setAdmin(accounts[0].address, false);
            await expect(
                TalenMatch.connect(accounts[0]).updateShareScheme(4000, 2000, 3000, 1000)
            ).to.be.revertedWith("admin: wut?");
        });
    });

    describe("Talent Match Events", function () {
        it("Emits Add Match Event", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await expect(
                TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"))
            ).to.emit(courseTokenEvent, "TalentMatchAdded").withArgs(anyValue, accounts[5].address);
        });

        it("Emits Update Match Event", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            await expect(
                TalenMatch.updateTalentMatch(accounts[5].address, accounts[6].address, accounts[10].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"))
            ).to.emit(courseTokenEvent, "TalentMatchUpdated").withArgs(anyValue, accounts[5].address);
        });

        it("Emits Delete Match Event", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            await expect(
                TalenMatch.deleteTalentMatch(accounts[5].address)
            ).to.emit(courseTokenEvent, "TalentMatchDeleted").withArgs(anyValue, accounts[5].address);
        });

        it("Emits Confirm Match Event", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await TalenMatch.addTalentMatch(accounts[5].address, accounts[6].address, accounts[7].address, accounts[8].address, courseNFT.address, 0, ethers.utils.parseEther("100"));
            await gtContract.approve(TalenMatch.address, ethers.utils.parseEther("100"));
            await expect(
                TalenMatch.confirmTalentMatch(accounts[5].address, ethers.utils.parseEther("100"))
            ).to.emit(courseTokenEvent, "TalentMatchConfirmed").withArgs(anyValue, accounts[5].address, ethers.utils.parseEther("100"));
        });

        it("Emits Share Scheme Updated Event", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares } = await loadFixture(deployTestEnvFixtureTalentMatch);
            await expect(
                TalenMatch.updateShareScheme(1000, 2000, 3000, 4000)
            ).to.emit(courseTokenEvent, "ShareSchemeUpdated").withArgs(1000, 2000, 3000, 4000);
        });
    });
});
