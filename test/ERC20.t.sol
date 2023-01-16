// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 erc20;

    function setUp() public {
        erc20 = new ERC20();
    }

    function testerc20() public {
        assertEq(erc20.name(), "Token-ERC20");
        assertEq(erc20.symbol(), "TE");
        assertEq(erc20.decimals(), 18);
    }

    function testMint() public {
        erc20.mint(address(this), 1000);
        assertEq(erc20.totalSupply(), 1000);
        assertEq(erc20.balanceOf(address(this)), 1000);
    }

    function testTransfer() public {
        erc20.mint(address(this), 1000);
        erc20.transfer(address(0x1), 1000);
        assertEq(erc20.totalSupply(), 1000);
        assertEq(erc20.balanceOf(address(0x1)), 1000);
    }

    function testApprove() public {
        erc20.approve(address(0x1), 1000);
        assertEq(erc20.allowance(address(this), address(0x1)), 1000);
    }

    function testTransferFrom() public {
        erc20.mint(address(this), 1000);
        erc20.approve(address(0x1), 1000);
        assertEq(erc20.allowance(address(this), address(0x1)), 1000);
        vm.startPrank(address(0x1));
        erc20.transferFrom(address(this), address(0x2), 1000);
        assertEq(erc20.balanceOf(address(0x2)), 1000);
    }

    function testBurn() public {
        erc20.mint(address(this), 1000);
        assertEq(erc20.totalSupply(), 1000);
        assertEq(erc20.balanceOf(address(this)), 1000);
        erc20.burn(address(this), 1000);
        assertEq(erc20.totalSupply(), 0);
        assertEq(erc20.balanceOf(address(this)), 0);
    }
}
