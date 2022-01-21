//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Change required: './../utils/npm/openzeppelin/' -> '@openzeppelin'
import "./../utils/npm/openzeppelin/contracts/access/Ownable.sol";
import "./../utils/npm/openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./../utils/npm/openzeppelin/contracts/utils/Counters.sol";
import "./../utils/Base64_bytes.sol";

contract Basic_SVG_Collection_On_Chain is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public tokenCounter;
    // Collection owner
    address public owner;

    // Contains all the properties of our NFT
    struct Attribute {
        string name;
        string description;
    }
    // MAPPINGS
    // Mapping from tokenID to its attributes
    mapping(uint256 => Attribute) public attributes;

    // Emited when the owner created a token
    event TokenMinted(uint256 indexed tokenId, string tokenURI);

    constructor(string memory _name, string memory _symbol)
        payable
        ERC721(_name, _symbol)
    {
        owner = msg.sender;
    }

    /**
     * @dev The money transactions will be catched here
     */
    receive() external payable {}

    /**
     * @dev Mints a given SVG as a NFT to the sender
     * SVG example: <svg xmlns='http://www.w3.org/2000/svg' width='500' height='500' viewBox='0 0 500 500'><circle cx='250' cy='250' r='200' stroke='blue' stroke-width='20' fill='pink'/></svg>
     */
    function safeMint(
        string memory _name,
        string memory _description,
        string memory _svg
    ) public {
        require(owner == msg.sender);
        _safeMint(msg.sender, tokenCounter.current());
        attributes[tokenCounter.current()] = Attribute(_name, _description);
        // <svg width='500' height='500' viewBox='0 0 500 500' xmlns='http://www.w3.org/2000/svg'><circle cx='250' cy='250' r='200' stroke='blue' stroke-width='20' fill='yellow'/></svg>
        string memory imgURI = _getImageURI(_svg);
        string memory tokenURI = _getTokenURI(imgURI, tokenCounter.current());
        // for this specific NFT, give it this token URI
        _setTokenURI(tokenCounter.current(), tokenURI);
        emit TokenMinted(tokenCounter.current(), tokenURI);
        tokenCounter.increment();
        //tokenCounter = tokenCounter + 1;
    }

    function _getImageURI(string memory _svg)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(string(abi.encodePacked(_svg))))
                )
            );
    }

    function _getTokenURI(string memory _imageURI, uint256 tokenID)
        internal
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                attributes[tokenID].name,
                                '","description": "',
                                attributes[tokenID].description,
                                '","attributes": "",',
                                '"image":"',
                                _imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    /**
     * Here we can add royalties if we want
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * After Solidity 0.8.0 Release we can easily burn our contracts from the chain
     */
    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        super._burn(tokenId);
    }

    function burn(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender);
        _burn(_tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
