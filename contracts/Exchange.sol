// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Exchange is ERC20 {

    address ASA_ADDRESS = 0x1A5Cf8a4611CA718B6F0218141aC0Bfa114AAf7D;
    address KOR_ADDRESS = 0x0B09AC43C6b788146fe0223159EcEa12b2EC6361;
    address HAW_ADDRESS = 0x42cD7B2c632E3F589933275095566DE6d8c1bfa5;
    address TOKEN_ADDRESS;

    uint K;

    address payable public owner;


    constructor(uint256 initialSupply) ERC20("AsaToken", "ASA") {
        owner = payable(msg.sender);
        TOKEN_ADDRESS = ASA_ADDRESS;
        _mint(msg.sender, initialSupply);
    }
    
    uint totalLiquidityPositions; // total number of liquidity positions

    // mapping of liquidity positions
    mapping (address => uint) public liquidityPositions;

    // Jouny
    function provideLiquidity(uint _amountERC20Token) payable public {

        transfer(address(this), _amountERC20Token);
        owner.transfer(msg.value);

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

    // Jouny
    function estimetaEthToProvide(uint _amountERC20Token) public {

    }

    // Jouny
    function estimateERC20TokenToProvide(uint _amountEth) public {

    }


    function getMyLiquidityPositions() public {

    }


    function withdrawLiquidity(uint _liquidityPositionsToBurn) public {

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