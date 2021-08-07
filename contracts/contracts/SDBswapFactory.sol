//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;

import './interfaces/ISDBswapFactory.sol';
import './SDBswapPair.sol';

contract SDBswapFactory is ISDBswapFactory {

    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(SDBswapPair).creationCode));

    address public override feeTo;
    address public override feeToSetter;

    mapping(address => mapping(address => address)) override public getPair;
    address[]override public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() override external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override   returns (address pair) {
        require(tokenA != tokenB, 'Pancake: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Pancake: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Pancake: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(SDBswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        SDBswapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo)  external  override  {//timelock add
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter)  external override {
        require(msg.sender == feeToSetter, 'Pancake: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}