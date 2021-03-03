// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FungibleToken.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
contract ERC20Capped is FungibleToken {
    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (string memory _name, string memory _symbol, uint256 cap_)
    FungibleToken(_symbol, _name) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        }
    }
}
