const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Name", function () {
  it("Should register, renew and unregister name", async function () {
    const Name = await ethers.getContractFactory("Name");
    const name = await Name.deploy();
    await name.deployed();

    const registrationName = "Narayan";

    const feesRequired = (await name.requiredFees(registrationName)).toString()

    await (await name.register(registrationName, { value: feesRequired })).wait()
    let balance = await ethers.provider.getBalance(name.address)

    expect(balance).to.equal(feesRequired);
    await expect(name.register(registrationName, { value: feesRequired })).to.be.revertedWith("Name is taken");
    await expect(name.expire(registrationName)).to.be.revertedWith("Cannot expire name");

    await network.provider.send("evm_increaseTime", [36000])
    await (await name.expire(registrationName)).wait()

    balance = await ethers.provider.getBalance(name.address)
    expect(balance).to.equal("0");

    await expect(name.renew(registrationName)).to.be.revertedWith("Cannot renew");
  });
});
