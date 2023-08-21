const hre = require("hardhat");

async function main(treasuryAddress) {
    
    const GTFactory = await hre.ethers.getContractFactory('GT');
    const courseTokenEventDeployer = await hre.ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await hre.ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await hre.ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await hre.ethers.getContractFactory('TalentMatch');
    const airdropDeployer = await hre.ethers.getContractFactory('Airdrop');

    const gtContract = await GTFactory.deploy();
    await gtContract.deployed();
    console.log("deployed GT: ", gtContract.address);
    
    const courseTokenEvent = await hre.upgrades.deployProxy(courseTokenEventDeployer);
    await courseTokenEvent.deployed();
    console.log("deployed courseTokenEvent: ", courseTokenEvent.address);
    
    const courseTokenBeacon = await hre.upgrades.deployBeacon(courseTokenDeployer);
    await courseTokenBeacon.deployed()
    console.log("deployed Beacon: ", courseTokenBeacon.address);
    
    const courseFactory = await hre.upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, gtContract.address, courseTokenEvent.address,]);
    await courseFactory.deployed();
    console.log("deployed TokenFactory: ", courseFactory.address);

    const TalenMatch = await hre.upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 3000, 3000, 4000, courseTokenEvent.address, treasuryAddress]);
    await TalenMatch.deployed();
    console.log("deployed TalenMatch: ", TalenMatch.address);

    let txn = await courseTokenEvent.setExecutor(courseFactory.address, true);
    await txn.wait();
    console.log("Done setExecutor to courseFactory");
    txn = await courseTokenEvent.setExecutor(TalenMatch.address, true);
    await txn.wait();
    console.log("Done setExecutor to TalenMatch");

    const airdrop = await airdropDeployer.deploy(gtContract.address);
    console.log("deployed Airdrop: ", airdrop.address);

    const addr1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" // airdrop wallet (localhost default wallet)
    const addr2 = "0x4d896ACA56c84D5b7D2eC817031E2E98cEb50F57" // gt exchange wallet (igs wallet)
    const addr3 = "0xACffE377D3BE67d927f3cE31c07A1c4B603F601d" // talent matching (igs wallet)
    
    txn = await gtContract.transfer(addr1, ethers.utils.parseEther("10000000"))    
    await txn.wait();
    console.log("Done sending GT token to address", addr1);

    txn = await gtContract.transfer(addr2, ethers.utils.parseEther("10000000"))    
    await txn.wait();
    console.log("Done sending GT token to address", addr2);

    txn = await gtContract.transfer(addr3, ethers.utils.parseEther("10000000"))    
    await txn.wait();
    console.log("Done sending GT token to address", addr3);

    // txn = await gtContract.transfer(addr3, ethers.utils.parseEther("10000000"))    
    // await txn.wait();
    // console.log("Done sending GT token to address", addr3);

    console.log(await gtContract.balanceOf(addr1))
    console.log(await gtContract.balanceOf(addr2))
    console.log(await gtContract.balanceOf(addr3))
    


}

const treasuryAddress = "0x821f3361D454cc98b7555221A06Be563a7E2E0A6"
main(treasuryAddress);