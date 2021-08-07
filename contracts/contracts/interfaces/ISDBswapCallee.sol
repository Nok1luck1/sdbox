//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;

interface ISDBswapCallee {
    function sdbswapCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
