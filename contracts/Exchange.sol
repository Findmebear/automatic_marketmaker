// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// Link: https://youtu.be/RcvJtGZg3v4

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange{

    IERC20 public immutable token;

    // address ASA_ADDRESS = 0x1A5Cf8a4611CA718B6F0218141aC0Bfa114AAf7D;
    // address KOR_ADDRESS = 0x0B09AC43C6b788146fe0223159EcEa12b2EC6361;
    // address HAW_ADDRESS = 0x42cD7B2c632E3F589933275095566DE6d8c1bfa5;
    address TOKEN_ADDRESS;

    uint K;

    address payable public owner;

    constructor(address token_address) {
        owner = payable(msg.sender);
        TOKEN_ADDRESS = token_address;
        token = IERC20(token_address);
    }

    uint totalLiquidityPositions; // total number of liquidity positions

    // mapping of liquidity positions
    mapping (address => uint) public liquidityPositions;


    // Jouny
    function provideLiquidity(uint _amountERC20Token) payable public {

        token.transfer(address(this), _amountERC20Token);
        // owner.transfer(msg.value);

        uint currentLiquidityPositions;
        
        // Check if no liquidity positions in map or total is zero
        if (totalLiquidityPositions == 0) {
            currentLiquidityPositions = 100;
        } else {
            // Update liquidity position
            currentLiquidityPositions = totalLiquidityPositions * _amountERC20Token / ERC20(TOKEN_ADDRESS).balanceOf(address(this));
        }
        
        liquidityPositions[msg.sender] += currentLiquidityPositions;
        totalLiquidityPositions += currentLiquidityPositions;

        // If so, we give the sender address 100 liquidity positions and store in map and increase total
        // otherwise liquiditypositions = totalLiquidityPositions * _amountERC20Token / contractERC20TokenBalance
        // Update k

        K = address(this).balance * ERC20(TOKEN_ADDRESS).balanceOf(address(this));

    }


    function estimetaEthToProvide(uint _amountERC20Token) public view returns (uint) {
        uint amountEth = address(this).balance * _amountERC20Token / ERC20(TOKEN_ADDRESS).balanceOf(address(this));
        return amountEth;
    }

    function estimateERC20TokenToProvide(uint _amountEth) public view returns (uint) {
        uint amountERC20 = ERC20(TOKEN_ADDRESS).balanceOf(address(this)) *  _amountEth / address(this).balance;
        return amountERC20;
    }

    function getMyLiquidityPositions() public view returns (uint) {
        return liquidityPositions[msg.sender];
    }


    function withdrawLiquidity(uint _liquidityPositionsToBurn) public {
        //unit amountEthToSend =  _liquidityPositionsToBurn * address(this).balance / totalLiquidityPositions;
        //unit amountERC20ToSend = -liquidityPositionsToBurn * ERC20(TOKEN_ADDRESS).balanceOf(address(this)) / totalLiquidityPosition;
        //
    }


    function swapForEth(uint _amountERC20Token) public {

    }


    function estimateSwapForEth(uint _amountERC20Token) public {

    }


    function swapForERC20Token() public {

    }


    function estimateSwapForERC20Token(uint _amountEth) public {

    }


}

// event LiquidityProvided(uint amountERC20TokenDeposited, uint amountEthDeposited, uint liquidityPositionsIssued)

// event LiquidityWithdrew(uint amountERC20TokenWithdrew, uint amountEthWithdrew, uint liquidityPositionsBurned)

// event SwapForEth(uint amountERC20TokenDeposited, uint amountEthWithdrew)

// event SwapForERC20Token(uint amountERC20TokenWithdrew, uint amountEthDeposited)