// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/*
Bob isn't really good in crypto and he decided to hide 4 secret numbers in contract.
To complete this round you should got true return from by calling start method.

Things that might help: if you wanna to call start from your account it won't work ()
*/

interface Player {
  function number() external returns (uint256);
}


contract MagicSequence {
  bool public accepted;
  bytes4[] private hashes;

  constructor() public {
    hashes.push(0xbeced095);
    hashes.push(0x42a7b7dd);
    hashes.push(0x45e010b9);
    hashes.push(0xa86c339e);
  }

  function start() public returns(bool) {
    Player player = Player(msg.sender);

    uint8 i = 0;
    while (i < 4) {
      if (bytes4(uint32(uint256(keccak256(abi.encodePacked(player.number()))) >> 224)) != hashes[i]) {
        return false;
      }
      i++;
    }

    accepted = true;
    return true;
  }
}