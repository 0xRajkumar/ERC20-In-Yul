// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ERC20 {
    // METADATA
    bytes32 private constant nameInBytes =
        0x546f6b656e2d4552433230000000000000000000000000000000000000000000;

    bytes32 private constant symbolInBytes =
        0x5445000000000000000000000000000000000000000000000000000000000000;

    uint256 private _decimals = 18;

    // ERC20 STORAGE
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

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

    function mint(address to, uint256 amount) external {
        assembly {
            let totalSupplySlot := totalSupply.slot
            let totalSupplyAfter := add(sload(totalSupplySlot), amount)
            sstore(totalSupplySlot, totalSupplyAfter)

            let ptr := mload(0x40)
            mstore(ptr, caller())
            let balanceOfSlot := balanceOf.slot
            mstore(add(ptr, 0x20), balanceOfSlot)
            let slot := keccak256(ptr, 0x40)
            let balanceAfter := add(sload(slot), amount)
            sstore(slot, balanceAfter)
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, caller())
            let balanceOfSlot := balanceOf.slot
            mstore(add(ptr, 0x20), balanceOfSlot)
            let slotUser1 := keccak256(ptr, 0x40)
            let balanceAfterUser1 := sub(sload(slotUser1), amount)
            sstore(slotUser1, balanceAfterUser1)
            //
            mstore(ptr, to)
            let slotUser2 := keccak256(ptr, 0x40)
            let balanceAfterUser2 := add(sload(slotUser2), amount)
            sstore(slotUser2, balanceAfterUser2)
        }
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, caller())
            let allowanceSlot := allowance.slot
            mstore(add(ptr, 0x20), allowanceSlot)
            let slot1 := keccak256(ptr, 0x40)
            mstore(add(ptr, 0x40), spender)
            mstore(add(ptr, 0x60), slot1)
            let slot2 := keccak256(add(ptr, 0x40), 0x40)
            sstore(slot2, amount)
        }
        return true;
    }
}
