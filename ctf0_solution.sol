// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface MagicSequence {
    function start() external returns(bool);
}

contract CTF_0 {
    uint256 counter;
    uint256[4] private numbers = [42, 55, 256, 9876543];
    address instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() public {
        require(MagicSequence(instance).start(), "Ops");
    }

    function number() external returns (uint256 _number) {
        _number = numbers[counter];
        counter++;
    }
}