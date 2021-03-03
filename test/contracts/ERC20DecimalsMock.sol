// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../contracts/Tokens/FungibleToken.sol";

contract ERC20DecimalsMock is FungibleToken {
    uint8 immutable private _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) FungibleToken(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
