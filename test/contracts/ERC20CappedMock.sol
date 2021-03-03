// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../contracts/Tokens/ERC20Capped.sol";

contract ERC20CappedMock is ERC20Capped {
    constructor (string memory name, string memory symbol, uint256 cap)
        ERC20Capped(name, symbol, cap)
    { }
}
