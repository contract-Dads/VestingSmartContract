const { expect } = require("chai");
const { number } = require("yargs");

describe("Vesting", function () {
  let Token;
  let testToken;
  let TokenVesting;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  before(async function () {
    Token = await ethers.getContractFactory("Token");
    TokenVesting = await ethers.getContractFactory("MockTokenVesting");
  });
  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    testToken = await Token.deploy("Test Token", "TT", 1000000);
    await testToken.deployed();
  });

  describe("Vesting", function () {
    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await testToken.balanceOf(owner.address);
      expect(await testToken.totalSupply()).to.equal(ownerBalance);
    });



    it("Should vest tokens gradually", async function () {
      // deploy vesting contract
      const tokenVesting = await TokenVesting.deploy(testToken.address);
      await tokenVesting.deployed();

      await expect(testToken.transfer(tokenVesting.address, 1000))
        .to.emit(testToken, "Transfer")
        .withArgs(owner.address, tokenVesting.address, 1000);
      const vestingContractBalance = await testToken.balanceOf(
        tokenVesting.address
      );

      expect(vestingContractBalance).to.equal(1000);

      expect(await tokenVesting.getWithdrawableAmount()).to.equal(1000);

      const baseTime = 1671769649;
      const beneficiary = addr1;
      const startTime = baseTime;
      const cliff = 0;
      const duration = 1000;
      const slicePeriodSeconds = 1;
      const revokable = true;
      const amount = 100;
      const typeOfVesting = 0;

      // create new vesting schedule
      await tokenVesting.createVestingSchedule(
        beneficiary.address,
        startTime,
        cliff,
        duration,
        slicePeriodSeconds,
        revokable,
        amount,
        typeOfVesting
      );

      expect(await tokenVesting.getVestingSchedulesCount()).to.be.equal(1);

      expect(
        await tokenVesting.getVestingSchedulesCountByBeneficiary(
          beneficiary.address
        )
      ).to.be.equal(1);

      // compute vesting schedule id
      const vestingScheduleId =
        await tokenVesting.computeVestingScheduleIdForAddressAndIndex(
          beneficiary.address,
          0
        );

      // check that vested amount is 0
      expect(
        await tokenVesting.computeReleasableAmount(vestingScheduleId)
      ).to.be.equal(0);

      // set time to half the vesting period
      const halfTime = baseTime + duration / 2;
      await tokenVesting.setCurrentTime(halfTime);

      expect(
        await tokenVesting
          .connect(beneficiary)
          .computeReleasableAmount(vestingScheduleId)
      ).to.be.equal(62);


      // check that beneficiary cannot release more than the vested amount
      await tokenVesting.connect(beneficiary).release(vestingScheduleId);

      expect(await testToken.balanceOf(beneficiary.address)).to.be.equal(62);

      // set current time after the end of the vesting period
      await tokenVesting.setCurrentTime(baseTime + duration + 1);

      expect(
        await tokenVesting
          .connect(beneficiary)
          .computeReleasableAmount(vestingScheduleId)
      ).to.be.equal(38);

      await tokenVesting.connect(beneficiary).release(vestingScheduleId);

      expect(await testToken.balanceOf(beneficiary.address)).to.be.equal(100);

      // check that the number of released tokens is 100

      let vestingSchedule = await tokenVesting.getVestingSchedule(
        vestingScheduleId
      );
      expect(vestingSchedule.released).to.be.equal(100);

      // check that the vested amount is 0
      expect(
        await tokenVesting
          .connect(beneficiary)
          .computeReleasableAmount(vestingScheduleId)
      ).to.be.equal(0);

    });

    it("Should compute vesting schedule index", async function () {
      const tokenVesting = await TokenVesting.deploy(testToken.address);
      await tokenVesting.deployed();
      const expectedVestingScheduleId =
        "0xa279197a1d7a4b7398aa0248e95b8fcc6cdfb43220ade05d01add9c5468ea097";
      expect(
        (
          await tokenVesting.computeVestingScheduleIdForAddressAndIndex(
            addr1.address,
            0
          )
        ).toString()
      ).to.equal(expectedVestingScheduleId);
      expect(
        (
          await tokenVesting.computeNextVestingScheduleIdForHolder(
            addr1.address
          )
        ).toString()
      ).to.equal(expectedVestingScheduleId);
    });


  });
});
