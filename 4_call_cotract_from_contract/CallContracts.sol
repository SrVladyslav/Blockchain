// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyContract {
    uint256 public x;
    uint256 public value;

    function setX(uint256 _x) public returns (uint256) {
        x = _x;
        return x;
    }

    function setXandEther(uint256 _x)
        public
        payable
        returns (uint256, uint256)
    {
        x = _x;
        value = msg.value;
        return (x, value);
    }

    function getData() public view returns (uint256, uint256) {
        return (x, value);
    }
}

contract CallContracts {
    function setX(address _addr, uint256 _x) public {
        MyContract myContract = MyContract(_addr);
        myContract.setX(_x);
    }

    function setEther(address _addr, uint256 _x)
        public
        payable
        returns (uint256, uint256)
    {
        MyContract myContract = MyContract(_addr);
        (uint256 a, uint256 b) = myContract.setXandEther{value: msg.value}(_x);
        return (a, b);
    }

    function getData(address _addr) public view returns (uint256, uint256) {
        MyContract myContract = MyContract(_addr);
        (uint256 a, uint256 b) = myContract.getData();
        return (a, b);
    }
}
