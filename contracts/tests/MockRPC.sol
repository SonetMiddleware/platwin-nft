// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockRPC is ERC20 {
    constructor()ERC20("Mock Res Publica Cash", "mRPC"){
        _mint(msg.sender, 1e10 * (10 ** decimals()));
    }

    function burn(uint amount) public {
        _burn(msg.sender, amount);
    }
}