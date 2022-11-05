// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange {

    event LiquidityProvided(uint amountERC20TokenDeposited, uint amountEthDeposited, uint liquidityPositionsIssued);

    event LiquidityWithdrew(uint amountERC20TokenWithdrew, uint amountEthWithdrew, uint liquidityPositionsBurned);

    event SwapForEth(uint amountERC20TokenDeposited, uint amountEthWithdrew);

    event SwapForERC20Token(uint amountERC20TokenWithdrew, uint amountEthDeposited);

    IERC20 public immutable token;
    
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


    function provideLiquidity(uint _amountERC20Token) payable public returns (uint) {

        token.transferFrom(msg.sender, address(this), _amountERC20Token); // transfer ERC20 token to this contract
        owner.transfer(msg.value); // transfer the ETH to the contract
        
        uint currentLiquidityPositions;
        
        // Check if no liquidity positions in map or total is zero
        if (totalLiquidityPositions == 0) {
            currentLiquidityPositions = 100;
        } else {
            // Update liquidity position
            currentLiquidityPositions = totalLiquidityPositions * _amountERC20Token / token.balanceOf(address(this));
        }
        
        // provide liquidity positions
        liquidityPositions[msg.sender] += currentLiquidityPositions;
        totalLiquidityPositions += currentLiquidityPositions;

        // update K
        K = address(this).balance * token.balanceOf(address(this));

        emit LiquidityProvided(_amountERC20Token, msg.value ,currentLiquidityPositions);
        
        return currentLiquidityPositions;
        
    }


    function estimateEthToProvide(uint _amountERC20Token) public view returns (uint) {
        //  amountEth = contractEthBalance * amountERC20Token / contractERC20TokenBalance) - FORMULA
        uint amountEth = address(this).balance * _amountERC20Token / token.balanceOf(address(this));
        return amountEth;
    }


    function estimateERC20TokenToProvide(uint _amountEth) public view returns (uint) {
        // amountERC20 = contractERC20TokenBalance * amountEth/contractEthBalance) - FORMULA
        uint amountERC20 = token.balanceOf(address(this)) *  _amountEth / address(this).balance;
        return amountERC20;
        
    }


    function getMyLiquidityPositions() public view returns (uint) {
        
        return liquidityPositions[msg.sender];
        
    }


    function withdrawLiquidity(uint _liquidityPositionsToBurn) public returns (uint, uint) {
        // amountEthToSend = liquidityPositionsToBurn*contractEthBalance / totalLiquidityPositions - FORMULA
        // amountERC20ToSend = liquidityPositionsToBurn * contractERC20TokenBalance / totalLiquidityPositions - FORMULA

        uint amountEthToSend =  _liquidityPositionsToBurn * address(this).balance / totalLiquidityPositions;
        uint amountERC20ToSend = _liquidityPositionsToBurn * token.balanceOf(address(this)) / totalLiquidityPositions;

        // check if liquidity positions to burn is greater than liquidity positions of the sender
        require(liquidityPositions[msg.sender] >= _liquidityPositionsToBurn, "You don't have enough liquidity positions to burn");

        // check if liquidity positions to burn is less than total liquidity positions
        require(totalLiquidityPositions > _liquidityPositionsToBurn, "Contract is broke on liquidity positions, RUN IT BACK OR SPIN THE BLOCK");
        
        // update liquidity positions
        liquidityPositions[msg.sender] -= _liquidityPositionsToBurn;
        totalLiquidityPositions -= _liquidityPositionsToBurn;

        // transfer ERC20 token to the sender
        token.transfer(msg.sender, amountERC20ToSend);
        
        // transfer ETH to the sender
        payable(msg.sender).transfer(amountEthToSend);

        // update K
        K = address(this).balance * token.balanceOf(address(this));

        emit LiquidityWithdrew(amountERC20ToSend, amountEthToSend, _liquidityPositionsToBurn);

        return (amountEthToSend, amountERC20ToSend);

    }


    function swapForEth(uint _amountERC20Token) public returns (uint) {
        /* 
        FORMULA: ethToSend = contractEthBalance - contractEthBalanceAfterSwap
        where contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap 
        */

        uint contractEthBalanceAfterSwap = K / (token.balanceOf(address(this)) - _amountERC20Token);
        uint ethToSend = address(this).balance - contractEthBalanceAfterSwap;
        
        // transfer ERC20 token to this contract
        token.transferFrom(msg.sender, address(this), _amountERC20Token);
        
        // transfer ETH to the caller
        payable(msg.sender).transfer(ethToSend);
        
        emit SwapForEth(_amountERC20Token, ethToSend);

        return ethToSend;
    }


    function estimateSwapForEth(uint _amountERC20Token) public view returns (uint){
        // – estimates the amount of Ether to give caller based on amount ERC20 token caller wishes to swap
        // for when a user wants to know how much Ether to expect when calling swapForEth 
        
        uint contractEthBalanceAfterSwap = K / (token.balanceOf(address(this)) - _amountERC20Token);
        uint ethToSend = address(this).balance - contractEthBalanceAfterSwap;
        
        return ethToSend;
        
    }


    function swapForERC20Token() payable public returns (uint){
        
        owner.transfer(msg.value);

        uint ERC20TokenToSend = token.balanceOf(address(this)) - (K / address(this).balance);

        token.transfer(msg.sender, ERC20TokenToSend);

        emit SwapForERC20Token(ERC20TokenToSend, msg.value);

        return ERC20TokenToSend;

    }


    function estimateSwapForERC20Token(uint _amountEth) public view returns (uint) {
        /*– estimates the amount of ERC20 token to give caller based on amount Ether caller wishes to
        swap for when a user wants to know how many ERC-20 tokens to expect when calling swapForERC20Token */
        // ERC20TokenToSend = contractERC20TokenBalance - contractERC20TokenBalanceAfterSwap
        // where contractERC20TokenBalanceAfterSwap = K /contractEthBalanceAfterSwap

        uint contractERC20TokenBalanceAfterSwap = K / (address(this).balance - _amountEth);

        uint ERC20TokenToSend = token.balanceOf(address(this)) - contractERC20TokenBalanceAfterSwap;

        return ERC20TokenToSend;

    }
}