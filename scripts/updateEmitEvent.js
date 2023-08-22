const hre = require("hardhat");

async function setNewEmitEvent(targetAddress, emitEventAddress) {
    
    const contract = await hre.ethers.getContractAt("CourseToken", targetAddress);
    const EmitEvent = await hre.ethers.getContractAt("CourseTokenEvent", emitEventAddress);

    let txn = await contract.setEmitEvent(emitEventAddress);
    await txn.wait();

    txn = await EmitEvent.setExecutor(targetAddress, true);
    await txn.wait();

    console.log("set emitEvent done for: ", targetAddress);

}

// please fill up the addresses
// caller must be owner
const targetAddress = "0xf5bbe568B64d9933AE0680147394A9752b084eBc" // courseFactory, courseToken, talentMatch address
const emitEventAddress = "0xC1bc3350B679E37873658d30A688962DdB8A0C15"


async function main() {
    await setNewEmitEvent(targetAddress, emitEventAddress); // example
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");
    // await setNewEmitEvent("0x00000000000000000...", "0x00000000000...");

}
main();


