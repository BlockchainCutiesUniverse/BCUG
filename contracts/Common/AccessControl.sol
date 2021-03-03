// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../../openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../../openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {setOwner}.
 *
 * This module is used through inheritance. It will make available the modifiers
 * `onlyOwner`/`onlyOperator`, which can be applied to your functions to
 * restrict their use to the owner.
 *
 * Operator account can be set to MultiSig contract.
 *
 * In case someone mistakenly sent other tokens to the contract, or ETH,
 * there are functions to transfer those funds to a different address.
 */
contract AccessControl
{
    mapping (address=>bool) ownerAddress;
    mapping (address=>bool) operatorAddress;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        ownerAddress[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(ownerAddress[msg.sender], "Access denied");
        _;
    }

    /**
     * @dev Checks if provided address has owner permissions.
     */
    function isOwner(address _addr) public view returns (bool) {
        return ownerAddress[_addr];
    }

    /**
     * @dev Grants owner permission to new account.
     * Can only be called by the current owner.
     */
    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner is empty");

        ownerAddress[_newOwner] = true;
    }

    /**
     * @dev Replaces owner permission to new account.
     * Can only be called by the current owner.
     */
    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner is empty");

        ownerAddress[_newOwner] = true;
        delete(ownerAddress[msg.sender]);
    }

    /**
     * @dev Revokes owner permission from account.
     * Can only be called by the current owner.
     */
    function removeOwner(address _oldOwner) external onlyOwner {
        delete(ownerAddress[_oldOwner]);
    }

    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require(isOperator(msg.sender), "Access denied");
        _;
    }

    /**
     * @dev Checks if provided address has operator or owner permissions.
     */
    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || ownerAddress[_addr];
    }

    /**
     * @dev Grants operator permission to new account.
     * Can only be called by the current owner.
     */
    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0), "New operator is empty");

        operatorAddress[_newOperator] = true;
    }

    /**
     * @dev Revokes operator permission from account.
     * Can only be called by the current owner.
     */
    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }

    /**
     * @dev Transfers to _withdrawToAddress all tokens controlled by
     * contract _tokenContract.
     */
    function withdrawERC20(
        IERC20 _tokenContract,
        address _withdrawToAddress
    )
        external
        onlyOperator
    {
        uint256 balance = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(_withdrawToAddress, balance);
    }

    /**
     * @dev Allow to withdraw ERC721 tokens from contract itself
     */
    function approveERC721(IERC721 _tokenContract, address _approveToAddress)
        external
        onlyOperator
    {
        _tokenContract.setApprovalForAll(_approveToAddress, true);
    }

    /**
     * @dev Allow to withdraw ERC1155 tokens from contract itself
     */
    function approveERC1155(IERC1155 _tokenContract, address _approveToAddress)
        external
        onlyOperator
    {
        _tokenContract.setApprovalForAll(_approveToAddress, true);
    }

    /**
     * @dev Allow to withdraw ETH from contract itself (only by owner)
     */
    function withdrawEth(address payable _withdrawToAddress)
        external
        onlyOperator
    {
        if (address(this).balance > 0) {
            _withdrawToAddress.transfer(address(this).balance);
        }
    }
}
