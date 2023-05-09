const hre = require("hardhat");

async function main() {
    
    const GTFactory = await hre.ethers.getContractFactory('GT');
    const courseTokenEventDeployer = await hre.ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await hre.ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await hre.ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');

    const gtContract = await GTFactory.deploy();
    await gtContract.deployed();
    console.log("deployed GT: ", gtContract.address);
    
    const courseTokenEvent = await hre.upgrades.deployProxy(courseTokenEventDeployer);
    await courseTokenEvent.deployed();
    console.log("deployed courseTokenEvent: ", courseTokenEvent.address);
    
    const courseTokenBeacon = await hre.upgrades.deployBeacon(courseTokenDeployer);
    await courseTokenBeacon.deployed()
    console.log("deployed Beacon: ", courseTokenBeacon.address);
    
    const courseFactory = await hre.upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, gtContract.address, courseTokenEvent.address]);
    await courseFactory.deployed();
    console.log("deployed TokenFactory: ", courseFactory.address);

    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 2000, 3000, 3000, 2000, courseTokenEvent.address]);
    await TalenMatch.deployed();
    console.log("deployed TalenMatch: ", TalenMatch.address);

    let txn = await courseTokenEvent.setExecutor(courseFactory.address, true);
    await txn.wait();
    console.log("Done setExecutor to courseFactory");
    txn = await courseTokenEvent.setExecutor(TalenMatch.address, true);
    await txn.wait();
    console.log("Done setExecutor to TalenMatch");
}


main();