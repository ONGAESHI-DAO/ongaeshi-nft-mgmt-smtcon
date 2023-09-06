const hre = require("hardhat");

async function main() {
    
    const courseTokenEventDeployer = await hre.ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await hre.ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await hre.ethers.getContractFactory('CourseTokenFactory');
    
    const courseTokenEvent = await hre.upgrades.deployProxy(courseTokenEventDeployer);
    await courseTokenEvent.deployed();
    console.log("deployed courseTokenEvent: ", courseTokenEvent.address);
    
    const courseTokenBeacon = await hre.upgrades.deployBeacon(courseTokenDeployer);
    await courseTokenBeacon.deployed()
    console.log("deployed Beacon: ", courseTokenBeacon.address);
    
    const courseFactory = await hre.upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, hre.ethers.constants.AddressZero, courseTokenEvent.address]);
    await courseFactory.deployed();
    console.log("deployed TokenFactory: ", courseFactory.address);

    let txn = await courseTokenEvent.setExecutor(courseFactory.address, true);
    await txn.wait();
    console.log("Done setExecutor to courseFactory");

}

main();