// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract PhitNfts is ERC721Enumerable, Ownable{
    uint256 public _price = 0.01 ether;
    uint256 public maxTokenIds = 10;
    uint256 public tokenIds;
    uint256 public presaleEnded;

    bool public presaleStarted;
    bool public _paused; // Used to pause contract in case of an emergency

    string _baseTokenURI;

    mapping(address => uint) public listOfAddressesThatHaveMinted;

    IWhitelist whitelist;

    modifier onlyWhenNotPaused{
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("Phit NFTS", "PN"){
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 10 minutes; // Set presaleended time as current timestamp + 10minutes
    }

    function presaleMint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Phit Nfts");
        require(msg.value >= _price, "Ether sent is not enough");

        uint numOfIdsMinted = tokenIds + 1;
        listOfAddressesThatHaveMinted[msg.sender] = numOfIdsMinted;

        tokenIds = numOfIdsMinted;
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }


    // allows a user to mint 1 NFT per transaction after the presale has ended
    function mint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceeded maximum Phit Nfts");
        require(msg.value >= _price , "Ether sent is not enough");

        uint numOfIdsMinted = tokenIds + 1;
        listOfAddressesThatHaveMinted[msg.sender] = numOfIdsMinted;

        tokenIds = numOfIdsMinted;
        _safeMint(msg.sender, tokenIds);
    }

    //overides the Openzeppelin's ERC721 implementation which by default returned an empty string for the baseURI
    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
    }

    //makes the contract paused or unpaused
    function setPaused(bool val) public onlyOwner{
        _paused = val;
    }

    //sends all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //Function to receive Ether. msg,data must be empty
    receive() external payable {}

    //This function is called when msg.data is not empty
    fallback() external payable{}
}