// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import {IERC3156FlashBorrower} from "./IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "./IERC3156FlashLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashBorrower is IERC3156FlashBorrower {

    address public owner;
    IERC3156FlashLender lender;

    modifier onlyOwner() {
        require(owner == msg.sender, "not an owner!");
        _;
    }


    error ERC3156UntrustedLender(address lender);
    error ERC3156UntrustedInitiator(address initiator);

    event Action1(address borrower, address token, uint amount, uint fee);
    event DefaultAction(address borrower, address token, uint amount, uint fee, bytes data);

    constructor () {
       owner = msg.sender;
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns(bytes32) {

        if(initiator != address(this)) {
            revert ERC3156UntrustedInitiator(initiator);
        }

        if(msg.sender != address(lender)) {
            revert ERC3156UntrustedLender(msg.sender);
        }   
        
        require(amount <= IERC20(token).balanceOf(address(this)), "Invalid balance, was the flashLoan successful?");        

        (uint action) = abi.decode(data, (uint));
//        console.log(token);
        if (action == 1) {
            emit Action1(address(this), token, amount, fee);
        } else {
            emit DefaultAction(address(this), token, amount, fee, data);
        }


        uint totalDebt = amount + fee;
	    bytes memory functionCallData = abi.encodeWithSelector(IERC20.transfer.selector, address(lender), totalDebt);        
	    (bool success, bytes memory returnData) = token.call(functionCallData);        
        require(success, "token transfer failed!");

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function flashBorrow(address lenderAddress, address token, uint256 amount, bytes memory data) public onlyOwner() {
   
	    lender = IERC3156FlashLender(lenderAddress);
        IERC3156FlashBorrower receiver = IERC3156FlashBorrower(address(this));

        lender.flashLoan(receiver, token, amount, data);

    }
}