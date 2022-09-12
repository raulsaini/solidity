// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Fomo3d is Ownable{
    address payable public  pot; //contract address    
    address public lastBid;
    uint256 public potMoney = 0;
    uint256 public keySold = 0;
    // uint256 public claimedHolder = 0;
    uint256 public potEndTime = 0;
    uint256 holderMintPrice = 0;
    uint256 holderPotPrice = 0;
    uint256 public startPrice = 1 * 10 ** 18;
    uint256 public increasePrice = 1 * 10 ** 17;
    uint256 [] public mintDistributionPer;
    uint256 [] public potDistributionPer;
    address payable public admin; // admin address
    uint256 public adminMintAmount = 0;
    // address payable public referralAddress;
   
    mapping (address => uint256) public keyHolder;
    mapping (address => uint256) public claimedHolder;

    // struct referralData{ 
    //     uint amount;
    //     }
    // mapping (address => referralData) public referral;

    constructor(){
        potEndTime = block.timestamp + 8 hours;
    }

    modifier isTimerRunning() {
        require(potEndTime >= block.timestamp, "Pot Closed");
        _;
    }

    modifier isTimerEnd() {
        require(potEndTime > block.timestamp, "Pot is runing");
         require(potMoney > 0, "Don't have money");
        _;
    }


    function potTimer( uint256 time) public onlyOwner returns(bool){
        require(time > block.timestamp, "Pot time should be greater then current time stamp");
        potEndTime = time;
        return true;
    }
   
  
    function mintKey(uint amount, address referralAddress) public payable isTimerRunning returns (bool) {
        require(msg.value >= (startPrice + (keySold * increasePrice)), "Less DOGE");
        uint256 mintAmount = msg.value;
        keySold++;
        lastBid = _msgSender();
        keyHolder[_msgSender()]++;
        potEndTime += 1 minutes;
        if(potEndTime > block.timestamp + 8 hours){
            potEndTime = block.timestamp + 8 hours;
        }          
        holderMintPrice += ( mintAmount * 30) / 100;           
        potMoney += ( mintAmount * 50 ) / 100;
        adminMintAmount += (( mintAmount * 5 ) / 100 );
        referralAddress.transfer(( mintAmount * 15 ) / 100);
        // referral[referralAddress] =  referralData(( mintAmount * 15 ) / 100) ++;
        return true;
    }
  
    //-------------------------------pot price distribution-after-end-timer------------------------------

    function potDistribution() public isTimerEnd returns (bool){         
        payable (lastBid).transfer(( potMoney * 25 ) / 100 ); 
        holderPotPrice = keySold /(( potMoney * 175 ) / 10**3);
        admin.transfer(( potMoney * 25 ) /10**3 );   
        return true;
    }    

     //------------------------------end-pot price distribution----------------------------

    function claimHoldAmount( address payable keyAddress ) public returns (bool){
        uint holderMintPricePer =  holderMintPrice / keySold;
        uint holdMintCount = keyHolder[keyAddress] - claimedHolder[keyAddress];
        if(holdMintCount > 0){
            if(potEndTime >= block.timestamp){
                keyAddress.transfer( (( holderMintPricePer * 50 ) / 100) * holdMintCount);
                claimedHolder[keyAddress]++;
                return true;
            }else{
                keyAddress.transfer((holderMintPricePer * holdMintCount) +  holderPotPrice);
                claimedHolder[keyAddress]++;
                return true;
            }
        }else{
                return false;
        }        
    }
    // ----------------------------claim-mint-amount-by-admin---------------------------------
    function claimAdmin(address adminAddress) public returns (bool){
        require( adminAddress == admin, "You are not authorized to claim this amount");
        adminAddress.transfer(adminMintAmount);
        adminMintAmount = 0 ;
    }
    // ---------------------------end-claim-mint-amount-by-admin---------------------------------
    // function referralClaim( address payable keyAddress ) public returns (bool){

    // }


     
}