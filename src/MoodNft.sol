// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title MoodNft
 * @notice This contract represents an NFT that reflects the owner's mood
 * @dev Inherits from OpenZeppelin's ERC721 implementation
 */
contract MoodNft is ERC721 {
    error MoodNft__CannotFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;

    mapping(uint256 => Mood) private s_tokenIdToMood;

    enum Mood {
        HAPPY,
        SAD
    }

    /**
     * @notice Initializes the contract with the given image URIs
     * @param happySvgImageUri The SVG image URI for the happy mood
     * @param sadSvgImageUri The SVG image URI for the sad mood
     */
    constructor(string memory happySvgImageUri, string memory sadSvgImageUri) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvgImageUri;
        s_sadSvgImageUri = sadSvgImageUri;
    }

    /**
     * @notice Mints a new NFT with the default mood set to HAPPY
     * @dev Mints the NFT to the caller's address
     */
    function mintNft() public {
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    /**
     * @notice Flips the mood of the specified NFT
     * @dev The caller must be the owner of the NFT to flip its mood
     * @param tokenId The ID of the NFT whose mood is to be flipped
     */
    function flipMood(uint256 tokenId) external {
        if (!_isAuthorized(_ownerOf(tokenId), msg.sender, tokenId)) revert MoodNft__CannotFlipMoodIfNotOwner();

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) s_tokenIdToMood[tokenId] = Mood.SAD;
        else s_tokenIdToMood[tokenId] = Mood.HAPPY;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**
     * @notice Returns the token URI for the specified token ID
     * @dev Overrides the tokenURI function from ERC721
     * @param tokenId The ID of the token whose URI is to be returned
     * @return The token URI string
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) imageURI = s_happySvgImageUri;
        else imageURI = s_sadSvgImageUri;

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description": "An NFT that reflects the owners mood.", "attributes": [{"trait_type": "moodness", "value": 100}], "image": "',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
