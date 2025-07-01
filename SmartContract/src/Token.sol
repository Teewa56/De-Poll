// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


/*
openzeppelin import and ownable contract import
erc20 for fungible tokens and erc721 for non-fungible tokens
*/

contract Token is ERC20, Ownable {
    address owmer = msg.sender;
    constructor() ERC20("VotingToken", "DE-VOTE") Ownable(_owner) {
        _mint(_owner, 1_000_000 * 10 ** decimals());
    }

    function transfer(address to, uint256 amount) external onlyOwner {
        _transfer(to, amount);
    }
    
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
