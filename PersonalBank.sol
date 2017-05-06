pragma solidity ^0.4.10;

contract PersonalBank {
	
	address public owner;
	uint checkInDeadline;
	uint checkInPeriod;
	mapping(address => uint8) public points;
	address[] heirs;
	uint8 heirsNumber = 0;
	
	/* constructor */
	function PersonalBank() {
		owner = msg.sender;
		setCheckInPeriod(365);
	}
	
	modifier onlyOwner() { if (msg.sender != owner) throw; _; }
	
	/* get the index of an heir */
	function indexOfHeir(address heir) private returns(int) {
		uint8 i = heirsNumber;
		while (i > 0) {
			i--;
			if (heirs[i] == heir) {
				return i;
			}
		}
		return -1;
	}
	
	/* called by owner to prove he is alive */
	function checkIn() onlyOwner {
		checkInDeadline = now + checkInPeriod * 1 days;
	}
	
	/* called by owner to send funds to custom accounts */
	function sendFunds(address receiver, uint amount) onlyOwner returns(bool success) {
		if (this.balance < amount) throw;
		return receiver.send(amount);
	}
	
	/* called by owner to terminate this contract */
	function destroy() onlyOwner {
		selfdestruct(owner);
	}
	
	/* called by owner to change check in period */
	function setCheckInPeriod(uint period) onlyOwner {
		checkInPeriod = period;
		checkIn();
	}
	
	/* called by owner to add/modify an heir; inheritance shares are deducted from the points assigned */
	function setHeir(address heir, uint8 inheritancePoints) onlyOwner {
		int heirIndex = indexOfHeir(heir);
		if (heirIndex < 0) { // not a heir
			heirIndex = heirsNumber;
			heirs.push(heir);
		}
		points[heirs[uint256(heirIndex)]] = inheritancePoints;
	}
	
	/* called by owner to remove an heir */
	function removeHeir(address heir) onlyOwner {
		int heirIndex = indexOfHeir(heir);
		if (heirIndex >= 0) { // is a heir
			delete points[heir];
			heirs[uint256(heirIndex)] = heirs[heirsNumber - 1];
			heirsNumber--;
		}
	}
	
	/* called by an heir to request his share in the inheritance */
	function requestInheritance() {
		if (now <= checkInDeadline) throw; // owner not dead
		int heirIndex = indexOfHeir(msg.sender);
		if (heirIndex < 0) throw; // not a heir
		uint totalPoints = 0;
		for (uint8 i = 0; i < heirsNumber; i++) {
			totalPoints += points[heirs[i]];
		}
		uint amount = this.balance * points[heirs[uint256(heirIndex)]] / totalPoints;
		if (this.balance < amount) {
			amount = this.balance;
		}
		msg.sender.transfer(amount);
		removeHeir(msg.sender);
		if (heirsNumber == 0) {
			selfdestruct(owner);
		}
	}
	
}