# Simple wallet contract with inheritance feature. #

You can use this contract to store your funds, send funds to an account of your choice and add heirs that will inherit the funds if you are not able to access them anymore, for example, in case of death.

# Usage #

* To create a new heritable wallet contract you need to use the ```create(address beneficiary, uint periodInDays)``` of the already deployed factory contract. This will return the new wallet contract address.

* To make deposits send funds directly to the wallet contract address.

* To prove you are alive and active use ```checkIn()``` method periodically (default period is set to 365 days). This will extend the active status of the owner for the period specified in the contract.

* To change the check-in period you can call ```setCheckInPeriod(uint periodInDays)``` by specifying the period in days.

* Use ```sendFunds(address receiver, uint amount, bytes data)``` method to send a chosen amount to a specific address along with extra data.

* To change ownership of the contract you can use ```transferOwnership(address newOwner)``` giving the new owner address as argument.

* Add an heir by calling ```setHeir(address heir, uint8 inheritancePoints, uint periodInDays)``` specifying the heir's Ethereum address, his inheritance points and a preset check-in period. Heirs will get a share in the inheritance directly proportional with their number points. You can think of these as percentages. To remove an heir you need just to call this method with a 0 value for inheritance points.

* For every heir added a new wallet contract is created and it is owned and controlled by the original owner. A heir is only the beneficiary of the wallet and can become the owner only after the original owner becomes unavailable. You can add sub-heirs to heirs so that if heirs aren't available to claim their share this will propagate to sub-heirs.

* A designated heir can claim his share in the inheritance once the owner hasn't checked in for the period of time set in the contract. Heirs should use ```unlock()``` method for this. If conditions apply a specific share of the funds will be transferred to the heir's address, removing the heir from the list of heirs so that he can claim the inheritance only once. This also makes the heir the owner of the wallet contract and from this moment he is in total control of the contract and funds.

* If a heir happens to be unavailable as well, sub-heirs can call the ```unlock()``` method for them so that the contract ownership is transfered to the heir, a necessary step before sub-heirs can claim their share from the unavailable heir.

* If you don't need the contract anymore you can call ```destroy()``` method which will return all funds to the owner's address.

# Disclaimer #

Make sure you **read, understand and test the code** before using it on the Main Ethereum Network. 

This version is still a work in progress and can change at any time. Any contributions, especially bug reports, are welcome as it is intended for free use.

I strongly encourage you to deploy the contract on a testnet as this was not tested enough yet to be considered safe to use.

Enjoy!

# Future plans #

We are in the process of creating an interface for this contract so that you can view all your wallet contracts, inherited wallets and interact with them.
