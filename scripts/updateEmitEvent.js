const hre = require("hardhat");

async function setNewEmitEvent(targetAddress, emitEventAddress) {
    
    const contract = await hre.ethers.getContractAt("CourseToken", targetAddress);

    let txn = await contract.setEmitEvent(emitEventAddress);
    await txn.wait();
    console.log("set emitEvent done for: ", targetAddress);

}

// please fill up the addresses
// caller must be owner
const targetAddress = "" // courseFactory, courseToken, talentMatch address
const emitEventAddress = ""


async function main() {
    await setNewEmitEvent(targetAddress, emitEventAddress); // example
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");

}
main();


