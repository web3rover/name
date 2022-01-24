const { expect } = require("chai");
const { ethers } = require("hardhat");
const randomstring = require("randomstring");

describe("Name", function () {
  it("Should register, renew and unregister name", async function () {
    const Name = await ethers.getContractFactory("Name");
    const name = await Name.deploy();
    await name.deployed();

    const registrationName = "Narayan";

    const feesRequired = (await name.feesRequired(registrationName)).toString()

    const accounts = await ethers.getSigners()
    const user = accounts[0]
    let random = randomstring.generate(32)
    let commitment = (await name.commitment(user.address, registrationName, random))

    await (await name.commit(commitment, { value: feesRequired })).wait()
    await (await name.reveal(registrationName, random)).wait()

    let balance = await ethers.provider.getBalance(name.address)
    expect(balance).to.equal(feesRequired);

    random = randomstring.generate(32)
    commitment = (await name.commitment(user.address, registrationName, random))
    await (await name.commit(commitment, { value: feesRequired })).wait()
    await expect(name.reveal(registrationName, random)).to.be.revertedWith("Name is taken");

    await expect(name.expire(registrationName)).to.be.revertedWith("Cannot expire name");

    await network.provider.send("evm_increaseTime", [36000])
    await (await name.expire(registrationName)).wait()

    balance = await ethers.provider.getBalance(name.address)
    expect(balance).to.equal("7000");

    await expect(name.renew(registrationName)).to.be.revertedWith("Cannot renew");
  });
});
