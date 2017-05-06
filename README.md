# Simple deposit contract with inheritance feature. #

You can use this contract to store your funds, send funds to an account of your choice and add heirs that will inherit the funds if you are not able to access them anymore, for example, in case of death.

# Usage #

* Deploy this contract to the Ethereum blockchain (using Mist for example).

* Send funds directly to the contract address to make deposits.

* To prove you are alive and active use ```checkIn()``` method periodically (default period is set to 365 days). This will extend the active status of the owner for the period specified in the contract.

* To change the check in period you can call ```setCheckInPeriod(uint period)``` by specifying the period in days.

* Use ```sendFunds(address receiver, uint amount)``` method to send a chosen amount to a specific address.

* Add an heir by calling ```setHeir(address heir, uint8 inheritancePoints)``` specifying the heir's Ethereum address and number of points. Heirs will get a share in the inheritance directly proportional with their number points. You can think of these as percentages.

* You can also remove an heir by calling ```removeHeir(address heir)```.

* If you don't need the contract anymore you can call ```destroy()``` method which will return all funds to the owner's address.

* Finally and most importantly, a designated heir can claim his share in the inheritance once the owner hasn't checked in for the period of time set in the contract. Heirs should use ```requestInheritance()``` method for this. If conditions apply a specific share of the funds will be transferred to the heir's address, also removing the heir from the list of heirs so that he can claim the inheritance only once.

# Disclaimer #

Make sure you **read, understand and test the code** before using it on the Main Ethereum Network. 

I strongly encourage you to deploy the contract on a testnet as this was not tested enough yet to be considered safe to use.

Enjoy!
