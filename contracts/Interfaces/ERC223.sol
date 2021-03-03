// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC223  {
    function transfer(address _to, uint _value, bytes calldata _data)
        external
        returns (bool success);
}
