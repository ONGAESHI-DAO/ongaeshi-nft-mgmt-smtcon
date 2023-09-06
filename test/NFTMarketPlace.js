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

describe("NFT Marketplace Test", function () {

    describe("NFTMarketplace", function () {
        let f;
        beforeEach(async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 2);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 2, ethers.utils.parseEther("1.5"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 3);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 3, ethers.utils.parseEther("2"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 4);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 4, ethers.utils.parseEther("2.5"));
        })

        it("Created Multiple Listing", async function () {

            expect(await f.courseNFT.ownerOf(1)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(4)).to.equal(f.NFTMarketplace.address);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(4);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(2);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("1.5"));
            expect(listingObj.index).to.equal(1);

            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(4);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("2.5"));
            expect(listingObj.index).to.equal(3);
        });

        it("Update Listing", async function () {

            await f.NFTMarketplace.connect(f.accounts[8]).updateListing(f.courseNFT.address, 2, ethers.utils.parseEther("1"));
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(2);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("1"));
            expect(listingObj.index).to.equal(1);
        });

        it("Delete Listing", async function () {

            await f.NFTMarketplace.connect(f.accounts[8]).cancelListing(f.courseNFT.address, 2);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenId).to.equal(0);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(3);
            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.index).to.equal(1);
            await f.NFTMarketplace.connect(f.accounts[8]).cancelListing(f.courseNFT.address, 3);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(2);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.accounts[8].address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.accounts[8].address);
        });

        it("Purchase Listing", async function () {

            const balbefore = await f.gtContract.balanceOf(f.accounts[8].address);
            await f.gtContract.approve(f.NFTMarketplace.address, ethers.utils.parseEther("3.5"))
            await f.NFTMarketplace.buyListing(f.courseNFT.address, 2);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenId).to.equal(0);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(3);
            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.index).to.equal(1);
            await f.NFTMarketplace.buyListing(f.courseNFT.address, 3);
            const balAfter = await f.gtContract.balanceOf(f.accounts[8].address);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(2);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.owner.address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.owner.address);
            expect((balAfter - balbefore).toString()).to.be.equals(ethers.utils.parseEther("1.75").toString());

        });
    });

    describe("Error Cases", function () {
        let f;
        it("Listing Token that is on loan", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.lendToken(1, ethers.utils.toUtf8Bytes("9csh28dnnairbdhwovhe"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"))
            ).to.be.revertedWith("Token is on loan, listing is not permitted");
        });

        it("Listing Token that needs repair", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.lendToken(1, ethers.utils.toUtf8Bytes("9csh28dnnairbdhwovhe"));
            await f.courseNFT.returnToken(1, ethers.utils.parseEther("5"), false);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"))
            ).to.be.revertedWith("Token needs repair, listing is not permitted");
        });

        it("Listing Token with price zero", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, 0)
            ).to.be.revertedWith("Listing price must not be zero");
        });

        it("Update Listing as non lister", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"));
            await expect(
                f.NFTMarketplace.connect(f.accounts[9]).updateListing(f.courseNFT.address, 1, ethers.utils.parseEther("2"))
            ).to.be.revertedWith("msg sender is not lister");

        });

        it("Cancel Listing as non lister", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"));
            await expect(
                f.NFTMarketplace.connect(f.accounts[9]).cancelListing(f.courseNFT.address, 1)
            ).to.be.revertedWith("msg sender is not lister");

        });

    });

    describe("NFT Marketplace Events", function () {

        it("Listing Created Event", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"))
            ).to.emit(f.NFTMarketplace, "ListingCreated").withArgs(f.courseNFT.address, 1, f.accounts[8].address, ethers.utils.parseEther("1"));
        });

        it("Listing Updated Event", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"))
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).updateListing(f.courseNFT.address, 1, ethers.utils.parseEther("2"))
            ).to.emit(f.NFTMarketplace, "ListingUpdated").withArgs(f.courseNFT.address, 1, ethers.utils.parseEther("1"), ethers.utils.parseEther("2"));
        });

        it("Listing Deleted Event", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"))
            await expect(
                f.NFTMarketplace.connect(f.accounts[8]).cancelListing(f.courseNFT.address, 1)
            ).to.emit(f.NFTMarketplace, "ListingDeleted").withArgs(f.courseNFT.address, 1);
        });

        it("Listing Purchased Event", async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"));
            await f.gtContract.approve(f.NFTMarketplace.address, ethers.utils.parseEther("1"));
            await expect(
                f.NFTMarketplace.buyListing(f.courseNFT.address, 1)
            ).to.emit(f.NFTMarketplace, "ListingPurchased").withArgs(f.courseNFT.address, 1, f.owner.address, ethers.utils.parseEther("1"));
        });


    });

    describe('Normal Transfers', () => {
        let f;
        beforeEach(async function () {
            f = await loadFixture(deployTestEnvFixtureTalentMatch);
            await f.courseNFT.setTransferEnabled(true);

            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 1);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 1, ethers.utils.parseEther("1"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 2);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 2, ethers.utils.parseEther("1.5"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 3);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 3, ethers.utils.parseEther("2"));
            await f.courseNFT.connect(f.accounts[8]).approve(f.NFTMarketplace.address, 4);
            await f.NFTMarketplace.connect(f.accounts[8]).createListing(f.courseNFT.address, 4, ethers.utils.parseEther("2.5"));
        })

        it("Created Multiple Listing", async function () {

            expect(await f.courseNFT.ownerOf(1)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.NFTMarketplace.address);
            expect(await f.courseNFT.ownerOf(4)).to.equal(f.NFTMarketplace.address);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(4);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(2);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("1.5"));
            expect(listingObj.index).to.equal(1);

            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(4);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("2.5"));
            expect(listingObj.index).to.equal(3);
        });

        it("Update Listing", async function () {

            await f.NFTMarketplace.connect(f.accounts[8]).updateListing(f.courseNFT.address, 2, ethers.utils.parseEther("1"));
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenAddress).to.equal(f.courseNFT.address);
            expect(listingObj.tokenId).to.equal(2);
            expect(listingObj.nftOwner).to.equal(f.accounts[8].address);
            expect(listingObj.price).to.equal(ethers.utils.parseEther("1"));
            expect(listingObj.index).to.equal(1);
        });

        it("Delete Listing", async function () {

            await f.NFTMarketplace.connect(f.accounts[8]).cancelListing(f.courseNFT.address, 2);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenId).to.equal(0);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(3);
            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.index).to.equal(1);
            await f.NFTMarketplace.connect(f.accounts[8]).cancelListing(f.courseNFT.address, 3);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(2);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.accounts[8].address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.accounts[8].address);
        });

        it("Purchase Listing", async function () {

            const balbefore = await f.gtContract.balanceOf(f.accounts[8].address);
            await f.gtContract.approve(f.NFTMarketplace.address, ethers.utils.parseEther("3.5"))
            await f.NFTMarketplace.buyListing(f.courseNFT.address, 2);
            let listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 2);
            expect(listingObj.tokenId).to.equal(0);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(3);
            listingObj = await f.NFTMarketplace.getListing(f.courseNFT.address, 4);
            expect(listingObj.index).to.equal(1);
            await f.NFTMarketplace.buyListing(f.courseNFT.address, 3);
            const balAfter = await f.gtContract.balanceOf(f.accounts[8].address);
            expect(await f.NFTMarketplace.getListingsCount()).to.equal(2);
            expect(await f.courseNFT.ownerOf(2)).to.equal(f.owner.address);
            expect(await f.courseNFT.ownerOf(3)).to.equal(f.owner.address);
            expect((balAfter - balbefore).toString()).to.be.equals(ethers.utils.parseEther("1.75").toString());

        });
    });
});