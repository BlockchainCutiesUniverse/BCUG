const Operators = artifacts.require('AccessControl.sol');

let user1, owner1, owner2, operator1, operator2;
let contr;

contract('AccessControl', function (accounts) {
    owner1 = accounts[1];
    owner2 = accounts[2];
    operator1 = accounts[3];
    operator2 = accounts[4];
    user1 = accounts[5];

    it("Create", async function () {

        contr = await Operators.new({from: owner1});
    });

    it('add/remove owner', async function () {
        assert(await contr.isOwner(owner1));
        assert(!await contr.isOwner(owner2));
        assert(await contr.isOperator(owner1));
        assert(!await contr.isOperator(owner2));

        await contr.addOwner(owner2, {from: owner1});
        assert(await contr.isOwner(owner2));

        await contr.removeOwner(owner2, {from: owner1});
        assert(!await contr.isOwner(owner2));
        assert(!await contr.isOperator(owner2));
    });


    it('add/remove operator', async function () {
        assert(!await contr.isOperator(operator1));
        assert(!await contr.isOperator(operator2));

        await contr.addOperator(operator1, {from: owner1});
        await contr.addOperator(operator2, {from: owner1});

        assert(await contr.isOperator(operator1));
        assert(await contr.isOperator(operator2));

        await contr.removeOperator(operator1, {from: owner1});
        await contr.removeOperator(operator2, {from: owner1});

        assert(!await contr.isOperator(operator1));
        assert(!await contr.isOperator(operator2));
    });

    it('setOwner', async function () {
        assert(await contr.isOwner(owner1));
        assert(!await contr.isOwner(owner2));

        await contr.setOwner(owner2, {from: owner1});
        assert(!await contr.isOwner(owner1));
        assert(await contr.isOwner(owner2));
    });

});