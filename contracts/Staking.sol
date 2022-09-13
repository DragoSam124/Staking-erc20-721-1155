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

    
    mapping(address => uint256[]) public stakingERC1155Users;
    mapping(address => uint256[]) public stakingERC721Users;
    mapping(address => uint256[]) public staking1155Tokeninfo;
    mapping(address => uint256) public stakingERC20Users;

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
        stakingERC20Users[msg.sender] += amount;
    }

    function DepositERC721(uint256 tokenId) external {
        erc721.transferFrom(msg.sender, address(this), tokenId);
        stakingERC721Users[msg.sender].push(tokenId);
    }

    function DepositERC1155(uint256 tokenId, uint256 amount, bytes calldata data) external {
        erc1155.safeTransferFrom(msg.sender, address(this), tokenId, amount, data);
        uint256 idx;
        for(idx = 0; idx < staking1155Tokeninfo[msg.sender].length; idx++) {
            if(staking1155Tokeninfo[msg.sender][idx] == tokenId) break;
        }

        if(idx == staking1155Tokeninfo[msg.sender].length) {
            staking1155Tokeninfo[msg.sender].push(tokenId);
            stakingERC1155Users[msg.sender].push(amount);
        } else {
            staking1155Tokeninfo[msg.sender][idx] += tokenId;
            stakingERC1155Users[msg.sender][idx] += amount;
        }
    }

    function Withdraw() external {
        if(stakingERC20Users[msg.sender] > 0) {
            erc20.transfer(msg.sender, stakingERC20Users[msg.sender]);
        }

        if(stakingERC721Users[msg.sender].length > 0) {
            for(uint256 i = 0; i < stakingERC721Users[msg.sender].length; i++) {
                erc721.transferFrom(address(this), msg.sender, stakingERC721Users[msg.sender][i]);
            }
        }

        if(staking1155Tokeninfo[msg.sender].length > 0) {
            erc1155.safeBatchTransferFrom(address(this), msg.sender, staking1155Tokeninfo[msg.sender], stakingERC1155Users[msg.sender], "");
        }

        delete stakingERC20Users[msg.sender];
        delete stakingERC721Users[msg.sender];
        delete staking1155Tokeninfo[msg.sender];
        delete stakingERC1155Users[msg.sender];
    }

    function balanceOf1155(address owner) external view returns(uint256[] memory, uint256[] memory) {
        return (staking1155Tokeninfo[owner], stakingERC1155Users[owner]);
    }

    function balanceOf20(address owner) external view returns(uint256) {
        return stakingERC20Users[owner];
    }

    function balanceOf721(address owner) external view returns(uint256[] memory) {
        return (stakingERC721Users[owner]);
    }
}