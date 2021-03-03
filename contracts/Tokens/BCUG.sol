// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "./ERC20Capped.sol";

/**
* @title Blockchain Cuties Universe Governance Token contract
* @author Andrey Pelipenko - <kindex@kindex.lv>
* @dev Implementation of the {IERC20}, {IERC827} and {IERC223} interfaces.
*
* Implementation is based on {FungibleToken} and {ERC20Capped}.
* Max supply is limited to 10,000,000 tokens.
*/
contract BCUG is ERC20Capped
{
    constructor()
        ERC20Capped(
            "BCUG",
            "Blockchain Cuties Universe Governance Token",
            10000000 ether)
    {
    }
}
