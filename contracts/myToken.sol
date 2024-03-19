// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract myToken is ERC20 {
    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    constructor() ERC20("myStableToken", "USDM") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
}