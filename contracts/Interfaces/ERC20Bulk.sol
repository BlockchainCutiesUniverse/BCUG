// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC20Bulk  {
    function transferBulk(address[] calldata to, uint[] calldata tokens) external;
    function approveBulk(address[] calldata spender, uint[] calldata tokens) external;
}
