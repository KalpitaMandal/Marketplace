//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Acoin is ERC20 {
    constructor() ERC20("Acoin","AC") public {
        _mint(msg.sender,10000);
    }
}
contract Hats is ERC721 {
    constructor() ERC721("Hats","HAT") public {
    }
}

contract Marketplace is Hats{
    
    address AcoinInstance;
    address HatInstance;
    IERC721 AcoinPayment;
    
    struct HatSaleItems{
        uint id;
        uint256 price;
        string hatColour;
        address hatOwner;
    }
    HatSaleItems[] public items;
    
    struct SaleCounter{
        string colour;
        uint256 salePrice;
    }
    SaleCounter[] public hatsale;
    
    mapping(string => bool) _hatExists;
    mapping(uint256 => HatSaleItems[]) _hatValue;
    
    uint256 hatId = 1;
    uint public amount;
    
    fallback () external {}
    
    constructor(address add_erc20, address add_erc721) public {
        AcoinInstance = add_erc20;
        HatInstance = add_erc721;
    }
    
    function AddHatForSale(string memory _colour, uint256 _price) public {
        require(!_hatExists[_colour]);
        require(_price<100);
        items.push(HatSaleItems(hatId,_price,_colour,msg.sender));
        hatsale.push(SaleCounter(_colour,_price));
        // _mint(msg.sender, hatId);
        // transferFrom(msg.sender,address(this), hatId);
        _hatExists[_colour] = true;
        hatId++;
    }
    
    function HatsForSale() public view returns(SaleCounter[] memory){
        return hatsale;
    }
    
    function BuyHat(uint _hatid) public {
        amount = FindPrice(_hatid);
        address _to = FindOwner(_hatid);
        AcoinPayment = IERC721(AcoinInstance);
        AcoinPayment.transferFrom(msg.sender,address(this),1);
        AcoinPayment.transferFrom(msg.sender,_to,amount-1);
        _mint(msg.sender, _hatid);
        // transferFrom(_to,msg.sender, _hatid);
        delete items[_hatid-1];
        delete hatsale[_hatid-1];
    }    
    
    function FindPrice(uint _hatid) public view returns(uint256) {
        for(uint i = 0; i < items.length; i++){
            if(items[i].id == _hatid){
                return(items[i].price);
            }
        }
    }
    
    function FindOwner(uint _hatid) public view returns(address) {
        for(uint i = 0; i < items.length; i++){
            if(items[i].id == _hatid){
                return(items[i].hatOwner);
            }
        }
    }
}
