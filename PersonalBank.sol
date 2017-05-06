pragma solidity ^0.4.10;

contract PersonalBank {
    
    address public owner;
    uint checkpoint;
    uint checkInPeriod;
    mapping(address => uint8) public points;
    address[] heirs;
    uint8 heirsNumber = 0;

    function PersonalBank(uint period) {
        owner = msg.sender;
        checkInPeriod = period;
        checkIn();
    }
    
    function indexOfHeir(address heir) returns(int) {
        uint8 i = heirsNumber;
        while (i > 0) {
            i--;
            if (heirs[i] == heir) {
                return i;
            }
        }
        return -1;
    }
    
    modifier onlyOwner() { if (msg.sender != owner) throw; _; }
    
    function checkIn() onlyOwner {
        checkpoint = now + checkInPeriod * 1 days;
    }
    
    function sendFunds(address receiver, uint amount) onlyOwner returns(bool success) {
		if (this.balance < amount) throw;
		return receiver.send(amount);
	}
	
	function requestInheritance() returns(bool success) {
	    if (now <= checkpoint) throw; // owner not dead
	    int heirIndex = indexOfHeir(msg.sender);
	    if (heirIndex < 0) throw; // not a heir
	    uint totalPoints = 0;
	    for (uint8 i = 0; i < heirsNumber; i++) {
	        totalPoints += points[heirs[i]];
	    }
	    uint amount = this.balance * points[heirs[uint256(heirIndex)]] / totalPoints;
		if (this.balance < amount) throw;
		removeHeir(msg.sender);
		return msg.sender.send(amount);
	}
	
	function setHeir(address heir, uint8 inheritancePoints) onlyOwner {
	    int heirIndex = indexOfHeir(heir);
	    if (heirIndex < 0) { // not a heir
	        heirIndex = heirsNumber;
	        heirs.push(heir);
	    }
	    points[heirs[uint256(heirIndex)]] = inheritancePoints;
	}
	
	function removeHeir(address heir) onlyOwner {
	    int heirIndex = indexOfHeir(heir);
	    if (heirIndex >= 0) { // is a heir
	        delete points[heir];
	        heirs[uint256(heirIndex)] = heirs[heirsNumber - 1];
	        heirsNumber--;
	    }
	}

}