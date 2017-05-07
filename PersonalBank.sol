pragma solidity ^0.4.10;

contract PersonalBank {
	
	address public owner;
	mapping(address => uint8) public points;
	uint checkInDeadline;
	uint checkInPeriod;
	uint public totalPoints = 0;
	
	/* constructor */
	function PersonalBank() {
		owner = msg.sender;
		setCheckInPeriod(365);
	}
	
	modifier onlyOwner() { if (msg.sender != owner) throw; _; }
	modifier onlyHeir() { if (points[msg.sender] == 0) throw; _; }
	
	/* anyone can deposit funds by sending funds to the contract address */
	function () payable {}
	
	/* called by owner to prove he is alive */
	function checkIn() onlyOwner {
		checkInDeadline = now + checkInPeriod * 1 days;
	}
	
	/* called by owner to change check in period */
	function setCheckInPeriod(uint period) onlyOwner {
		checkInPeriod = period;
		checkIn();
	}
	
	/* called by owner to send funds to custom accounts */
	function sendFunds(address receiver, uint amount) onlyOwner returns(bool success) {
		if (this.balance < amount) throw;
		return receiver.send(amount);
	}
	
	/* called by owner to add/modify an heir; inheritance shares are directly proportional to the points assigned */
	function setHeir(address heir, uint8 inheritancePoints) onlyOwner {
		totalPoints -= points[heir];
		points[heir] = inheritancePoints;
		totalPoints += inheritancePoints;
	}
	
	/* called by an heir to request his share in the inheritance */
	function requestInheritance() onlyHeir {
		if (now <= checkInDeadline) throw; // owner not dead
		uint amount = this.balance * points[msg.sender] / totalPoints;
		if (this.balance < amount) {
			amount = this.balance;
		}
		msg.sender.transfer(amount);
		totalPoints -= points[msg.sender];
		delete points[msg.sender];
		if (totalPoints == 0) {
			selfdestruct(owner);
		}
	}
	
	/* called by owner to terminate this contract */
	function destroy() onlyOwner {
		selfdestruct(owner);
	}
	
}