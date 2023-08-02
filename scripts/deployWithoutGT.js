const hre = require("hardhat");

async function main(treasuryAddress) {
    
    const courseTokenEventDeployer = await hre.ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await hre.ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await hre.ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');
    
    const courseTokenEvent = await hre.upgrades.deployProxy(courseTokenEventDeployer);
    await courseTokenEvent.deployed();
    console.log("deployed courseTokenEvent: ", courseTokenEvent.address);
    
    const courseTokenBeacon = await hre.upgrades.deployBeacon(courseTokenDeployer);
    await courseTokenBeacon.deployed()
    console.log("deployed Beacon: ", courseTokenBeacon.address);
    
    const courseFactory = await hre.upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, hre.ethers.constants.AddressZero, courseTokenEvent.address]);
    await courseFactory.deployed();
    console.log("deployed TokenFactory: ", courseFactory.address);

    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [hre.ethers.constants.AddressZero, 2000, 3000, 3000, 2000, courseTokenEvent.address, treasuryAddress]);
    await TalenMatch.deployed();
    console.log("deployed TalenMatch: ", TalenMatch.address);

    let txn = await courseTokenEvent.setExecutor(courseFactory.address, true);
    await txn.wait();
    console.log("Done setExecutor to courseFactory");
    txn = await courseTokenEvent.setExecutor(TalenMatch.address, true);
    await txn.wait();
    console.log("Done setExecutor to TalenMatch");

}

const treasuryAddress = "0x821f3361D454cc98b7555221A06Be563a7E2E0A6"
main(treasuryAddress);