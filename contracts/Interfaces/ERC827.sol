// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface IERC827  {
    function approveAndCall(address _spender, uint256 _value, bytes memory _data)
        external
        returns (bool);
}
