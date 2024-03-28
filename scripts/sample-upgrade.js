const hre = require("hardhat");

const impersonateAcc = async (wallet) => {

    console.log("impersonate account start...")
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [wallet],
    });
    const provider = ethers.getDefaultProvider("http://localhost:8545");

    return await provider.getSigner(wallet);
}

async function forceImportONG() {
    const eventFactory = await hre.ethers.getContractFactory('CourseTokenEvent');
    const nftFactoryFactory = await hre.ethers.getContractFactory('CourseTokenFactory');
    const nftFactory = await hre.ethers.getContractFactory('CourseToken');

    let eventContract = await hre.upgrades.forceImport('0xBa7C3ce6Fee83CF978159c4d8ED973fA172b450B', eventFactory, 'transparent');
    let nftFactoryContract = await hre.upgrades.forceImport('0x91D7ddEDfdf0e0Df6CdB56b1058b097801D96A48', nftFactoryFactory, 'transparent');
    let nftContract = await hre.upgrades.forceImport('0x98D56d55EF5EAc599639f8A3333CfbE40F942646', nftFactory, 'transparent');
    
}

async function upgrade() {
    // const signer = await impersonateAcc('0x6d3854a7a15818b4882b7B948D27D9c4c1eE2047');
    const signer = await impersonateAcc('0xAa341AA48F86978ff84E00f28bab64B4A7391F63');

    const nftFactoryFactoryV2 = await hre.ethers.getContractFactory('CourseTokenV2', signer);
    let nftFactoryContract = await hre.upgrades.upgradeBeacon('0x98D56d55EF5EAc599639f8A3333CfbE40F942646', nftFactoryFactoryV2);
    const NFT = await hre.ethers.getContractAt('CourseTokenV2', '0x1C067E9F24fC12e21Ef5BE924b3C12DF03d67231');
    console.log("msg: ", await NFT.newF());
    // console.log("msg:", await nftFactoryContract.newFunction());
}

async function main() {
    // await forceImportONG();
    await upgrade();
}
main();
