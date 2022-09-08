const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const {BigNumber} = require('ethers')


describe("Staking", function () {
  async function deploy() {

    const [owner, addr1, addr2] = await ethers.getSigners();

    const ERC20 = await ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy("Drago Sam", "KKK");
    await erc20.deployed();

    const ERC721 = await ethers.getContractFactory("ERC721");
    const erc721 = await ERC721.deploy("Drago Sam", "KKK");
    await erc721.deployed();

    const ERC1155 = await ethers.getContractFactory("ERC1155");
    const erc1155 = await ERC1155.deploy("HTTPESL//myURI/");
    await erc1155.deployed();

    const STAKING = await ethers.getContractFactory("Staking");
    const Staking = await STAKING.deploy();
    await Staking.deployed();

    return { erc20, erc721, erc1155, Staking, owner, addr1, addr2 };
  }

  describe("Deployment", async function () {
    it("Should be start staking", async function () {
      const {erc20, erc721, erc1155, Staking, owner, addr1, addr2} = await deploy();
      await Staking.start(erc20.address, erc721.address, erc1155.address);
    });
    it("Should be deposit, withdraw 20, 721, 1155", async function () {
      const {erc20, erc721, erc1155, Staking, owner, addr1, addr2} = await deploy();
      await Staking.start(erc20.address, erc721.address, erc1155.address);

      await erc20.mint(owner.address, BigNumber.from("10000"));
      await erc20.approve(Staking.address, BigNumber.from("10000"));
      await Staking.DepositERC20(BigNumber.from("10000"));
      console.log("This is erc20 balance: ", await Staking.balanceOf20(owner.address));

      await erc721.mint(owner.address, BigNumber.from("0"));
      await erc721.approve(Staking.address, BigNumber.from("0"));
      await Staking.DepositERC721(BigNumber.from("0"));
      console.log("This is erc721 balance: ", await Staking.balanceOf721(owner.address));

      await erc1155.mint(owner.address, BigNumber.from("0"), BigNumber.from("10000"), []);
      await erc1155.setApprovalForAll(Staking.address, true)
      await Staking.DepositERC1155(BigNumber.from("0"), BigNumber.from("10000"), []);
      console.log("This is erc1155 balance: ", await Staking.balanceOf1155(owner.address));

      await Staking.Withdraw();

      console.log("After withdraw-> erc20: ", await Staking.balanceOf20(owner.address));
      console.log("After withdraw-> erc721: ", await Staking.balanceOf721(owner.address));
      console.log("After withdraw-> erc1155: ", await Staking.balanceOf1155(owner.address));
    });
  });
});
