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
    
    //Mapping - each Item struct has an address in mapping
    mapping(address => LeaseItem) public leaseItems;
    
    //Constructor
    function Item (string name_, string desc_, uint value_) public {
        this.owner = msg.sender;
        this.name = name_;
        this.desc = desc_;
        this.value = value_;
        this.created = block.timestamp;
        this.available = true;
    }
    
        //Access modification - Func based on owner
    modifier ownerFunc {
        require(this.owner == msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
    
        modifier nonOwnerFunc {
        require(this.owner != msg.sender);                //Better than throw - deprecated to 'require'
        _;                                           //executes check BEFORE func in this case
    }
    
    modifier leaseeFunc {
        require(this.leasee == msg.sender);              //Better than throw - deprecated to 'require'
        _;                                          //executes check BEFORE func in this case
    }
    
    //Lease requires a payment to the Item/contract address, part goes to owner as rent while the rest remains in contract
    function lease() public payable nonOwnerFunc {   
        require(this.available == true);                         //Item must be available to be leased
        require(msg.value >= this.value);
        if(msg.value >= this.value) {
            this.leasee = msg.sender;                            //leasee will be set to sender of funds
            address(this.owner).send(msg.value/4);               //Send owner 1/4 of value as rent - keep rest in contract address
            this.available = false;
            this.leased = block.timestamp;
        } else { return; }
    }
    
    //Only owner can verify the Item has been returned - remaining balance will be paid back to leasee
    function returnItem() public ownerFunc {
        require(this.available == false);                        //Can't return an un leased item
        if(this.balance > 0) { address(this.leasee).send(this.balance); }
        this.leasee = 0;                                         //Clear leasee address - no longer leasee
        this.available = true;
        this.leased = 0;                                         //Reset leased timestamp
    }
    
    //(Only) Leasee can pay towards balance - can trigger claim of ownership
    function payOut() public leaseeFunc  {
        require(this.available == false);
        address(this.owner).send(getBalance());                  //Send funds to owner from Item wallet
        //claimItem;
    }
    
    //If balance has been paid out to owner, renter can claim ownership of Item
    function claimItem() public leaseeFunc {
        require(this.balance == 0);
        if(this.balance == 0) { this.owner = this.leasee; }            //Renter now becomes the owner
    }

//Todo: transfer funds daily
//Todo: check balance and call claimItem after event
    
    //Only owner can set value for Item    
    function setName(string newName) ownerFunc {
        this.name = newName;
    }
    
    function getName() returns (string) {
        return this.name;
    }
    
    //Current timestamp minus created timestamp
    function getAge() returns (uint) {
        return block.timestamp - this.created;
    }
    
    //Current timestamp minus leased timstamp
    function getLeasedTime() returns (uint) {
        require(this.leased > 0 && this.available == false);                            
        return block.timestamp - this.leased;
    }
    
    //Only owner can set value for Item
    function setDesc(string desc_) ownerFunc {
        this.desc = desc_;
    }
    
    function getDesc() returns (string) {
        return this.desc;
    }
    
    //Only owner can set value for Item
    function setValue(uint value_) ownerFunc {
        this.value = value_;
    }
    
    function getValue() returns (uint) {
        return this.value;
    }
    
    //Only owner can set leseeAddress for Item
    function setLeasee(address leaseeAddr_) ownerFunc {
        this.leasee = leaseeAddr_;
    }
    
    //Get is public
    function getLeasee() returns (address) {
        return this.leasee;
    }  
    
    //Set availablity can only be done by return of item or change in ownership
    
    //Get is public
    function getAvailability() returns (bool) {
        return this.available;
    }
    
    //Get is public
    function getOwner() returns (address) {
        return this.owner;
    }
    
    //Get is public
    function getBalance() returns (uint) {
        return this.balance;
    }   
    
    //Kill instance of contract or kill contract on blockchain?
    function kill() ownerFunc {
        selfdestruct(this.owner);
    }
}