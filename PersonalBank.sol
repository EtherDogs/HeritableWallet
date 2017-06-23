pragma solidity ^0.4.10;

contract PersonalBank {
	
	address public owner;
	mapping(address => uint8) public points;
	uint public lastCheckInTime;
	uint public checkInPeriod;
	uint public totalPoints = 0;
	
	/* constructor */
	function PersonalBank() {
		owner = msg.sender;
		setCheckInPeriod(365); // 1 year default period
	}
	
	/* anyone can deposit funds by sending funds to the contract address */
	function() payable {}
	
	modifier onlyOwner() {
		if (msg.sender != owner) throw; 
		_; // function body
		lastCheckInTime = now;
	}
	
	modifier onlyHeir() {
		if (points[msg.sender] == 0) throw; 
		_; // function body
	}
	
	/* called by owner to prove he is alive */
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
	}
	
	/* called by owner to add/modify an heir; inheritance shares are directly proportional to the points assigned */
	function setHeir(address heir, uint8 inheritancePoints) onlyOwner {
		totalPoints -= points[heir];
		points[heir] = inheritancePoints;
		totalPoints += inheritancePoints;
	}
	
	/* called by an heir to collect his share in the inheritance */
	function claimInheritance() onlyHeir {
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
	
}