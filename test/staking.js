const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { deployTestEnvFixture } = require("./testLib")

describe("Stake Test", function () {

    describe("Stake", function () {

        it("Stake", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop, stake } = await loadFixture(deployTestEnvFixture);
            await gtContract.approve(stake.address, ethers.utils.parseEther("10000"));
            await gtContract.connect(accounts[1]).approve(stake.address, ethers.utils.parseEther("10000"));
            const balBefore = await gtContract.balanceOf(owner.address);

            await stake.stake(ethers.utils.parseEther("5000"), 86400 * 30, 1);
            
            // check balances
            expect((await gtContract.balanceOf(owner.address))).to.equal(balBefore.sub(ethers.utils.parseEther("5000")));
            expect((await gtContract.balanceOf(stake.address))).to.equal(ethers.utils.parseEther("5000"));

            // add more stake
            await stake.stake(ethers.utils.parseEther("3000"), 86400 * 30, 2);
            await stake.stake(ethers.utils.parseEther("2000"), 86400 * 30, 3);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("100"), 86400 * 60, 1);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("200"), 86400 * 60, 2);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("300"), 86400 * 60, 3);

            const allUser = await stake.getAllUser(1);
            const data = await stake.getUserPosition(owner.address, 2);
            const data2 = await stake.getUserPosition(accounts[1].address, 1);

            // check all user
            expect(allUser[0]).to.equal(owner.address);
            expect(allUser[1]).to.equal(accounts[1].address);

            // check user position data
            expect(data[0].amount).to.equal(ethers.utils.parseEther("3000"));
            expect(data[0].depositDuration).to.equal(86400 * 30);
            expect(data2[0].amount).to.equal(ethers.utils.parseEther("100"));
            expect(data2[0].depositDuration).to.equal(86400 * 60);

            // check total deposit count
            expect((await stake.totalDeposits(3))).to.equal(ethers.utils.parseEther("2300"));

        });

        it("Stake Multi", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop, stake } = await loadFixture(deployTestEnvFixture);
            await gtContract.approve(stake.address, ethers.utils.parseEther("10000"));

            // stake
            await stake.stake(ethers.utils.parseEther("5000"), 86400 * 60, 1);

            // add stake same incentive
            await stake.stake(ethers.utils.parseEther("3000"), 86400 * 30, 1);

            const allUser = await stake.getAllUser(1);
            const data = await stake.getUserPosition(owner.address, 1);

            // check all user
            expect(allUser[0]).to.equal(owner.address);

            // check user position data
            expect(data[0].amount).to.equal(ethers.utils.parseEther("5000"));
            expect(data[0].depositDuration).to.equal(86400 * 60);
            expect(data[1].amount).to.equal(ethers.utils.parseEther("3000"));
            expect(data[1].depositDuration).to.equal(86400 * 30);

        });

        it("Withdraw", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop, stake } = await loadFixture(deployTestEnvFixture);

            // setup for withdraw
            await gtContract.approve(stake.address, ethers.utils.parseEther("10000"));
            await gtContract.connect(accounts[1]).approve(stake.address, ethers.utils.parseEther("10000"));
            await stake.stake(ethers.utils.parseEther("5000"), 86400 * 30, 1);
            await stake.stake(ethers.utils.parseEther("3000"), 86400 * 30, 2);
            await stake.stake(ethers.utils.parseEther("2000"), 86400 * 30, 3);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("100"), 86400 * 30, 1);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("200"), 86400 * 30, 2);
            await stake.connect(accounts[1]).stake(ethers.utils.parseEther("300"), 86400 * 30, 3);
            await time.increase(86400 * 30);

            const balBefore0 = await gtContract.balanceOf(owner.address);
            const balBefore1 = await gtContract.balanceOf(accounts[1].address);
            const balBeforeContract = await gtContract.balanceOf(stake.address);

            await stake.withdraw(1, 0);
            
            const data = await stake.getUserPosition(owner.address, 1);
            const data2 = await stake.getUserPosition(owner.address, 2);
            const allUser = await stake.getAllUser(1);

            // check balances
            expect(await gtContract.balanceOf(owner.address)).to.equal(balBefore0.add(ethers.utils.parseEther("5000")));
            expect(await gtContract.balanceOf(stake.address)).to.equal(balBeforeContract.sub(ethers.utils.parseEther("5000")));

            // check all user
            expect(allUser.length).to.equal(1);
            expect(allUser[0]).to.equal(accounts[1].address);

            // check user data
            expect(data.length).to.equal(0);
            expect(data2[0].amount).to.equal(ethers.utils.parseEther("3000"));
            expect(data2[0].depositDuration).to.equal(86400 * 30);

            expect(await stake.totalDeposits(1)).to.equal(ethers.utils.parseEther("100"));
            expect(await stake.totalDeposits(2)).to.equal(ethers.utils.parseEther("3200"));
            expect(await stake.totalDeposits(3)).to.equal(ethers.utils.parseEther("2300"));


            // withdraw all
            await stake.withdraw(2, 0);
            await stake.withdraw(3, 0);
            await stake.connect(accounts[1]).withdraw(1, 0);
            await stake.connect(accounts[1]).withdraw(2, 0);
            await stake.connect(accounts[1]).withdraw(3, 0);

            // check balance
            expect(await gtContract.balanceOf(owner.address)).to.equal(balBefore0.add(ethers.utils.parseEther("10000")));
            expect(await gtContract.balanceOf(accounts[1].address)).to.equal(balBefore1.add(ethers.utils.parseEther("600")));
            expect(await gtContract.balanceOf(stake.address)).to.equal("0");

            expect(await stake.totalDeposits(1)).to.equal(0);
            expect(await stake.totalDeposits(2)).to.equal(0);
            expect(await stake.totalDeposits(3)).to.equal(0);

        });

        it("Withdraw Multi", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop, stake } = await loadFixture(deployTestEnvFixture);

            // setup for withdraw
            await gtContract.approve(stake.address, ethers.utils.parseEther("10000"));
            await stake.stake(ethers.utils.parseEther("5000"), 86400 * 60, 1);
            await stake.stake(ethers.utils.parseEther("3000"), 86400 * 30, 1);
            await time.increase(86400 * 30);

            const balBefore0 = await gtContract.balanceOf(owner.address);
            const balBefore1 = await gtContract.balanceOf(accounts[1].address);
            const balBeforeContract = await gtContract.balanceOf(stake.address);

            await stake.withdraw(1, 1);
            
            const data = await stake.getUserPosition(owner.address, 1);
            const allUser = await stake.getAllUser(1);

            // check balances
            expect(await gtContract.balanceOf(owner.address)).to.equal(balBefore0.add(ethers.utils.parseEther("3000")));

            // check all user
            expect(allUser.length).to.equal(1);
            expect(allUser[0]).to.equal(owner.address);

            // check user data
            expect(data.length).to.equal(1);
            expect(data[0].amount).to.equal(ethers.utils.parseEther("5000"));
            expect(data[0].depositDuration).to.equal(86400 * 60);

            expect(await stake.totalDeposits(1)).to.equal(ethers.utils.parseEther("5000"));


            // withdraw all
            await expect(stake.withdraw(1, 0)).to.be.revertedWith("Stake duration still ongoing");
            await time.increase(86400 * 30);

            await stake.withdraw(1, 0);
            expect(await gtContract.balanceOf(owner.address)).to.equal(balBefore0.add(ethers.utils.parseEther("8000")));
        });
    });

    describe("Stake Events", function () {

        it("Deposit Withdraw Events", async function () {
            const { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop, stake } = await loadFixture(deployTestEnvFixture);
            await gtContract.approve(stake.address, ethers.utils.parseEther("10000"));

            await expect(
                stake.stake(ethers.utils.parseEther("5000"), 86400 * 30, 1)
            ).to.emit(stake, "StakedToken");
            
            await time.increase(86400 * 35);

            await expect(
                stake.withdraw(1, 0)
            ).to.emit(stake, "WithdrawToken");
        });
    });

});