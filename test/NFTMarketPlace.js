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
});