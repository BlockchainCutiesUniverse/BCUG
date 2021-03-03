'use strict';

var Token = artifacts.require('./Tokens/FungibleToken.sol');
var TokenFallbackMock = artifacts.require('./test/contracts/TokenFallbackMock.sol');
const { BN, ether, expectRevert } = require('@openzeppelin/test-helpers');

contract('FungibleTokenMock as ERC20 (KindeX test)', function (accounts) {

    const ceo = accounts[0];
    const user1 = accounts[1];
    const user2 = accounts[2];
    const user3 = accounts[3];
    const coo = accounts[4];
    const cfo = accounts[5];

    /*    it('Transfer ERC223 contract custom_fallback', async function() {
            let token = await Token.new("symbol", "name", {from:ceo});
            let receiver = await TokenFallbackMock.new({from:ceo});

            await token.mint(user1, 100, {from:ceo});

            await token.transferErc233_2(receiver.address, 1, [0x1, 0x2], "customFallback", {from:user1});

            assert.equal(await token.balanceOf(user1), 99);
            let newVar = await token.balanceOf(receiver.address);
            console.log(newVar.toNumber());
            assert.equal(newVar.toNumber(), 1);
            //console.log(await receiver.data());
            assert.equal(await receiver.value(), 1);
            assert.equal(await receiver.from(), user1);
        });
    */
    it('Transfer ERC223 contract', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        let receiver = await TokenFallbackMock.new({from: ceo});

        await token.mint(user1, 100, {from: ceo});

        await token.transferToContract(receiver.address, 10, [0x1, 0x2], {from: user1});

        assert.equal(await token.balanceOf(user1), 90);
        assert.equal(await token.balanceOf(receiver.address), 10);
        //console.log(await receiver.data());
        assert.equal(await receiver.value(), 10);
        assert.equal(await receiver.from(), user1);
    });

    it('Transfer ERC223 address', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});

        await token.transferToAddress(user2, 10, [0x1, 0x2], {from: user1});

        assert.equal(await token.balanceOf(user1), 90);
        assert.equal(await token.balanceOf(user2), 10);
    });

    it('Approve bulk', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});

        await token.approveBulk([user2, user3], [10, 20], {from: user1});

        assert.equal(await token.allowance(user1, user2), 10);
        assert.equal(await token.allowance(user1, user3), 20);
    });

    it('Transfer bulk', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});

        await token.transferBulk([user2, user3], [10, 20], {from: user1});

        assert.equal(await token.balanceOf(user1), 70);
        assert.equal(await token.balanceOf(user2), 10);
        assert.equal(await token.balanceOf(user3), 20);
    });

    it('Burn', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});

        assert.equal(await token.balanceOf(user1), 100);
        assert.equal((await token.totalSupply()).toNumber(), 100);

        await token.burn(100, {from: user1});

        assert.equal(await token.balanceOf(user1), 0);
        assert.equal((await token.totalSupply()).toNumber(), 0);

        await expectRevert(
            token.burn(100, {from: user1}),
            "ERC20: burn amount exceeds balance"
        );
    });

    it('Owner permissions', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await expectRevert(
            token.mintBulk([user1, user2, user3], [1, 2, 3], {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mint(user1, 1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mintAddDecimalsBulk([user1, user2, user3], [1, 2, 3], {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mintAddDecimals(user1, 1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.addOperator(user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.removeOperator(user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.withdrawERC20(token.address, user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.approveERC721(token.address, user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.approveERC1155(token.address, user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.withdrawEth(user1, {from: user1}), "Access denied"
        );

        await expectRevert(
            token.disableFreezeForever({from: user1}), "Access denied"
        );
        await expectRevert(
            token.freeze(user2, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.unfreeze(user2, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.burnFrozenTokens(user2, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.disablePauseForever({from: user1}), "Access denied"
        );
        await expectRevert(
            token.pause({from: user1}), "Access denied"
        );
        await expectRevert(
            token.unpause({from: user1}), "Access denied"
        );

        await token.addOperator(user1, {from: ceo});
        /// ************************ user1 is now operator *******************

        await token.mintBulk([user1, user2, user3], [1, 2, 3], {from: user1});
        await token.mint(user1, 1, {from: user1});
        await token.mintAddDecimalsBulk([user1, user2, user3], [1, 2, 3], {from: user1});
        await token.mintAddDecimals(user1, 1, {from: user1});
        await expectRevert(
            token.addOperator(user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.removeOperator(user1, {from: user1}), "Access denied"
        );
        await token.withdrawERC20(token.address, user1, {from: user1});
        // await token.approveERC721(token.address, user1, {from: user1});
        // await token.approveERC1155(token.address, user1, {from: user1});
        await token.withdrawEth(user1, {from: user1});

        await token.removeOperator(user1, {from: ceo});

        /// ********************* user1 is no more operator ********************

        await expectRevert(
            token.mintBulk([user1, user2, user3], [1, 2, 3], {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mint(user1, 1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mintAddDecimalsBulk([user1, user2, user3], [1, 2, 3], {from: user1}), "Access denied"
        );
        await expectRevert(
            token.mintAddDecimals(user1, 1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.addOperator(user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.removeOperator(user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.withdrawERC20(token.address, user1, {from: user1}), "Access denied"
        );
        await expectRevert(
            token.withdrawEth(user1, {from: user1}), "Access denied"
        );

        await expectRevert(
            token.freezeAndBurnTokens(user1, {from: user1}), "Access denied"
        );
    });

    it('mintBulk', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mintBulk([user1, user2, user3], [1, 2, 3], {from: ceo});

        assert.equal(await token.balanceOf(user1), 1);
        assert.equal(await token.balanceOf(user2), 2);
        assert.equal(await token.balanceOf(user3), 3);
        assert.equal(await token.totalSupply(), 6);
    });

    it('mintAddDecimalsBulk', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mintAddDecimalsBulk([user1, user2, user3], [1, 2, 3], {from: ceo});

        assert.equal(await token.balanceOf(user1), 1*(10**18));
        assert.equal(await token.balanceOf(user2), 2*(10**18));
        assert.equal(await token.balanceOf(user3), 3*(10**18));
        assert.equal(await token.totalSupply(), 6*(10**18));
    });

    it('mintAddDecimals', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mintAddDecimals(user1, 123, {from: ceo});

        assert.equal(await token.balanceOf(user1), 123*(10**18));
        assert.equal(await token.totalSupply(), 123*(10**18));
    });

    it('should return the correct totalSupply after construction', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mint(accounts[0], 100, {from: ceo});
        let totalSupply = await token.totalSupply();

        assert.equal(totalSupply, 100);
    });

    it('should return the correct allowance amount after approval', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.approve(accounts[1], 100);
        let allowance = await token.allowance(accounts[0], accounts[1]);

        assert.equal(allowance, 100);
    });

    it('should return correct balances after transfer', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mint(accounts[0], 100, {from: ceo});

        await token.transfer(accounts[1], 100, {from: ceo});
        let balance0 = await token.balanceOf(accounts[0]);
        assert.equal(balance0, 0);

        let balance1 = await token.balanceOf(accounts[1]);
        assert.equal(balance1, 100);
    });

    it('should throw an error when trying to transfer more than balance', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mint(accounts[0], 100, {from: ceo});

        await expectRevert(
            token.transfer(accounts[1], 101, {from: ceo}),
            "ERC20: transfer amount exceeds balance"
        );
    });

    it('should return correct balances after transfering from another account', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mint(accounts[0], 100, {from: ceo});

        await token.approve(accounts[1], 100);
        await token.transferFrom(accounts[0], accounts[2], 100, {from: accounts[1]});

        let balance0 = await token.balanceOf(accounts[0]);
        assert.equal(balance0, 0);

        let balance1 = await token.balanceOf(accounts[2]);
        assert.equal(balance1, 100);

        let balance2 = await token.balanceOf(accounts[1]);
        assert.equal(balance2, 0);
    });

    it('should throw an error when trying to transfer more than allowed', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        await token.mint(accounts[0], 100, {from: ceo});
        await token.approve(accounts[1], 99);

        await expectRevert(
            token.transferFrom(accounts[0], accounts[2], 100, {from: accounts[1]}),
            "ERC20: transfer amount exceeds allowance"
        );
    });

    it('Transfer to itself', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});

        await expectRevert(
            token.transfer(token.address, 1, {from: user1}),
            "FungibleToken: can't transfer to token contract self"
        );
    });

    it('Pause/disablePause', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});
        await token.pause({from: ceo});
        await expectRevert(token.pause({from: ceo}), "Pausable: paused");
        await expectRevert(token.transfer(user2, 1, {from: user1}), "ERC20Pausable: token transfer while paused");

        await token.unpause({from: ceo});
        await expectRevert(token.unpause({from: ceo}), "Pausable: not paused");

        await token.transfer(user2, 1, {from: user1});

        await token.disablePauseForever({from: ceo});
        await expectRevert(token.disablePauseForever({from: ceo}), "Pausable: Pause was already disabled");
        await expectRevert(token.pause({from: ceo}), "Pausable: Pause not allowed");
    });

     it('Freeze/unfreeze', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});
        assert.equal(await token.isFrozen(user1), false);

        await token.mint(user1, 100, {from: ceo});
        await token.freeze(user1, {from: ceo});
        assert.equal(await token.isFrozen(user1), true);
        await expectRevert(token.transfer(user2, 1, {from: user1}), "FungibleToken: source address was frozen");

        await token.unfreeze(user1, {from: ceo});
        assert.equal(await token.isFrozen(user1), false);

        await token.transfer(user2, 1, {from: user1});
    });

    it('disableFreeze', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.disableFreezeForever({from: ceo});
        await expectRevert(token.freeze(user1, {from: ceo}), "FungibleToken: Freeze not allowed");
        await expectRevert(token.freezeAndBurnTokens(user1, {from: ceo}), "FungibleToken: Freeze not allowed");
    });

    it('burnFrozenTokens', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});
        assert.equal(await token.balanceOf(user1), 100);
        assert.equal(await token.totalSupply(), 100);

        await expectRevert(token.burnFrozenTokens(user1, {from: ceo}), "FungibleToken: Target account is not frozen");

        await token.freeze(user1, {from: ceo});
        await token.burnFrozenTokens(user1, {from: ceo});

        assert.equal(await token.balanceOf(user1), 0);
        assert.equal(await token.totalSupply(), 0);

    });

    it('freezeAndBurnTokens', async function () {
        let token = await Token.new("symbol", "name", {from: ceo});

        await token.mint(user1, 100, {from: ceo});
        assert.equal(await token.balanceOf(user1), 100);
        assert.equal(await token.totalSupply(), 100);

        await token.freezeAndBurnTokens(user1, {from: ceo});

        assert.equal(await token.balanceOf(user1), 0);
        assert.equal(await token.totalSupply(), 0);
        assert.equal(await token.isFrozen(user1), true);

    });

});
