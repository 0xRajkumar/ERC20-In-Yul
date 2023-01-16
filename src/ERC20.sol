// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ERC20 {
    bytes32 private constant nameInBytes =
        0x546f6b656e2d4552433230000000000000000000000000000000000000000000;

    bytes32 private constant symbolInBytes =
        0x5445000000000000000000000000000000000000000000000000000000000000;

    uint256 private _decimals = 18;

    function name() external pure returns (string memory name_) {
        assembly {
            name_ := mload(0x40)
            mstore(name_, 11)
            mstore(add(name_, 0x20), nameInBytes)
            mstore(0x40, add(name_, 0x40))
        }
    }

    function symbol() external pure returns (string memory symbol_) {
        assembly {
            symbol_ := mload(0x40)
            mstore(symbol_, 2)
            mstore(add(symbol_, 0x20), symbolInBytes)
            mstore(0x40, add(symbol_, 0x40))
        }
    }

    function decimals() public view returns (uint256) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, sload(_decimals.slot))
            return(ptr, 0x20)
        }
    }
}
