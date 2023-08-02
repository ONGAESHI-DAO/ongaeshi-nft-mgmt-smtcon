async function deployTestEnvFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, ...accounts] = await ethers.getSigners();

    const GTFactory = await ethers.getContractFactory('GT');
    const courseTokenEventDeployer = await ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await ethers.getContractFactory('TalentMatch');
    const airdropDeployer = await hre.ethers.getContractFactory('Airdrop');

    const gtContract = await GTFactory.deploy();
    const courseTokenEvent = await upgrades.deployProxy(courseTokenEventDeployer);
    const courseTokenBeacon = await upgrades.deployBeacon(courseTokenDeployer);
    const courseFactory = await upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, gtContract.address, courseTokenEvent.address]);
    const TalenMatch = await upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 3000, 3000, 4000, courseTokenEvent.address, accounts[9].address]);
    const airdrop = await airdropDeployer.deploy(gtContract.address);
    await courseTokenEvent.setExecutor(courseFactory.address, true);
    await courseTokenEvent.setExecutor(TalenMatch.address, true);

    // give accounts some GT
    for (let i = 0; i < 5; i++) {
        await gtContract.transfer(accounts[i].address, ethers.utils.parseEther("1000"));
    }

    const defaultTeacherShares = [
        {
            teacher: accounts[0].address,
            shares: 5000
        },
        {
            teacher: accounts[1].address,
            shares: 4000
        },
        {
            teacher: accounts[2].address,
            shares: 1000
        }
    ]
    await courseFactory.deployCourseToken("Token Name", "Symbol", "test://uri/", ethers.utils.parseEther("1"), 9000, 100, accounts[9].address);
    const courseNFT = await courseTokenDeployer.attach(await courseFactory.deployedAddresses(0));
    await courseNFT.addTeacherShares(defaultTeacherShares);
    return { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares, airdrop};
}

async function deployTestEnvFixtureTalentMatch() {

    // Contracts are deployed using the first signer/account by default
    const [owner, ...accounts] = await ethers.getSigners();

    const GTFactory = await ethers.getContractFactory('GT');
    const courseTokenEventDeployer = await ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await ethers.getContractFactory('TalentMatch');

    const gtContract = await GTFactory.deploy();
    const courseTokenEvent = await upgrades.deployProxy(courseTokenEventDeployer);
    const courseTokenBeacon = await upgrades.deployBeacon(courseTokenDeployer);
    const courseFactory = await upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, gtContract.address, courseTokenEvent.address]);
    const TalenMatch = await upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 3000, 3000, 4000, courseTokenEvent.address, accounts[9].address]);
    await courseTokenEvent.setExecutor(courseFactory.address, true);
    await courseTokenEvent.setExecutor(TalenMatch.address, true);

    // give accounts some GT
    for (let i = 0; i < 5; i++) {
        await gtContract.transfer(accounts[i].address, ethers.utils.parseEther("1000"));
    }

    const defaultTeacherShares = [
        {
            teacher: accounts[0].address,
            shares: 5000
        },
        {
            teacher: accounts[1].address,
            shares: 4000
        },
        {
            teacher: accounts[2].address,
            shares: 1000
        }
    ]
    await courseFactory.deployCourseToken("Token Name", "Symbol", "test://uri/", ethers.utils.parseEther("1"), 9000, 100, accounts[9].address);
    const courseNFT = await courseTokenDeployer.attach(await courseFactory.deployedAddresses(0));
    await courseNFT.addTeacherShares(defaultTeacherShares);
    await courseNFT.mintByAdmin(3, accounts[8].address);
    return { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares };
}

async function deployTestEnvFixtureWithoutGT() {

    // Contracts are deployed using the first signer/account by default
    const [owner, ...accounts] = await ethers.getSigners();

    const courseTokenEventDeployer = await ethers.getContractFactory('CourseTokenEvent');
    const courseTokenDeployer = await ethers.getContractFactory("CourseToken");
    const courseTokenFactoryDeployer = await ethers.getContractFactory('CourseTokenFactory');
    const talentMatchDeployer = await ethers.getContractFactory('TalentMatch');

    const courseTokenEvent = await upgrades.deployProxy(courseTokenEventDeployer);
    const courseTokenBeacon = await upgrades.deployBeacon(courseTokenDeployer);
    const courseFactory = await upgrades.deployProxy(courseTokenFactoryDeployer, [courseTokenBeacon.address, ethers.constants.AddressZero, courseTokenEvent.address]);
    const TalenMatch = await upgrades.deployProxy(talentMatchDeployer, [ethers.constants.AddressZero, 3000, 3000, 4000, courseTokenEvent.address, accounts[9].address]);
    await courseTokenEvent.setExecutor(courseFactory.address, true);
    await courseTokenEvent.setExecutor(TalenMatch.address, true);

    const defaultTeacherShares = [
        {
            teacher: accounts[0].address,
            shares: 5000
        },
        {
            teacher: accounts[1].address,
            shares: 4000
        },
        {
            teacher: accounts[2].address,
            shares: 1000
        }
    ]
    await courseFactory.deployCourseToken("Token Name", "Symbol", "test://uri/", ethers.utils.parseEther("1"), 9000, 100, accounts[9].address);
    const courseNFT = await courseTokenDeployer.attach(await courseFactory.deployedAddresses(0));
    await courseNFT.addTeacherShares(defaultTeacherShares);
    await courseNFT.setAdminRepairOnly(true);

    return { courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares};
}

module.exports = {
    deployTestEnvFixture,
    deployTestEnvFixtureTalentMatch,
    deployTestEnvFixtureWithoutGT
};