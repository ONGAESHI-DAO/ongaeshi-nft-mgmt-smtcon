const hre = require("hardhat");

async function main() {
    const courseTokenEventDeployer = await hre.ethers.getContractFactory('CourseTokenEvent');

    const courseTokenEvent = await hre.upgrades.deployProxy(courseTokenEventDeployer);
    await courseTokenEvent.deployed();
    console.log("deployed courseTokenEvent: ", courseTokenEvent.address);
}


main();