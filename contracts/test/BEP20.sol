// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

import '../SDBswapBEP20.sol';

contract BEP20 is SDBswapBEP20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
