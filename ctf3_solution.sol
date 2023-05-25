// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
https://iopscience.iop.org/article/10.1088/1757-899X/928/3/032022/pdf
https://www.halborn.com/blog/post/how-hackers-can-exploit-weak-ecdsa-signatures
https://medium.com/asecuritysite-when-bob-met-alice/cracking-ecdsa-with-a-leak-of-the-random-nonce-d72c67f201cd
https://ethereum.stackexchange.com/questions/20962/should-signed-text-messages-use-the-x19ethereum-signed-message-prefix/30173
https://github.com/pubkey/eth-crypto#sign
*/

interface Lottery {
    function ownerWithdraw(uint8 v, bytes32 r, bytes32 s, bytes32 salt) external;
}

contract CTF_3 {
    Lottery public lottery;

    constructor(address _lottery) {
        lottery = Lottery(_lottery);
        bytes32 salt = 0x2626262626262626262626262626262626262626262626262626262626262626;

        uint8 v = 27;
        bytes32 r = 0x586372fa87d5caea94b660a5216fbc085c68b99d0213c6c9789427710dd4be9d;
        bytes32 s = 0x27c277730c0e5bb35e05390db78710c0260c4cd5e65a9266858bf98d7de72c91;
        lottery.ownerWithdraw(v, r, s, salt);
    }
}
