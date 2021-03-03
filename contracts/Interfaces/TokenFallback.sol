// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/// https://github.com/ethereum/EIPs/issues/223
interface TokenFallback {
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}
