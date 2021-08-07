//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;

import '../math/SafeMath.sol';

// used for testing the logic of token naming
contract SafeMathTest {
    function sqrt(uint256 num) public pure returns (uint256) {
        return SafeMath.sqrt(num);
    }
}
