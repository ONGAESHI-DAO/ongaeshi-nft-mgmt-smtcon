const hre = require("hardhat");

async function main(treasuryAddress, gtAddress, emitEventAddress) {
    
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');
 
    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [gtAddress, 3000, 3000, 4000, emitEventAddress, treasuryAddress]);
    await TalenMatch.deployed();
    console.log("deployed TalenMatch: ", TalenMatch.address);

}

// please fill up the addresses
const treasuryAddress = "0x821f3361D454cc98b7555221A06Be563a7E2E0A6"
const gtAddress = ""
const emitEventAddress = ""
main(treasuryAddress, gtAddress, emitEventAddress);