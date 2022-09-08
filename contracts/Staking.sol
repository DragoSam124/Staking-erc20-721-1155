// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Staking {
    IERC20 public erc20;
    IERC721 public erc721;
    IERC1155 public erc1155;
    bool private openStaking = false;

    struct Staker{
        uint256 token20;
        uint256[] token721;
        uint256[] token1155;
        uint256[] token1155Amt;    
    }

    mapping(address => Staker) private balance;

    constructor() {    
    }

    function start(address erc20_, address erc721_, address erc1155_) public {
        erc20 = IERC20(erc20_);
        erc721 = IERC721(erc721_);
        erc1155 = IERC1155(erc1155_);
        openStaking = true;
    }

    function DepositERC20(uint256 amount) external {
        erc20.transferFrom(msg.sender, address(this), amount);
        balance[msg.sender].token20 += amount;
    }

    function DepositERC721(uint256 tokenId) external {
        erc721.transferFrom(msg.sender, address(this), tokenId);
        balance[msg.sender].token721.push(tokenId);
    }

    function DepositERC1155(uint256 tokenId, uint256 amount, bytes calldata data) external {
        erc1155.safeTransferFrom(msg.sender, address(this), tokenId, amount, data);
        uint256 idx;
        for(idx = 0; idx < balance[msg.sender].token1155.length; idx++) {
            if(balance[msg.sender].token1155[idx] == tokenId) break;
        }

        if(idx == balance[msg.sender].token1155.length) {
            balance[msg.sender].token1155.push(tokenId);
            balance[msg.sender].token1155Amt.push(amount);
        } else {
            balance[msg.sender].token1155Amt[idx] += amount;
        }
    }

    function Withdraw() external {
        if(balance[msg.sender].token20 > 0) {
            erc20.transfer(msg.sender, balance[msg.sender].token20);
        }

        if(balance[msg.sender].token721.length > 0) {
            for(uint256 i = 0; i < balance[msg.sender].token721.length; i++) {
                erc721.transferFrom(address(this), msg.sender, balance[msg.sender].token721[i]);
            }
        }

        if(balance[msg.sender].token1155.length > 0) {
            erc1155.safeBatchTransferFrom(address(this), msg.sender, balance[msg.sender].token1155, balance[msg.sender].token1155Amt, "");
        }

        delete balance[msg.sender];
    }

    function balanceOf1155(address owner) external view returns(uint256[] memory, uint256[] memory) {
        return (balance[owner].token1155, balance[owner].token1155Amt);
    }

    function balanceOf20(address owner) external view returns(uint256) {
        return balance[owner].token20;
    }

    function balanceOf721(address owner) external view returns(uint256[] memory) {
        return (balance[owner].token721);
    }
}