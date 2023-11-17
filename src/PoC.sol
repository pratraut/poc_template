// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.19;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IPoC} from "@src/interfaces/IPoC.sol";
import {Test, console} from "forge-std/Test.sol";

contract PoC is IPoC, Test {
    /// @notice starting hacker token amounts
    IPoC.TokenAmounts[] public tokenAmounts;

    /// @notice the attacker address, could be this contract if no exploit is written
    address public immutable attacker;

    /// @notice set the attacker address
    constructor(address _attacker) {
        attacker = _attacker == address(0) ? address(this) : _attacker;
    }

    /// @notice step one, fund the contract with different tokens and amounts
    /// @param amounts the list of tokens and amounts to send to the attacker.
    function fund(IPoC.TokenAmounts[] calldata amounts) external {
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i].amount >= 0, "PoC: negative deal amount");
            if (amounts[i].token == address(0)) {
                deal(attacker, uint256(amounts[i].amount));
            } else {
                deal(amounts[i].token, attacker, uint256(amounts[i].amount));
            }
        }
    }

    /// @notice step two, snapshot the balance of the attacker, records balance
    /// of all tokens tracked pre-attack
    /// @param tokens the list of tokens to snapshot the balance of
    function snapshotBalancePre(address[] calldata tokens) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 tokenBalance = 0;
            if (tokens[i] == address(0)) {
                tokenBalance = attacker.balance;
            } else {
                tokenBalance = IERC20(tokens[i]).balanceOf(attacker);
            }
            
            require(
                tokenBalance <= uint256(type(int256).max),
                "PoC: balance too large"
            );
            tokenAmounts.push(
                IPoC.TokenAmounts(tokens[i], int256(tokenBalance))
            );
        }
    }

    /// @notice step three, attack the contract, perform all necessary attack steps
    function attack() public {
        /// TODO perform attack
        /// if there is an attack contract, call it here, otherwise craft and execute the exploit here
    }

    /// @notice returns the profit from the attack
    function profit() public view returns (IPoC.TokenAmounts[] memory) {
        IPoC.TokenAmounts[] memory profits = new IPoC.TokenAmounts[](
            tokenAmounts.length
        );
        for (uint256 i = 0; i < tokenAmounts.length; i++) {
            int256 attackProfit;
            if (tokenAmounts[i].token == address(0)) {
                attackProfit = int256(
                    attacker.balance - uint256(tokenAmounts[i].amount)
                );
            } else {
                attackProfit = int256(
                    IERC20(tokenAmounts[i].token).balanceOf(attacker)
                ) - tokenAmounts[i].amount;
            }
            
            profits[i] = IPoC.TokenAmounts(tokenAmounts[i].token, attackProfit);
        }

        return profits;
    }

    /// @notice prints the profit from the attack
    function prettyPrintProfit() external {
        IPoC.TokenAmounts[] memory profits = profit();
        for (uint256 i = 0; i < profits.length; i++) {
            if (i == 0) {
                console.log("Profits:");
                console.log("============================================");
            }
            if (profits[i].token == address(0)) {
                emit log_named_decimal_int("ETH", profits[i].amount, 18);
            } else {
                string memory symbol = IERC20(profits[i].token).symbol();
                emit log_named_decimal_int(symbol, profits[i].amount, IERC20(profits[i].token).decimals());
            }
        }
    }
}