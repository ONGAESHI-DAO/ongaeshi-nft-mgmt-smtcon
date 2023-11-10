const hre = require("hardhat");

async function burnToken(nftAddress, nftOwner, tokenId) {
    
    const burnAddress = "0x000000000000000000000000000000000000dEaD"
    const contract = await hre.ethers.getContractAt("CourseToken", nftAddress);
    let txn = await contract.adminTransferFrom(nftOwner, burnAddress, tokenId);
    await txn.wait();
    console.log("Token id: ", tokenId, " burned");
    // check after burned
    console.log("latest Owner", await contract.ownerOf(tokenId))
    
}

// please fill up the addresses
// caller must be owner
const nftAddress = "0xC9EE9E9C2ec4641F3727d169B01549A58E2712CC" // courseFactory, courseToken, talentMatch address
const owner = "0x700077412f6ecE065e2AC0DF975A6B2BD9DcaA4D"
const tokenId1 = "30";
const tokenId2 = "31";


async function main() {
    await burnToken(nftAddress, owner, tokenId1);
    await burnToken(nftAddress, owner, tokenId2);
}
main();


