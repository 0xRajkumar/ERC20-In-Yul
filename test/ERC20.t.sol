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
}
