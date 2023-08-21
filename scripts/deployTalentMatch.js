const hre = require("hardhat");

async function main(treasuryAddress, gtAddress, emitEventAddress) {
    
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');
 
    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [gtAddress, 3000, 3000, 4000, emitEventAddress, treasuryAddress]);
    await TalenMatch.deployed();
    console.log("deployed TalenMatch: ", TalenMatch.address);

}

// please fill up the addresses
const treasuryAddress = "0xBcd4042DE499D14e55001CcbB24a551F3b954096"
const gtAddress = "0xe2BbFFB2735B8CeF08e1B2240Ba539F0a8466D86"
const emitEventAddress = "0xC1bc3350B679E37873658d30A688962DdB8A0C15"
main(treasuryAddress, gtAddress, emitEventAddress);