//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./metadata/ERC1155OnChainMetadata.sol";

contract PosterFactory is ERC1155OnChainMetadata {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    // Index of current PosterID.
    CountersUpgradeable.Counter private tokenId;

    function initialize(
        string memory name_,
        string memory symbol_,
        address royaltyRecipient_
    ) external initializer {
        __ERC1155_init("");
        __Context_init();
        __ERC165_init();
        name = name_;
        symbol = symbol_;
        contract_description = "Posters (Season 2) by Mint Songs. TODO: work with Dwight / Nathan to get more info here.";
        contract_image = "ipfs://QmWoaiiNB9NoDfj3q1xhMt6DJSAU8fMsNePuhH8gwbaKND";
        contract_external_link = "https://mintsongs.com";
        contract_seller_fee_basis_points = 300;
        contract_fee_recipient = royaltyRecipient_;
    }

    /**
     * @dev checks caller can create a new poster.
     * @param _maxSupply amount to supply the first owner
     */
    modifier createPreCheck(uint256 _maxSupply) {
        uint256 price = 5000000000000 * _maxSupply;
        require(
            msg.value >= price,
            string(
                abi.encodePacked(
                    "msg.value too low: Posters are not free hoe. pay up. required cost: ",
                    StringsUpgradeable.toString(price),
                    " wei"
                )
            )
        );
        _;
    }

    /**
     * @dev Creates a new Poster.
     * @param _name name of token
     * @param _description description of token
     * @param _imageUri imageUri of token
     * @param _royaltyRecipient address of the first recipient of royalty payments
     * @param _maxSupply amount to supply the first owner
     * @return tokenId newly created token ID
     */
    function createPoster(
        string memory _name,
        string memory _description,
        string memory _imageUri,
        address _royaltyRecipient,
        uint256 _maxSupply
    ) external payable createPreCheck(_maxSupply) returns (uint256) {
        tokenId.increment();
        uint256 id = tokenId.current();
        uint256 initialSupply = 1;
        _mint(msg.sender, id, initialSupply, "");
        emit URI(_imageUri, id);
        Poster memory newPoster = Poster(
            msg.sender,
            _name,
            _description,
            _imageUri,
            initialSupply,
            _maxSupply,
            _royaltyRecipient
        );
        poster[id] = newPoster;
        return id;
    }

    /**
     * @dev Receiving native token (MATIC / ETH).
     */
    receive() external payable {}

    /**
     * @dev Receiving other ERC20 tokens.
     */
    fallback() external payable {}
}
