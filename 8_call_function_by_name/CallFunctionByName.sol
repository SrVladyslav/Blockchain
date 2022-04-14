// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface CalleeContractInterface {
    function getFunctions() external view returns (string[] memory);
}

contract CallFunctionByName {
    address private owner;

    mapping(address => bool) private allowedContracts;
    mapping(address => string[]) public functions; // Functions which could be called from the contract

    constructor() {
        owner = msg.sender;
    }

    /**
     * Adds the contract to the white list, so we can do call on it later.
     */
    function allowContract(address _newContract) public {
        require(owner == msg.sender, "Only admin can allow contracts");
        allowedContracts[_newContract] = true;
        getContractFunctions(_newContract);
    }

    /**
     *   Obtains the contract functions given the contract address
     */
    function getAllowedContractFunctions(address _contract)
        public
        view
        returns (string[] memory)
    {
        require(allowedContracts[_contract], "This contract is not allowed");
        require(
            functions[_contract].length > 0,
            "There is no contract awailable with this address"
        );
        return functions[_contract];
    }

    /**
     * Obtains the function name from given contract and given position
     */
    function getFunction(address _contract, uint256 _index)
        public
        view
        returns (string memory)
    {
        return functions[_contract][_index];
    }

    function decodeArray(bytes memory _msg)
        internal
        pure
        returns (string[] memory)
    {
        return abi.decode(_msg, (string[]));
    }

    function getContractFunctions(address _contract)
        public
        returns (string[] memory)
    {
        require(owner == msg.sender, "Yout are not the owner");
        require(allowedContracts[_contract], "This contract is not allowed");

        bytes memory message = abi.encodeWithSignature("getFunctions()");
        (bool success, bytes memory returnData) = address(_contract).call(
            message
        );
        require(success, "Something went wrong with the transaction");
        functions[_contract] = decodeArray(returnData);
        return functions[_contract];
    }

    function callFunction(address _contract, string memory _funct)
        public
        returns (bytes memory)
    {
        require(owner == msg.sender);
        require(allowedContracts[_contract], "This contract is not allowed");
        require(
            functions[_contract].length > 0,
            "There are no functions for this contract"
        );
        bytes memory funct = abi.encodeWithSignature(_funct);
        (bool success, bytes memory returnData) = address(_contract).call(
            funct
        );
        require(success, "Something went wrong with the call function");
        return returnData;
    }

    function callWithTwoUints(
        address _contract,
        uint256 _a,
        uint256 _b
    ) public returns (uint256) {
        require(owner == msg.sender);
        require(allowedContracts[_contract], "This contract is not allowed");
        require(
            functions[_contract].length > 0,
            "There are no functions for this contract"
        );
        bytes memory funct = abi.encodeWithSignature(
            "addNumber(uint256,uint256)",
            _a,
            _b
        );
        (bool success, bytes memory returnData) = address(_contract).call(
            funct
        );
        require(success, "Something went wrong with the call function");
        return abi.decode(returnData, (uint256));
    }

    /**
     * Returns the length of the array for the given contract
     */
    function getFunctionLength(address _contract)
        public
        view
        returns (uint256)
    {
        return functions[_contract].length;
    }
}

contract CalleeContract is CalleeContractInterface {
    address private owner;
    address private contractOwner;
    string[] public functions = [
        "viewOwner()",
        "viewContractOwner()",
        "addNumber(uint256,uint256)"
    ];

    // We can also add the possibility for the return values and parameters, so we can create better function

    constructor() {
        owner = tx.origin; // the person calling the function
        contractOwner = msg.sender; // The contract which called the function
    }

    function getFunctions() external view override returns (string[] memory) {
        return functions; //abi.encode(functions);
    }

    function viewOwner() public view returns (address) {
        require(tx.origin == owner);
        return owner;
    }

    function viewContractOwner() public view returns (address) {
        require(tx.origin == owner);
        return owner;
    }

    function addNumber(uint256 _a, uint256 _b) public pure returns (uint256) {
        return _a + _b;
    }
}
