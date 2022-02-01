// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract NFTCollection {
    address public owner;
    string public name;
    string public symbol;
    uint256 public value;

    mapping(address => NFT[]) public nftOwners;

    struct NFT {
        address owner;
        string name;
    }

    constructor(
        address _owner,
        string memory _name,
        string memory _symbol
    ) payable {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        value = msg.value;
    }

    receive() external payable {
        value = value + msg.value;
    }

    function createNFT(address _owner, string memory _name) public {
        nftOwners[_owner].push(NFT(_owner, _name));
    }

    function getNFT(address _owner, uint256 _id)
        public
        view
        returns (string memory)
    {
        NFT[] memory nft = nftOwners[_owner];
        return nft[_id].name;
    }

    function getName() public view returns (string memory) {
        return name;
    }

    function getAddr() public view returns (address) {
        return address(this);
    }

    function setOwner(address _newOwner) public {
        require(owner == msg.sender);
        owner = _newOwner;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function withdraw(address _to, uint256 _amount) external payable {
        require(owner == msg.sender);
        require(_amount >= value);
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send eth.");
    }
}

contract ContractFactory {
    address public owner;
    NFTCollection[] public myContracts;

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}

    function withdraw(address _to, uint256 _amount) external payable {
        require(owner == msg.sender);
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send eth.");
    }

    function create(
        address _owner,
        string memory _name,
        string memory _symbol
    ) public returns (address) {
        NFTCollection myContract = new NFTCollection(_owner, _name, _symbol);
        myContracts.push(myContract);
        return address(myContract);
    }

    function createWithETH(
        address _owner,
        string memory _name,
        string memory _symbol,
        uint256 _amount
    ) public payable {
        NFTCollection myContract = (new NFTCollection){value: _amount}(
            _owner,
            _name,
            _symbol
        );
        myContracts.push(myContract);
    }

    function getContract(uint256 _index)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint256
        )
    {
        NFTCollection myContract = myContracts[_index];
        return (
            myContract.owner(),
            myContract.name(),
            myContract.symbol(),
            myContract.value()
        );
    }

    function getContractAddr(uint256 _index) public view returns (address) {
        NFTCollection myContract = myContracts[_index];
        return address(myContract);
    }
}
