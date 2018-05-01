pragma solidity ^0.4.0;

contract Item {
    
    struct LeaseItem {
        address owner;
        address leasee;
        string name;
        string desc;
        uint created;
        uint leased;       
        uint value;
        bool available;
        uint balance;
    }
    
    LeaseItem item;
    
    //Mapping - each Item struct has an address in mapping
    mapping(address => LeaseItem) leaseItems;
    
    //Constructor
    constructor (string name_, string desc_, uint value_) public payable{
        LeaseItem storage sender = leaseItems[msg.sender];
        sender.owner = msg.sender;
        sender.name = name_;
        sender.desc = desc_;
        sender.value = value_;
        sender.created = block.timestamp;
        sender.available = true;
    }
    
    //Access modification - Func based on owner
    modifier ownerFunc {
        require(leaseItems[msg.sender].owner == msg.sender);    //Better than throw - deprecated to 'require'
        _;                                                       //executes check BEFORE func in this case
    }
    
        modifier nonOwnerFunc {
        require(leaseItems[msg.sender].owner != msg.sender);     //Better than throw - deprecated to 'require'
        _;                                                        //executes check BEFORE func in this case
    }
    
    modifier leaseeFunc {
        require(leaseItems[msg.sender].leasee == msg.sender);              //Better than throw - deprecated to 'require'
        _;                                          //executes check BEFORE func in this case
    }
    
    //Lease requires a payment to the Item/contract address, part goes to owner as rent while the rest remains in contract
    function lease() public payable nonOwnerFunc {  
         LeaseItem storage sender = leaseItems[msg.sender];
        require(sender.available == true);                         //Item must be available to be leased
        require(msg.value >= sender.value);
        if(msg.value >= sender.value) {
            sender.leasee = msg.sender;                            //leasee will be set to sender of funds
            address(sender.owner).transfer(msg.value/4);               //Send owner 1/4 of value as rent - keep rest in contract address
            sender.available = false;
            sender.leased = block.timestamp;
        } else { return; }
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        LeaseItem storage sender = leaseItems[msg.sender];
        require(sender.available == false);                        //Can't return an un leased item
        if(sender.balance > 0) { address(sender.leasee).transfer(sender.balance); }
        _leaseItems[msg.sender].leasee = 0;                                         //Clear leasee address - no longer leasee
        _leaseItems[msg.sender].available = true;
        _leaseItems[msg.sender].leased = 0;                                         //Reset leased timestamp
    }
    
    //(Only) Leasee can pay towards balance - can trigger claim of ownership
    function payOut() public leaseeFunc  {
        LeaseItem storage sender = leaseItems[msg.sender];
        require(sender.available == false);
        address(sender.owner).tansfer(getBalance());                  //Send funds to owner from Item wallet
        //claimItem;
    }
    
    //If balance has been paid out to owner, renter can claim ownership of Item
    function claimItem() public leaseeFunc {
        LeaseItem storage sender = leaseItems[msg.sender];
        require(sender.balance == 0);
        if(sender).balance == 0) { sender.owner = sender.leasee; }            //Renter now becomes the owner
    }

//Todo: transfer funds daily
//Todo: check balance and call claimItem after event
    
    //Only owner can set value for Item    
    function setName(string newName) ownerFunc {
        leaseItems[msg.sender].name = newName;
    }
    
    function getName() returns (string) {
        return leaseItems[msg.sender].name;
    }
    
    //Current timestamp minus created timestamp
    function getAge() returns (uint) {
        return block.timestamp - leaseItems[msg.sender].created;
    }
    
    //Current timestamp minus leased timstamp
    function getLeasedTime() returns (uint) {
        LeaseItem storage sender = leaseItems[msg.sender];
        require(sender.leased > 0 && sender.available == false);                            
        return block.timestamp - sender.leased;
    }
    
    //Only owner can set value for Item
    function setDesc(string desc_) ownerFunc {
        leaseItems[msg.sender].desc = desc_;
    }
    
    function getDesc() returns (string) {
        return leaseItems[msg.sender].desc;
    }
    
    //Only owner can set value for Item
    function setValue(uint value_) ownerFunc {
        leaseItems[msg.sender].value = value_;
    }
    
    function getValue() returns (uint) {
        return leaseItems[msg.sender].value;
    }
    
    //Only owner can set leseeAddress for Item
    function setLeasee(address leaseeAddr_) ownerFunc {
        leaseItems[msg.sender].leasee = leaseeAddr_;
    }
    
    //Get is public
    function getLeasee() returns (address) {
        return leaseItems[msg.sender].leasee;
    }  
    
    //Set availablity can only be done by return of item or change in ownership
    
    //Get is public
    function getAvailability() returns (bool) {
        return leaseItems[msg.sender].available;
    }
    
    //Get is public
    function getOwner() returns (address) {
        return leaseItems[msg.sender].owner;
    }
    
    //Get is public
    function getBalance() returns (uint) {
        return leaseItems[msg.sender].balance;
    }   
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() ownerFunc {
        selfdestruct(leaseItems[msg.sender].owner);
    }
}