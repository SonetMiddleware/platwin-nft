// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TestERC20 is ERC20 {

    constructor()ERC20('Test ERC20', 'TT'){
        _mint(msg.sender, 100000000000 * (10 ** 18));
    }
}
