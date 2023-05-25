const { ethers } = require('ethers');

function findSecret() {
	// to get this array I used a loop for 10000000 first i
	let array = [42, 55, 256, 9876543]
	array.forEach(i => {
		let encoded = ethers.utils.defaultAbiCoder.encode(['uint256'], [i]);
		let keccaked = ethers.utils.keccak256(encoded);
		let sliced = keccaked.slice(2, 10);
		if (sliced === "beced095") console.log("0", i);
		if (sliced === "42a7b7dd") console.log("1", i);
		if (sliced === "45e010b9") console.log("2", i);
		if (sliced === "a86c339e") console.log("3", i);
	})
}

findSecret();