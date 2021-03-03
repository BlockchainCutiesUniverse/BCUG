// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../../openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./ERC827.sol";
import "./ERC223.sol";
import "./ERC20Bulk.sol";

interface IFungibleToken is IERC20, IERC827, IERC223, IERC20Bulk {

    function mint(address target, uint256 mintedAmount) external;

    function mintBulk(address[] calldata target, uint256[] calldata mintedAmount) external;

    function mintAddDecimals(address target, uint256 mintedAmountWithoutDecimals) external;

    function mintAddDecimalsBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmountWithoutDecimals
    )
        external;
}
