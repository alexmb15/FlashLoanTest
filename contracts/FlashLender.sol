// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC3156FlashBorrower} from "./IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "./IERC3156FlashLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract FlashLander is IERC3156FlashLender {
    address tokenAddress;
  
    bytes32 private constant RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");
    

    event FlashLoan(
        IERC3156FlashBorrower indexed receiver,
        address indexed token,
        uint256 value,
        uint256 fee,
        uint256 timestamp
    );

    error ERC3156UnsupportedToken(address token);
    error ERC3156ExceededMaxLoan(uint256 maxLoan);
    error ERC3156InvalidReceiver(address receiver);

    constructor(address token){
        tokenAddress = token;    
    }

    function maxFlashLoan(address token) public view virtual returns (uint256) {
        return token == tokenAddress ? IERC20(token).balanceOf(address(this)) : 0;
    }

    function flashFee(address token, uint256 value) public view virtual returns (uint256) {
        if (token != tokenAddress) {
            revert ERC3156UnsupportedToken(token);
        }

        return _flashFee(token, value);
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 value,
        bytes calldata data
    ) public virtual returns (bool) {

        //check that the reserve has enough available liquidity
        uint256 availableLiquidityBefore = maxFlashLoan(token);

        if (value > availableLiquidityBefore) {
            revert ERC3156ExceededMaxLoan(availableLiquidityBefore);
        }

        uint256 fee = flashFee(token, value);

        IERC20(tokenAddress).transferFrom(address(this), address(receiver), value);

        if (receiver.onFlashLoan(msg.sender, token, value, fee, data) != RETURN_VALUE) {
            revert ERC3156InvalidReceiver(address(receiver));
        }

        address flashFeeReceiver = _flashFeeReceiver();
        if(flashFeeReceiver != address(this))
           IERC20(tokenAddress).transferFrom(address(this), flashFeeReceiver, fee);

        //check that the actual balance of the core contract includes the returned amount
        uint256 availableLiquidityAfter = IERC20(token).balanceOf(address(this));

        require(
            availableLiquidityAfter == availableLiquidityBefore + fee,
            "The actual balance of the protocol is inconsistent"
        );  

        emit FlashLoan(receiver, token, value, fee, block.timestamp);

        return true;
    }

    function _flashFee(address token, uint256 value) internal view virtual returns (uint256) {

      if(token == tokenAddress)
        return (value*9/10000);
      else
        return 0;

    }

    function _flashFeeReceiver() internal view virtual returns (address) {
        return address(this);
    }
}