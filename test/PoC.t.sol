// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PoC} from "@src/PoC.sol";
import {IPoC} from "@src/interfaces/IPoC.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestPoC is Test {
    PoC public poc;
    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/eth");
        // Initialize and funds required addresses
        address attacker = makeAddr("attacker");
        poc = new PoC(attacker);
        IPoC.TokenAmounts[] memory amounts = new IPoC.TokenAmounts[](0);

        // Fund it
        poc.fund(amounts);

        // Initial snapshots of balances of tokens
        address[] memory tokens = new address[](0);
        poc.snapshotBalancePre(tokens);
    }

    function testPoC() public {
        poc.attack();

        // Print profit
        poc.prettyPrintProfit();
    }
}