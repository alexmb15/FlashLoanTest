import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("FlashLoanTest", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFlashLoanTest() {

    // Contracts are deployed using the first signer/account by default
    const [ownerToken, ownerLander, ownerBorrower, otherAccount] = await hre.ethers.getSigners();

    const initialSupplyAmount = ethers.parseUnits("1000000", "ether");

    const MyStableToken = await hre.ethers.getContractFactory("MyStableToken");
    const myStableToken = await MyStableToken.connect(ownerToken).deploy();

    const FlashLander = await hre.ethers.getContractFactory("FlashLander");
    const flashLander = await FlashLander.connect(ownerLander).deploy(myStableToken);

    const FlashBorrower = await hre.ethers.getContractFactory("FlashBorrower");
    const flashBorrower = await FlashBorrower.connect(ownerBorrower).deploy();
/*
    console.log("ownerToken = ", ownerToken.address);
    console.log("ownerLander = ", ownerLander.address);
    console.log("ownerBorrower = ", ownerBorrower.address);

    console.log("myStableToken = ", await myStableToken.owner());
    console.log("flashLander = ", await flashLander.owner());
    console.log("flashBorrower = ", await flashBorrower.owner());
*/
   
    myStableToken.mint(flashLander.target, initialSupplyAmount);

//    initialSupplyAmount

    return { myStableToken, flashLander, flashBorrower, initialSupplyAmount, ownerToken, ownerLander, ownerBorrower, otherAccount };
  }

  describe("Deployment", function () {
    it("Should have 1 milion tokens on FlashLender balance", async function () {
      const { myStableToken, flashLander, initialSupplyAmount } = await loadFixture(deployFlashLoanTest);

      expect(await myStableToken.balanceOf(flashLander.target)).to.equal(initialSupplyAmount);
    });

    it("Should set the right owner on contracts", async function () {
      const { myStableToken, flashLander, flashBorrower, ownerToken, ownerLander, ownerBorrower } = await loadFixture(deployFlashLoanTest);

      expect(await myStableToken.owner()).to.equal(ownerToken.address);
      expect(await flashLander.owner()).to.equal(ownerLander.address);
      expect(await flashBorrower.owner()).to.equal(ownerBorrower.address);
    });    
  });  

  describe("Flash loan", function () {
    it("Should be end with success and emit event 'Action1'", async function () {
      const { myStableToken, flashLander, flashBorrower, ownerToken, ownerBorrower } = await loadFixture(deployFlashLoanTest);

      let amount = ethers.parseUnits("1000", "ether");
      let data = ethers.solidityPacked(["uint256"], [1]);
      let Fee = await flashLander.flashFee(myStableToken.target, amount);

      await myStableToken.connect(ownerToken).mint(flashBorrower.target, Fee);

      await expect(flashBorrower.connect(ownerBorrower).flashBorrow(flashLander.target, myStableToken.target, amount, data)).to.emit(flashBorrower, 'Action1');
    }); 

    it("Should revert with 'not an owner!'", async function () {
      const { myStableToken, flashLander, flashBorrower, otherAccount } = await loadFixture(deployFlashLoanTest);

      let amount = ethers.parseUnits("1000", "ether");
      let data = ethers.solidityPacked(["uint256"], [0]);

      await expect(flashBorrower.connect(otherAccount).flashBorrow(flashLander.target, myStableToken.target, amount, data)).to.be.revertedWith("not an owner!");
    });    

    it("Should revert with 'token transfer failed!'", async function () {
      const { myStableToken, flashLander, flashBorrower, ownerBorrower } = await loadFixture(deployFlashLoanTest);

      let amount = ethers.parseUnits("1000", "ether");
      let data = ethers.solidityPacked(["uint256"], [0]);

      await expect(flashBorrower.connect(ownerBorrower).flashBorrow(flashLander.target, myStableToken.target, amount, data)).to.be.revertedWith("token transfer failed!");
    });    

  });  
  
});
