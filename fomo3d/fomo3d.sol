// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Fomo3d is Ownable{
    address payable public  pot; //contract address    
    address public lastBid; //winner
    uint256 public winnerAmount = 0;
    uint256 public potMoney = 0; //contract balance
    uint256 public keySold = 0; 
    uint256 public potEndTime = 0;
    uint256 holderMintPrice = 0;
    uint256 holderPotPrice = 0;
    uint256 public startPrice = 1 * 10 ** 18;
    uint256 public increasePrice = 1 * 10 ** 17;
    address payable public admin; // admin address
    uint256 public adminBalance = 0;
    uint256 nextRound = 0;
    mapping (address => uint256) public keyHolder;
    mapping (address => uint256) public claimedAmount;
    mapping (address => uint256) public referral;


    constructor(){
        potEndTime = block.timestamp + 8 hours;
    }

    modifier isTimerRunning() {
        require(potEndTime >= block.timestamp, "Pot Closed");
        _;
    }

    modifier isTimerEnd() {
        require(potEndTime < block.timestamp, "Pot is runing");
        require(potMoney > 0, "Don't have money");
        _;
    }

   

    function potTimer( uint256 time) public onlyOwner returns(bool){
        require(time > block.timestamp, "Pot time should be greater then current time stamp");
        potEndTime = time;
        return true;
    }
    
    function addAdminAccount( address payable adminAddress) public onlyOwner returns(bool){
        require( admin == 0x0000000000000000000000000000000000000000 , "Admin account already created by owner");
        admin = adminAddress;
        return true;
    }

  
    function mintKey(uint mintAmount, address referralAddress) public payable isTimerRunning returns (bool) {
        require(mintAmount >= (startPrice + (keySold * increasePrice)), "Amount is less then price !");
        keySold++;
        lastBid = msg.sender;
        startPrice += increasePrice;
        keyHolder[msg.sender]++;
        potEndTime += 1 minutes;
        if(potEndTime > block.timestamp + 8 hours){
            potEndTime = block.timestamp + 8 hours;
        }          
        holderMintPrice += ( mintAmount * 30) / 100;           
        potMoney += ( mintAmount * 50 ) / 100;
        adminBalance += (( mintAmount * 5 ) / 100 );
        referral[referralAddress] += ( mintAmount * 15 ) / 100;
        return true;
    }
  
    //-------------------------------pot price distribution-after-end-timer------------------------------

    function potDistribution() public isTimerEnd returns (bool){    
        winnerAmount = ( potMoney * 25 ) / 100;
        payable (lastBid).transfer( winnerAmount);         
        holderPotPrice = keySold /(( potMoney * 175 ) / 10**3);
        adminBalance += (( potMoney * 25 ) /10**3 );   
        nextRound += (( potMoney * 75 ) / 10**3);  
        potMoney = potMoney - (winnerAmount + holderPotPrice + adminBalance + nextRound);
        return true;
    }    

    //------------------------------end-pot price distribution-------------------------------

    // ----------------------------claim-mint-amount-by-Holder---------------------------------

    function claimHoldAmount() public returns (bool){
        uint256 holderMintPricePer =  holderMintPrice / keySold;
        uint256 holderPotPricePer =  holderPotPrice / keySold;
        uint256 claimableMintAmount = (( holderMintPricePer * 50 ) / 100) * keyHolder[msg.sender];
        require(keyHolder[msg.sender] > 0, "You had not sold any key yet!");
            if(potEndTime >= block.timestamp){
                require(claimableMintAmount >= claimedAmount[msg.sender], "You have already claimed !" );
                payable(msg.sender).transfer(claimableMintAmount - claimedAmount[msg.sender]);
                claimedAmount[msg.sender] += (claimableMintAmount - claimedAmount[msg.sender]);
                holderMintPrice = holderMintPrice - claimableMintAmount;
                potMoney -= holderMintPrice;
                return true;
            }else{
                payable(msg.sender).transfer((holderMintPricePer * keyHolder[msg.sender]) +  holderPotPricePer);
                claimedAmount[msg.sender]++;
                holderMintPrice = (holderPotPricePer + (holderMintPricePer * keyHolder[msg.sender])) - claimedAmount[msg.sender];
                holderPotPrice -= holderPotPricePer;
                potMoney -= holderPotPricePer;
                return true;
            }             
    }
    
    // ---------------------------End-claim-mint-amount-by-Holder---------------------------------

    // ----------------------------claim-mint-amount-by-admin---------------------------------

    function claimAdmin(address payable adminAddress) public returns (bool){
        require( adminAddress == admin, "You are not authorized to claim this amount !");
        require( adminBalance != 0, "You don't have any amount to claim !");
        adminAddress.transfer(adminBalance);
        potMoney = potMoney - adminBalance;
        adminBalance = 0 ;        
        return true;
    }
    
    // ---------------------------End-claim-mint-amount-by-admin---------------------------------

    // ----------------------------Referral-mint-amount---------------------------------------

    function referralClaim() public returns (bool){
        require(referral[msg.sender] > 0, "You don't have any referral amount");
        uint256 referralAmount = referral[msg.sender];       
        payable(msg.sender).transfer(referralAmount);
        delete referral[msg.sender];
        return true;
    }

    // ---------------------------End-Referral-mint-amount---------------------------------------

    
     
}