pragma solidity ^0.4.10;

import "HeritableWallet.sol";

contract HeritableWalletFactory {
	
	address public creator;
	mapping(address => address[]) public contracts;
	
	event WalletCreated(address walletAddress, address walletOwner, address walletBeneficiary);
	
	function HeritableWalletFactory() {
		creator = msg.sender;
	}
	
	function create(address beneficiary, uint periodInDays) returns (address wallet) {
		wallet = new HeritableWallet(beneficiary, msg.sender, periodInDays);
		contracts[beneficiary].push(wallet);
		WalletCreated(wallet, msg.sender, beneficiary);
	}
	
}