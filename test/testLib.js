async function deployTestEnvFixture() {

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
    const TalenMatch = await upgrades.deployProxy(talentMatchDeployer, [gtContract.address, 2000, 3000, 3000, 2000, courseTokenEvent.address]);
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
    await courseFactory.deployCourseToken("Token Name", "Symbol", "test://uri/", ethers.utils.parseEther("1"), 100, accounts[0].address, defaultTeacherShares);
    const courseNFT = await courseTokenDeployer.attach(await courseFactory.deployedAddresses(0));
    return { gtContract, courseTokenEvent, courseFactory, TalenMatch, courseNFT, owner, accounts, defaultTeacherShares };
}

module.exports = {
    deployTestEnvFixture
};