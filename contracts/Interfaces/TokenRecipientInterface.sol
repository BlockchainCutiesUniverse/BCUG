// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/// Contract function to receive approval and execute function in one call
interface TokenRecipientInterface {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}
