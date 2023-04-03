const hre = require("hardhat");

async function main() {
    const GTFactory = await hre.ethers.getContractFactory('GT');
    const courseTokenDeployer = await hre.ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await hre.ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');

    const gtContract = await GTFactory.deploy();
    await gtContract.deployed();

    const courseTokenBeacon = await hre.upgrades.deployBeacon(courseTokenDeployer);
    await courseTokenBeacon.deployed()

    const courseFactory = await hre.upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, gtContract.address]);
    await courseFactory.deployed();

    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 2000, 3000, 3000, 2000]);
    await TalenMatch.deployed();

    console.log("deployed GT: ", gtContract.address);
    console.log("deployed Beacon: ", courseTokenBeacon.address);
    console.log("deployed TokenFactory: ", courseFactory.address);
    console.log("deployed TalenMatch: ", TalenMatch.address);
}


main();