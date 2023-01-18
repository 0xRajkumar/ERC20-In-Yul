// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 erc20;

    //Users
    address testUser1 = address(0x1);
    address testUser2 = address(0x2);

    function setUp() public {
        erc20 = new ERC20();
    }

    function testSetUp() public {
        assertEq(erc20.name(), "Token-ERC20");
        assertEq(erc20.symbol(), "TE");
        assertEq(erc20.decimals(), 18);
    }

    function testMint(uint256 testAmount) public {
        vm.prank(testUser1);
        erc20.mint(testUser1, testAmount);
        uint256 totalSupply = erc20.totalSupply();
        assertEq(totalSupply, testAmount);
        uint256 testUser1Balance = erc20.balanceOf(testUser1);
        assertEq(testUser1Balance, testAmount);
        vm.stopPrank();
    }

    function testTransfer(uint256 testAmount) public {
        vm.startPrank(testUser1);
        erc20.mint(testUser1, testAmount);
        erc20.transfer(testUser2, testAmount);
        uint256 totalSupply = erc20.totalSupply();
        assertEq(totalSupply, testAmount);
        uint256 testUser2Balance = erc20.balanceOf(testUser2);
        assertEq(testUser2Balance, testAmount);
    }

    function testApprove(uint256 testAmount) public {
        vm.startPrank(testUser1);
        erc20.approve(testUser2, testAmount);
        uint256 checkAllowance = erc20.allowance(testUser1, testUser2);
        assertEq(checkAllowance, testAmount);
        vm.stopPrank();
    }

    function testTransferFrom(uint256 testAmount1, uint256 testAmount2) public {
        (testAmount1, testAmount2) = testAmount1 > testAmount2
            ? (testAmount1, testAmount2)
            : (testAmount2, testAmount1);
        vm.startPrank(testUser1);
        erc20.mint(testUser1, testAmount1);
        erc20.approve(testUser2, testAmount1);
        uint256 checkAllowance = erc20.allowance(testUser1, testUser2);
        assertEq(checkAllowance, testAmount1);
        vm.stopPrank();
        vm.startPrank(testUser2);
        erc20.transferFrom(testUser1, testUser2, testAmount2);
        uint256 balanceOfUser1 = erc20.balanceOf(testUser1);
        uint256 balanceOfUser2 = erc20.balanceOf(testUser2);
        assertEq(balanceOfUser1, testAmount1 - testAmount2);
        assertEq(balanceOfUser2, testAmount2);
        vm.stopPrank();
    }

    function testBurn(uint256 testAmount1, uint256 testAmount2) public {
        (testAmount1, testAmount2) = testAmount1 > testAmount2
            ? (testAmount1, testAmount2)
            : (testAmount2, testAmount1);
        vm.startPrank(testUser1);
        erc20.mint(testUser1, testAmount1);
        assertEq(erc20.totalSupply(), testAmount1);
        assertEq(erc20.balanceOf(testUser1), testAmount1);
        erc20.burn(testUser1, testAmount2);
        assertEq(erc20.totalSupply(), testAmount1 - testAmount2);
        assertEq(erc20.balanceOf(testUser1), testAmount1 - testAmount2);
        vm.stopPrank();
    }
}
