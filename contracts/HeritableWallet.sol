pragma solidity ^0.4.10;

import "HeritableWalletFactory.sol";

contract HeritableWallet {
	
	HeritableWalletFactory public factory;
	address public beneficiary;
	address public owner;
	mapping(address => uint8) public points;
	mapping(address => address) public wallets;
	uint public lastCheckInTime;
	uint public checkInPeriod;
	uint public totalPoints = 0;
	
	/* constructor */
	function HeritableWallet(address walletBeneficiary, address walletOwner, uint periodInDays) {
		factory = HeritableWalletFactory(msg.sender); // asume the creator is always the factory
		beneficiary = walletBeneficiary; // intended beneficiary
		owner = walletOwner; // who currently controls the wallet
		checkInPeriod = periodInDays * 1 days;
		lastCheckInTime = now;
	}
	
	/* anyone can deposit funds by sending funds to the contract address */
	function() payable {}
	
	modifier onlyOwner() {
		if (msg.sender != owner && msg.sender != HeritableWallet(owner).getOwner()) throw; 
		lastCheckInTime = now;
		_; // function body
	}
	
	modifier onlyHeir() {
		if (points[msg.sender] == 0) throw; 
		_; // function body
	}
	
	/* called by owner periodically to prove he is alive */
	function checkIn() onlyOwner {}
	
	/* called by owner to change check in period */
	function setCheckInPeriod(uint periodInDays) onlyOwner {
		checkInPeriod = periodInDays * 1 days;
	}
	
	/* called by owner to send funds with data to chosen destination */
	function sendFunds(address destination, uint amount, bytes data) onlyOwner {
		if (!destination.call.value(amount)(data)) throw;
	}
	
	/* called by owner to change ownership */
	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
		beneficiary = owner;
	}
	
	/* called by owner to add/modify an heir; inheritance shares are directly proportional to the points assigned */
	function setHeir(address heir, uint8 inheritancePoints, uint periodInDays) onlyOwner returns (address) {
		if (wallets[heir] == 0 && inheritancePoints > 0) {
			wallets[heir] = factory.create(heir, periodInDays);
		} else if (wallets[heir] > 0 && inheritancePoints == 0) {
			HeritableWallet(wallets[heir]).destroy();
			delete wallets[heir];
		}
		totalPoints -= points[wallets[heir]];
		points[wallets[heir]] = inheritancePoints;
		totalPoints += inheritancePoints;
		return wallets[heir];
	}
	
	/* called by anyone to give the benificiary full ownership of this account when his predecessor is inactive */
	function unlock() {
		if (beneficiary == owner) throw; // already unlocked
		HeritableWallet(owner).claimInheritance();
		owner = beneficiary;
		lastCheckInTime = now;
	}
	
	/* called by an heir to collect his share in the inheritance */
	function claimInheritance() onlyHeir {
		if (beneficiary != owner) throw; // account is locked
		if (now <= lastCheckInTime + checkInPeriod) throw; // owner was active recently
		uint8 heirPoints = points[msg.sender];
		uint amount = this.balance * heirPoints / totalPoints; // compute amount for current heir
		totalPoints -= heirPoints;
		delete points[msg.sender];
		if (!msg.sender.send(amount)) { // transfer proper amount to heir or revert state if it fails
			totalPoints += heirPoints;
			points[msg.sender] = heirPoints;
			throw;
		}
		if (totalPoints == 0) { // last heir, destroy empty contract
			selfdestruct(owner);
		}
	}
	
	/* called by owner to terminate this contract */
	function destroy() onlyOwner {
		selfdestruct(owner);
	}
	
	function getOwner() constant returns (address) { return owner; }
	function getBeneficiary() constant returns (address) { return beneficiary; }
	
}