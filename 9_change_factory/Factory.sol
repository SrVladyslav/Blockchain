// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Factory {
    address public owner;
    Account[] public accounts;

    constructor() {
        owner = msg.sender;
    }

    function createAccount() public returns (address) {
        Account account = new Account(msg.sender, address(this));
        accounts.push(account);
        return address(account);
    }

    function showAccount(uint256 _id) public view returns (address) {
        return address(accounts[_id]);
    }

    function changeFactory(address _addr, address _nf) public {
        require(msg.sender == owner);
        Account account = Account(_addr);
        account.changeFactory(_nf);
    }
}

contract Account {
    address public owner;
    address[] public previousFactories;
    address public factoryAddr; // Address of the factory which created this account

    constructor(address _owner, address _factory) {
        owner = _owner;
        factoryAddr = _factory;
    }

    event Created(string);

    function createContract() public {
        require(msg.sender == owner);
        emit Created("Contract Created!");
    }

    function changeFactory(address _newFactory) external {
        require(msg.sender == factoryAddr);
        previousFactories.push(factoryAddr);
        factoryAddr = _newFactory;
    }
}
