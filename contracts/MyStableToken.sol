// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyStableToken is ERC20 {
    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "not an owner!");
        _;
    }
   
    constructor() ERC20("MyStableToken", "USDM") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner() {
        _mint(to, amount);
    }
    
}