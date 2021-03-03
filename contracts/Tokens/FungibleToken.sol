// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../../openzeppelin-contracts/contracts/token/ERC20/ERC20Burnable.sol";
import "../../openzeppelin-contracts/contracts/utils/Pausable.sol";
import "../Common/AccessControl.sol";
import "../Interfaces/FungibleToken.sol";
import "../Interfaces/TokenRecipientInterface.sol";
import "../Interfaces/TokenFallback.sol";

/**
 * @title Blockchain Cuties Universe fungible token base contract
 * @author Andrey Pelipenko - <kindex@kindex.lv>
 * @dev Implementation of the {IERC20}, {IERC827} and {IERC223} interfaces.
 *
 * Implementation is based on OpenZeppelin contracts.
 * Modules:
 * *** ERC20 ***
 *
 * *** Mint/Burn module ***
 * Admins can mint tokens. Token holders can burn their tokens.
 *
 * *** Pause/Freeze module ***
 * It is possible to pause contract transfers in case an exchange is hacked and
 * there is a risk for token holders to lose their tokens, delegated to an
 * exchange. After freezing suspicious accounts the contract can be unpaused.
 * Admins can burn tokens on frozen accounts to mint new tokens to holders as a
 * recovery after a successful hacking attack. Admin can disable the
 * pause/freeze module without possibility to enable this functionality after
 * that.
 *
 * *** Bulk operations ***
 * Bulk operations are added to save on gas.
 * Admin operations: mint tokens and burn frozen tokens
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract FungibleToken is ERC20Burnable, IFungibleToken, AccessControl, Pausable
{
    bool public allowPause = true;
    bool public allowFreeze = true;
    mapping (address => bool) private _frozen;

    event Frozen(address target);
    event Unfrozen(address target);
    event FreezeDisabled();
    event PauseDisabled();

    constructor (string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
    }

    /// --------------------------- Admin functions ----------------------------

    /**
     * @dev Mint some tokens to target account.
     * There is a check for the cap inside.
     */
    function mint(address target, uint256 mintedAmount)
        external
        override
        onlyOperator
    {
        _mint(target, mintedAmount);
    }

    /**
     * @dev Mint some tokens to target account.
     * mintedAmountWithoutDecimals is in human readable format (will be multiplied with 10^decimals)
     * Argument 123 will become 123 000 000 000 000 000 000 tokens.
     */
    function mintAddDecimals(address target, uint256 mintedAmountWithoutDecimals)
        external
        override
        onlyOperator
    {
        _mint(target, mintedAmountWithoutDecimals * (10**decimals()));
    }

    /**
     * @dev Bulk operation to mint tokens to target accounts.
     * There is a check for the cap inside.
     */
    function mintBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmount
    )
        external
        override
        onlyOperator
    {
        require(
            targets.length == mintedAmount.length,
            "mintBulk: targets.length != mintedAmount.length"
        );
        for (uint i = 0; i < targets.length; i++) {
            _mint(targets[i], mintedAmount[i]);
        }
    }

    /**
     * @dev Bulk operation to mint tokens to target accounts.
     * There is a check for the cap inside.
     * mintedAmountWithoutDecimals is in human readable format (will be multiplied with 10^decimals)
     * Argument 123 will become 123 000 000 000 000 000 000 tokens.
     */
    function mintAddDecimalsBulk(
        address[] calldata targets,
        uint256[] calldata mintedAmountWithoutDecimals
    )
        external
        override
        onlyOperator
    {
        require(
            targets.length == mintedAmountWithoutDecimals.length,
            "mintAddDecimalsBulk: targets.length != mintedAmountWithoutDecimals.length"
        );
        for (uint i = 0; i < targets.length; i++) {
            _mint(targets[i], mintedAmountWithoutDecimals[i] * (10**decimals()));
        }
    }

    /// ---------------------------- Freeze module ----------------------------

    /**
     * @dev Disable freeze forever. There is no enableFreeze function.
     */
    function disableFreezeForever() external onlyOwner {
        require(allowFreeze, "disableFreezeForever: Freeze not allowed");
        allowFreeze = false;
        emit FreezeDisabled();
    }

    /**
     * @dev Mark target account as frozen.
     * Frozen accounts can't perform transfers.
     * Admins can burn the tokens on frozen accounts later.
     */
    function freeze(address target) external onlyOperator {
        _freeze(target);
    }

    function _freeze(address target) internal {
        require(allowFreeze, "FungibleToken: Freeze not allowed");
        require(
            !_frozen[target],
            "FungibleToken: Target account is already frozen"
        );
        _frozen[target] = true;
        emit Frozen(target);
    }

    /**
     * @dev Returns true if the target account is frozen.
     */
    function isFrozen(address target) view external returns (bool) {
        return _frozen[target];
    }

    /**
     * @dev Mark target account as unfrozen.
     * Can be called even if the contract doesn't allow to freeze accounts.
     */
    function unfreeze(address target) external onlyOperator {
        require(_frozen[target], "FungibleToken: Target account is not frozen");
        delete _frozen[target];
        emit Unfrozen(target);
    }

    /**
     * @dev Burn tokens on frozen account.
     */
    function burnFrozenTokens(address target) external onlyOperator {
        require(_frozen[target], "FungibleToken: Target account is not frozen");
        _burn(target, balanceOf(target));
    }

    /**
     * @dev Freeze and burn tokens in a single transaction.
     */
    function freezeAndBurnTokens(address target) external onlyOperator {
        _freeze(target);
        _burn(target, balanceOf(target));
    }

    /// ---------------------------- Pause module ----------------------------

    /**
     * @dev Disable pause forever.
     * Noone can enable pause after it has been disabled.
     * Admin will only be able to unpause the contract.
     */
    function disablePauseForever() external onlyOwner {
        require(allowPause, "Pausable: Pause was already disabled");
        allowPause = false;
        emit PauseDisabled();
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused and pause should be allowed.
     */
    function pause() external onlyOperator {
        require(allowPause, "Pausable: Pause not allowed");
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyOperator {
        _unpause();
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - do not allow the transfer of funds to the token contract itself (
     *                                   Usually such a call is a mistake).
     * - do not allow transfers when contract is paused.
     * - only allow to burn frozen tokens.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
        override
    {
        super._beforeTokenTransfer(from, to, amount);

        require(
            to != address(this),
            "FungibleToken: can't transfer to token contract self"
        );
        require(!paused(), "ERC20Pausable: token transfer while paused");
        require(
            !_frozen[from] || to == address(0x0),
            "FungibleToken: source address was frozen"
        );
    }


    /// --------------------------- ERC827 approveAndCall ----------------------


    /**
    * Token owner can approve for `spender` to transferFrom(...) `tokens`
    * from the token owner's account. The `spender` contract function
    * `receiveApproval(...)` is then executed
    */
    function approveAndCall(address spender, uint tokens, bytes calldata data)
        external
        override
        returns (bool success)
    {
        _approve(msg.sender, spender, tokens);
        TokenRecipientInterface(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }

    // ---------------------------- ERC20 Bulk Operations ----------------------

    function transferBulk(address[] calldata to, uint[] calldata tokens)
        external
        override
    {
        require(
            to.length == tokens.length,
            "transferBulk: to.length != tokens.length"
        );
        for (uint i = 0; i < to.length; i++) {
            _transfer(msg.sender, to[i], tokens[i]);
        }
    }

    function approveBulk(address[] calldata spender, uint[] calldata tokens)
        external
        override
    {
        require(
            spender.length == tokens.length,
            "approveBulk: spender.length != tokens.length"
        );
        for (uint i = 0; i < spender.length; i++) {
            _approve(msg.sender, spender[i], tokens[i]);
        }
    }

    /// ---------------------------- ERC223 ----------------------------
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data
    );

    /**
     * @dev Function that is called when a user or another contract wants to
     * transfer funds with custom data, that is passed to receiver contract.
     */
    function transfer(address _to, uint _value, bytes calldata _data)
        external
        override
        returns (bool success)
    {
        return transferWithData(_to, _value, _data);
    }

    /**
     * @dev Alias to {transfer} with 3 arguments.
     */
    function transferWithData(address _to, uint _value, bytes calldata _data)
        public
        returns (bool success)
    {
        if (_isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    /**
    * @dev function that is called when transaction target is a contract
    */
    function transferToContract(address _to, uint _value, bytes calldata _data)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        TokenFallback receiver = TokenFallback(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        return true;
    }

    /**
    * @dev function that is called when transaction target is an address
    */
    function transferToAddress(address _to, uint tokens, bytes calldata _data)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, tokens);
        emit Transfer(msg.sender, _to, tokens, _data);
        return true;
    }

    /**
    * @dev Assemble the given address bytecode.
    * If bytecode exists then the _addr is a contract.
    */
    function _isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return length > 0;
    }
}
