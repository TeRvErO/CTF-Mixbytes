// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
Hey there! Check it out! A brand spanking new lottery contract just got deployed!!
Apparently, every tenth user has a chance at becoming a big winner and getting their hands
on all the funds from the contract. Looks like the contract owner is all about the SECURITY
and wants to keep all the governance offchain. But who cares? So, do you dare to take a chance
and see if you can score all that sweet ether from the contract? Who knows, you might just strike it lucky!
*/

contract OffchainOwnable {
    // New technology!
    // Owner is offchain!
    // He just need to sign messages!
    address public owner;

    event Signed(
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes32 hash
    );

    // Restrict reusing the same signatures
    mapping(bytes32 => bool) public used;
    constructor(address _owner) {
        owner = _owner;
    }

    function onlyOwner(uint8 v, bytes32 r, bytes32 s, bytes32 hash) internal {
        require(!used[hash]);
        address signer = ecrecover(hash, v, r, s);
        require(signer == owner);
        used[hash] = true;
        emit Signed(v, r, s, hash);
    }
}

contract Lottery is OffchainOwnable {
    uint256 counter = 0;
    uint256 border = 10;
    uint256 rounds = 0;
    mapping(address => uint256) registered;
    event Deposited(address sender, uint256 value);
    event NewBorder(uint256 value);
    event Withdrawn(address recepient, uint256 value);

    constructor(address _owner) OffchainOwnable(_owner) {}

    function register() external {
        require(registered[msg.sender] == 0);
        counter += 1;
        registered[msg.sender] = counter;
    }

    function deposit() external payable {
        require(registered[msg.sender] != 0);
        if (msg.value >= address(this).balance) {
            // You are the BIG contributer to the lottery
            // You definetely deserves a promotion
            registered[msg.sender] += 1;
        }
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw() external {
        require(registered[msg.sender] != 0);
        // You can withdraw only once!
        // Better luck next time.
        require(registered[msg.sender] % border == 0 && counter / border == rounds + 1);
        emit Withdrawn(msg.sender, address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
        rounds += 1;
    }

    function ownerDeposit(uint8 v, bytes32 r, bytes32 s, bytes32 salt) external payable {
        // add 0x00 prefix to prevent collisions with other types of messages
        bytes32 hash = keccak256(abi.encode(uint8(0x00), msg.value, salt));
        onlyOwner(v, r, s, hash);
        require(msg.value > 0);
        emit Deposited(owner, msg.value);
    }

    function ownerWithdraw(uint8 v, bytes32 r, bytes32 s, bytes32 salt) external {
        // add 0x01 prefix to prevent collisions with other types of messages
        uint256 value = address(this).balance;
        bytes32 hash = keccak256(abi.encode(uint8(0x01), value, salt));
        onlyOwner(v, r, s, hash);
        payable(owner).transfer(value);
        emit Withdrawn(owner, value);
    }

    function setBorder(uint8 v, bytes32 r, bytes32 s, bytes32 salt, uint256 newBorder) external {
        // add 0x02 prefix to prevent collisions with other types of messages
        bytes32 hash = keccak256(abi.encode(uint8(0x02), newBorder, salt));
        onlyOwner(v, r, s, hash);
        border = newBorder;
        emit NewBorder(newBorder);
    }
}