//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Change required: './../npm/openzeppelin/' -> '@openzeppelin'
import "./../npm/openzeppelin/contracts/access/Ownable.sol";
import "./../npm/openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./../npm/openzeppelin/contracts/utils/Counters.sol";
import "./../utils/Base64.sol";

contract Basic_SVG_Collection_On_Chain is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address public owner;
    mapping(uint256 => Attributes) public attributes;

    struct Attributes {
        string name;
        string description;
    }

    event TokenMinted(uint256 tokenId, string tokenUri);

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
     * SVG example: "<svg width='50' height='50' xmlns='http://www.w3.org/2000/svg'><circle cx='25' cy='25' r='20' stroke='blue' stroke-width='2' fill='yellow' /></svg>"
     */
    function safeMint(
        string memory _name,
        string memory _description,
        string memory _svg
    ) public {
        require(owner == msg.sender); // Only the owner can mint the NFT
        _safeMint(msg.sender, _tokenIdCounter.current());

        // Creating the TokenURI
        string memory imageURI = getImageURI(_svg);
        string memory tokenURI = getTokenURI(
            _tokenIdCounter.current(),
            imageURI
        );
        attributes[_tokenIdCounter.current()] = Attributes(_name, _description);

        _setTokenURI(_tokenIdCounter.current(), tokenURI);
        emit TokenMinted(_tokenIdCounter.current(), tokenURI);
        _tokenIdCounter.increment();
    }

    /**
     * @dev Given one SVG, encodes it using Base64 and obtains the Token URI
     */
    function getImageURI(string memory _svg)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgEncoded = Base64.encode(
            string(abi.encodePacked(_svg))
        );
        return string(abi.encodePacked(baseURL, svgEncoded));
    }

    /**
     * @dev Given an image URI, encodes it to Base64 and obtains the token URI
     */
    function getTokenURI(uint256 _tokenId, string memory _svgURI)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        string(
                            abi.encodePacked(
                                '{"name":"',
                                attributes[_tokenId].name,
                                '",',
                                '"description": "',
                                attributes[_tokenId].description,
                                '",',
                                '"attributes": "",',
                                '"image":"',
                                _svgURI,
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

    function burnToken(uint256 _tokenId) public {
        require(owner == msg.sender);
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

    /**
     * @dev Given a number, it returns his string
     */
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
