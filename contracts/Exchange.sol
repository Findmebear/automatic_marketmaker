// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Exchange {

    event LiquidityProvided(uint amountERC20TokenDeposited, uint amountEthDeposited, uint liquidityPositionsIssued);

    event LiquidityWithdrew(uint amountERC20TokenWithdrew, uint amountEthWithdrew, uint liquidityPositionsBurned);

    event SwapForEth(uint amountERC20TokenDeposited, uint amountEthWithdrew);

    event SwapForERC20Token(uint amountERC20TokenWithdrew, uint amountEthDeposited);

    IERC20 public token;

    uint public balance_address;

    uint public balance_token;
    
    address TOKEN_ADDRESS;
    
    uint K;

    constructor(address token_address) {
        TOKEN_ADDRESS = token_address;
        token = IERC20(token_address);
        balance_address = address(this).balance;
        balance_token = token.balanceOf(address(this));
    }

    uint totalLiquidityPositions; // total number of liquidity positions

    // mapping of liquidity positions
    mapping (address => uint) public liquidityPositions;


    function provideLiquidity(uint _amountERC20Token) public payable returns (uint) {

        require(msg.value > 0, "You must send ETH to provide liquidity");
        require(_amountERC20Token > 0, "You must send ERC20 tokens to provide liquidity");
        require(token.transferFrom(msg.sender, address(this), _amountERC20Token), "You must approve this contract to spend your ERC20 tokens");

        balance_address = address(this).balance;
        balance_token = token.balanceOf(address(this));
        
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

        emit LiquidityProvided(_amountERC20Token, msg.value, currentLiquidityPositions);
        
        return currentLiquidityPositions;
        
    }


    function estimateEthToProvide(uint _amountERC20Token) public view returns (uint) {

        require(_amountERC20Token > 0, "You must send ERC20 tokens to provide liquidity");
        require(token.balanceOf(address(this)) > 0, "There is no liquidity in the pool");
        
        //  amountEth = contractEthBalance * amountERC20Token / contractERC20TokenBalance) - FORMULA
        uint amountEth = address(this).balance * _amountERC20Token / token.balanceOf(address(this));
        return amountEth;

    }


    function estimateERC20TokenToProvide(uint _amountEth) public view returns (uint) {

        require(_amountEth > 0, "You must send ETH to provide liquidity");
        require(address(this).balance > 0, "There is no liquidity in the pool");
        
        // amountERC20 = contractERC20TokenBalance * amountEth/contractEthBalance) - FORMULA
        uint amountERC20 = token.balanceOf(address(this)) *  _amountEth / address(this).balance;
        return amountERC20;
        
    }


    function getMyLiquidityPositions() public view returns (uint) {

        require(liquidityPositions[msg.sender] > 0, "You have no liquidity positions");
        
        return liquidityPositions[msg.sender];
        
    }


    function withdrawLiquidity(uint _liquidityPositionsToBurn) public returns (uint, uint) {

        require(_liquidityPositionsToBurn > 0, "You must burn some liquidity positions");

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

        require(_amountERC20Token > 0, "You must send ERC20 tokens to swap for ETH");
        require(token.balanceOf(address(this)) > 0, "There is no liquidity in the pool");

        /* 
        FORMULA: ethToSend = contractEthBalance - contractEthBalanceAfterSwap
        where contractEthBalanceAfterSwap = K / contractERC20TokenBalanceAfterSwap 
        */

        uint contractEthBalanceAfterSwap = K / (token.balanceOf(address(this)) + _amountERC20Token);
        uint ethToSend = address(this).balance - contractEthBalanceAfterSwap;
        
        // transfer ERC20 token to this contract
        require(token.transferFrom(msg.sender, address(this), _amountERC20Token), "You must approve this contract to spend your ERC20 tokens");
        
        // transfer ETH to the caller
        payable(msg.sender).transfer(ethToSend);
        
        emit SwapForEth(_amountERC20Token, ethToSend);

        return ethToSend;

    }


    function estimateSwapForEth(uint _amountERC20Token) public view returns (uint){

        require(_amountERC20Token > 0, "You must send ERC20 tokens to swap for ETH");
        require(token.balanceOf(address(this)) > 0, "There is no liquidity in the pool");

        // – estimates the amount of Ether to give caller based on amount ERC20 token caller wishes to swap
        // for when a user wants to know how much Ether to expect when calling swapForEth 
        
        uint contractEthBalanceAfterSwap = K / (token.balanceOf(address(this)) + _amountERC20Token);
        uint ethToSend = address(this).balance - contractEthBalanceAfterSwap;
        return ethToSend;

    }


    function swapForERC20Token() payable public returns (uint){

        require(msg.value > 0, "You must send ETH to swap for ERC20 tokens");
        require(address(this).balance > 0, "There is no liquidity in the pool");

        uint ERC20TokenToSend = token.balanceOf(address(this)) - (K / (address(this).balance + msg.value));

        token.transfer(msg.sender, ERC20TokenToSend);

        emit SwapForERC20Token(ERC20TokenToSend, msg.value);

        return ERC20TokenToSend;

    }


    function estimateSwapForERC20Token(uint _amountEth) public view returns (uint) {

        require(_amountEth > 0, "You must send ETH to swap for ERC20 tokens");
        require(address(this).balance > 0, "There is no liquidity in the pool");
        
        /*– estimates the amount of ERC20 token to give caller based on amount Ether caller wishes to
        swap for when a user wants to know how many ERC-20 tokens to expect when calling swapForERC20Token */
        // ERC20TokenToSend = contractERC20TokenBalance - contractERC20TokenBalanceAfterSwap
        // where contractERC20TokenBalanceAfterSwap = K /contractEthBalanceAfterSwap

        uint contractERC20TokenBalanceAfterSwap = K / (address(this).balance + _amountEth);

        uint ERC20TokenToSend = token.balanceOf(address(this)) - contractERC20TokenBalanceAfterSwap;

        return ERC20TokenToSend;

    }
}