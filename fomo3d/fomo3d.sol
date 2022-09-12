// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Fomo3d is Ownable{
    address payable public  pot; //contract address
    address payable public admin; // admin address
    address public lastBid;
    uint256 public potMoney = 0;
    uint256 public keySold = 0;
    uint256 public potEndTime = 0;
    uint256 public startPrice = 1 * 10 ** 18;
    uint256 public increasePrice = 1 * 10 ** 17;
    uint256 [] public mintDistributionPer;
    uint256 [] public potDistributionPer;
    
    address payable[] public holder;
    address payable public referralAddress;

    constructor(){
        potEndTime = block.timestamp + 8 hours;
    }
   
    //------------------------------Timer-will-stop-exactly-at-0-seconds-----------------------
    modifier checkTimer() {
        require(potEndTime >= block.timestamp, "Pot Closed");
        _;
    }

    modifier timeOut() {
        require(potEndTime > block.timestamp, "Pot is runing");
        potEndTime = 0;
         require(potMoney > 0, "Don't have money");
        _;
    }

    function mintKey() public payable checkTimer returns (bool) {
        require(msg.value >= keyPrice(), "Less DOGE");
        uint mintAmount = msg.value;
        keySold++;
        lastBid = _msgSender();
        potEndTime += 1 minutes;
        if(potEndTime > block.timestamp + 8 hours){
            potEndTime = block.timestamp + 8 hours;
        }           
        uint256 potMinPrice = (  mintAmount * 50 ) / 100;          
        uint256 adminMinPrice = ( mintAmount * 5 ) / 100;          
        uint256 holderMinPrice = (mintAmount * 30)/100;        
        uint256 referralMinPrice = (mintAmount * 15)/100;

        potMoney += potMinPrice;
        admin.transfer( adminMinPrice );

        uint256 amountPerHolder = holder.length / holderMinPrice;
        for(uint256 i=0; i<holder.length; i++){
            holder[i].transfer( amountPerHolder );
        }      

        referralAddress.transfer(referralMinPrice);

        return true;
    }

    function keyPrice() public view returns(uint) {
        return startPrice + (keySold * increasePrice);
    }

    function updateMintDistributionPer(uint[] memory _per) onlyOwner public returns (bool) {
        mintDistributionPer = _per;
        return true;
    }

    function updatePotDistributionPer(uint[] memory _per) onlyOwner public returns (bool) {
        potDistributionPer = _per;
        return true;
    }

    //-------------------------------pot price distribution--------------------------------

    function potDistribution() public timeOut returns (bool){        
        uint256 winnerAmount = (potMoney * 25)/100;
        uint256 holderPotAmount = (potMoney * 175)/10**3;         
        uint256 adminPotAmount = (potMoney * 25)/10**3;

        address payable winnerAddress = holder[holder.length - 1];
        winnerAddress.transfer( winnerAmount );

        uint256 amountPerHolder = holder.length / holderPotAmount;
        for(uint256 i=0; i<holder.length; i++){
            holder[i].transfer( amountPerHolder );
        } 

        admin.transfer( adminPotAmount );
       
        return true;
    }    

     //------------------------------end-pot price distribution----------------------------
    


}