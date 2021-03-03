// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../../contracts/Interfaces/TokenFallback.sol";

contract TokenFallbackMock is TokenFallback
{
    bytes public data;
    uint public value;
    address public from;

    function tokenFallback(address _from, uint _value, bytes calldata _data) external override
    {
        data = _data;
        from = _from;
        value = _value;
    }

    function customFallback(address _from, uint _value, bytes calldata _data) external
    {
        data = _data;
        from = _from;
        value = _value;
    }
}
