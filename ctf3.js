const { ethers } = require('ethers');
const EthCrypto = require('eth-crypto');
const Web3 = require('web3');

// Connect to the RPC provider
const rpc = 'https://polygon-mumbai-bor.publicnode.com';
const provider = new ethers.providers.JsonRpcProvider(rpc);

function getPrivateKey() {
	let modulo = ethers.BigNumber.from('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141');
	let h1 = ethers.BigNumber.from('0x25c1050314a89c7d6a9c227984efcff0ebd77c7c1ef51ce05a6725c8dad2424f');
	let h2 = ethers.BigNumber.from('0xe21147eaadd6f5b9439ebee73487f91963f71c2e5b67accf93661063bb41336a');
	let s1 = ethers.BigNumber.from('0x77ce18e7fdacafde51b6ea73f8df391329278cf66d5400307a7194a68193fc93');
	let s2 = ethers.BigNumber.from('0x2278fcc65be7f801abdc857a4178f808e9115c61690d47ea10759149851e5e94');
	let r = ethers.BigNumber.from('0xa9c7e2fcd2640a67284050685eece548eb81c189946a92a5bab048b956eb908d');
	let h1s2 = h1.mul(s2).mod(modulo);
	let h2s1 = h2.mul(s1).mod(modulo);
	let s1s2 = s1.sub(s2).mod(modulo);
	let denominator = r.mul(s1s2).mod(modulo);
	let numerator = h1s2.sub(h2s1).mod(modulo);
	let pkey = numerator.mul(modInverse(denominator, modulo)).mod(modulo);
	console.log(`Private key: ${pkey._hex}`);
	return pkey._hex;
}

/* modInverse and extendedEuclidean are function from chatGPT requests =) */
function modInverse(a, m) {
    if (m.eq(1)) {
        return ethers.BigNumber.from(0);
    }

    let [g, x] = extendedEuclidean(a, m);
    if (g.eq(1)) {
        return x.mod(m);
    }

    return ethers.BigNumber.from(0);
}

function extendedEuclidean(a, b) {
    if (b.eq(0)) {
        return [a, ethers.BigNumber.from(1), ethers.BigNumber.from(0)];
    }

    const [g, x, y] = extendedEuclidean(b, a.mod(b));
    return [g, y, x.sub(a.div(b).mul(y))];
}

function verifySignature(signature, hash, signer) {
	console.log('Signature:', signature);
	if (EthCrypto.recover(signature, hash) != signer) console.log(`Signature signer doesn't match\n`);
	else {
		console.log(`Working!`);
		const { v, r, s } = ethers.utils.splitSignature(signature);
		console.log('v:', v);
		console.log('r:', r);
		console.log('s:', s);
		console.log('\n')
	}
}

async function signMessage() {
	let salt = "0x2626262626262626262626262626262626262626262626262626262626262626";
	let value = 1000000000000000;
	const encodedData = ethers.utils.defaultAbiCoder.encode(['uint8', 'uint256', 'bytes32'], [1, value, salt]);
	const messageHash = ethers.utils.keccak256(encodedData);
	
	const privateKey = getPrivateKey(); // Replace with your private key
	const wallet = new ethers.Wallet(privateKey);
	console.log(`Owner address: ${wallet.address}`);
	
	/* First method. Not working because there is prefix of `\x19Ethereum Signed Message:\n` */
	let messageHashBytes = ethers.utils.arrayify(messageHash)
	const signature = await wallet.signMessage(messageHashBytes);
	console.log(`Ethers js`);
	verifySignature(signature, messageHash, wallet.address);

	/* Second method. Not working because there is prefix of `\x19Ethereum Signed Message:\n` */
	const web3 = new Web3(rpc);
	web3.eth.accounts.wallet.add(privateKey);
	let signature_web3 = await web3.eth.sign(messageHash, wallet.address);
	console.log(`Web3 js`);
	verifySignature(signature_web3, messageHash, wallet.address); 

	/* Third method. Working! https://ethereum.stackexchange.com/questions/20962/should-signed-text-messages-use-the-x19ethereum-signed-message-prefix/30173 */
	const signature_withoutPrefix = EthCrypto.sign(privateKey, messageHash);
	console.log(`Ethcrypto js`);
	verifySignature(signature_withoutPrefix, messageHash, wallet.address);
}

signMessage();
