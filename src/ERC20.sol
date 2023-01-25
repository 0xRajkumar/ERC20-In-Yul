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

    function symbol() external pure returns (string memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 2)
            mstore(add(ptr, 0x40), symbolInBytes)
            return(ptr, 0x60)
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
            let totalSupplyBefore := sload(totalSupplySlot)
            let max_uint := sub(exp(2, 256), 1)
            if iszero(iszero(gt(amount, sub(max_uint, totalSupplyBefore)))) {
                revert(0, 0)
            }
            let totalSupplyAfter := add(totalSupplyBefore, amount)
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

    function transfer(address, uint256) public returns (bool) {
        assembly {
            let firstPtr := mload(0x40)
            let to := calldataload(0x4)
            let amount := calldataload(add(0x20, 0x4))
            mstore(0x40, add(firstPtr, 0x40))
            let ptr := mload(0x40)
            mstore(ptr, caller())
            let balanceOfSlot := balanceOf.slot
            mstore(add(ptr, 0x20), balanceOfSlot)
            let slotUser1 := keccak256(ptr, 0x40)
            let User1Balance := sload(slotUser1)
            if iszero(iszero(lt(User1Balance, amount))) {
                revert(0, 0)
            }
            let balanceAfterUser1 := sub(User1Balance, amount)
            sstore(slotUser1, balanceAfterUser1)
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

    function approveMany(
        address[] memory addresses,
        uint256[] memory amounts
    ) public returns (bool) {
        assembly {
            let addrsSize := mload(addresses)
            let amountsSize := mload(amounts)
            if iszero(eq(addrsSize, amountsSize)) {
                revert(0, 0)
            }
            for {
                let i := 0
            } lt(i, addrsSize) {
                i := add(i, 1)
            } {
                let userAddress := mload(add(addresses, mul(0x20, add(i, 1))))
                let amount := mload(add(amounts, mul(0x20, add(i, 1))))
                mstore(0x00, caller())
                let allowanceSlot := allowance.slot
                mstore(0x20, allowanceSlot)
                let slot1 := keccak256(0x00, 0x40)
                mstore(0x00, userAddress)
                mstore(0x20, slot1)
                let slot2 := keccak256(0x00, 0x40)
                sstore(slot2, amount)
            }
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, from)
            let allowanceSlot := allowance.slot
            mstore(add(ptr, 0x20), allowanceSlot)
            let slot1 := keccak256(ptr, 0x40)
            mstore(add(ptr, 0x40), caller())
            mstore(add(ptr, 0x60), slot1)
            let slot2 := keccak256(add(ptr, 0x40), 0x40)
            let allowanceAmount := sload(slot2)
            if iszero(iszero(lt(allowanceAmount, amount))) {
                revert(0, 0)
            }
            sstore(slot2, sub(mload(add(ptr, 0x80)), amount))
            //Updating pointer
            mstore(0x40, add(ptr, 0x80))
            let newPtr := mload(0x40)
            mstore(ptr, from)
            let balanceOfSlot := balanceOf.slot
            mstore(add(ptr, 0x20), balanceOfSlot)
            let slotUser1 := keccak256(ptr, 0x40)
            let user1Balance := sload(slotUser1)
            if iszero(iszero(lt(user1Balance, amount))) {
                revert(0, 0)
            }
            let balanceAfterUser1 := sub(user1Balance, amount)
            sstore(slotUser1, balanceAfterUser1)
            mstore(ptr, to)
            let slotUser2 := keccak256(ptr, 0x40)
            let balanceAfterUser2 := add(sload(slotUser2), amount)
            sstore(slotUser2, balanceAfterUser2)
        }
        return true;
    }

    function burn(address from, uint256 amount) external {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, from)
            let balanceOfSlot := balanceOf.slot
            mstore(add(ptr, 0x20), balanceOfSlot)
            let slot := keccak256(ptr, 0x40)
            let UserBalance := sload(slot)
            if iszero(iszero(lt(UserBalance, amount))) {
                revert(0, 0)
            }
            let balanceAfter := sub(UserBalance, amount)
            sstore(slot, balanceAfter)
            let totalSupplySlot := totalSupply.slot
            let totalSupplyAfter := sub(sload(totalSupplySlot), amount)
            sstore(totalSupplySlot, totalSupplyAfter)
        }
    }
}
