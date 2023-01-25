// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 erc20;

    //Users
    address testUser1 = address(0x1);
    address testUser2 = address(0x2);

    //
    address[] approveTo;
    uint256[] approveAmount;

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

    function testMintShouldRevertOnOverflow() public {
        vm.prank(testUser1);
        erc20.mint(testUser1, 1e18);
        vm.expectRevert();
        erc20.mint(testUser1, type(uint256).max);
    }

    function testTransfer(uint256 testAmount) public {
        vm.startPrank(testUser1);
        erc20.mint(testUser1, testAmount);
        erc20.transfer(testUser2, testAmount);
        uint256 totalSupply = erc20.totalSupply();
        assertEq(totalSupply, testAmount);
        uint256 testUser2Balance = erc20.balanceOf(testUser2);
        assertEq(testUser2Balance, testAmount);
        vm.stopPrank();
    }

    function testTransferShouldRevertOnUnderflow() public {
        uint256 amountMinting = 1e18;
        uint256 amountTransfering = 2e18;
        vm.startPrank(testUser1);
        erc20.mint(testUser1, amountMinting);
        vm.expectRevert();
        erc20.transfer(testUser2, amountTransfering);
        vm.stopPrank();
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

    function testTransferFromShouldRevertOnUnderflowOnLessAllowance() public {
        uint256 allowanceAmount = 1e18;
        uint256 SpendingAmount = 2e18;
        vm.startPrank(testUser1);
        erc20.mint(testUser1, allowanceAmount + SpendingAmount);
        erc20.approve(testUser2, allowanceAmount);
        uint256 checkAllowance = erc20.allowance(testUser1, testUser2);
        assertEq(checkAllowance, allowanceAmount);
        vm.stopPrank();
        vm.startPrank(testUser2);
        vm.expectRevert();
        erc20.transferFrom(testUser1, testUser2, SpendingAmount);
        vm.stopPrank();
    }

    function testTransferFromShouldRevertOnUnderflowOnLessAmount() public {
        uint256 SpendingAmount = 1e18;
        uint256 allowanceAmount = 2e18;
        vm.startPrank(testUser1);
        erc20.mint(testUser1, SpendingAmount);
        erc20.approve(testUser2, allowanceAmount);
        uint256 checkAllowance = erc20.allowance(testUser1, testUser2);
        assertEq(checkAllowance, allowanceAmount);
        vm.stopPrank();
        vm.startPrank(testUser2);
        vm.expectRevert();
        erc20.transferFrom(testUser1, testUser2, allowanceAmount);
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

    function testBurnShouldOnUnderflow() public {
        uint256 amountToMint = 1e18;
        uint256 amountToBurn = 2e18;
        vm.startPrank(testUser1);
        erc20.mint(testUser1, amountToMint);
        assertEq(erc20.totalSupply(), amountToMint);
        assertEq(erc20.balanceOf(testUser1), amountToMint);
        vm.expectRevert();
        erc20.burn(testUser1, amountToBurn);
        vm.stopPrank();
    }

    function testApproveMany() public {
        vm.prank(testUser1);
        uint256 num = 3;
        for (uint160 i = 0; i < num; i++) {
            approveTo.push(address(i + 1));
            approveAmount.push((i + 1) * 1e18);
        }
        erc20.approveMany(approveTo, approveAmount);
        for (uint160 i = 0; i < num; i++) {
            assertEq(
                erc20.allowance(testUser1, address(i + 1)),
                (i + 1) * 1e18
            );
        }
        vm.stopPrank();
    }

    function testApproveManyShouldRevertOnWrongInput() public {
        vm.prank(testUser1);
        uint256 num1 = 3;
        uint256 num2 = 4;
        for (uint160 i = 0; i < num1; i++) {
            approveTo.push(address(i + 1));
        }
        for (uint160 i = 0; i < num2; i++) {
            approveAmount.push((i + 1) * 1e18);
        }
        vm.expectRevert();
        erc20.approveMany(approveTo, approveAmount);
        vm.stopPrank();
    }
}
