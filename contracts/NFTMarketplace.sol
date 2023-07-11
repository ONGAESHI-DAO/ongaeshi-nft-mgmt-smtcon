// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

contract CourseToken is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Listing {
        address tokenAddress;
        uint256 tokenId;
        address nftOwner;
        uint256 price;
        uint256 index;
    }
    mapping(address => mapping(uint256 => Listing)) public listingMap;
    Listing[] public listings;

    ICourseTokenEvent public xEmitEvent;
    address public treasury;
    uint256 public treasuryCommission;
    uint256 public teacherCommission;
    address public gtAddress;

    function initialize(
        address _gtAddress,
        address _treasury,
        uint256 _treasuryCommission,
        uint256 _teacherCommission,
        address _emitEventAddr
    ) external initializer {
        require(_treasury != address(0), "_treasury is zero");
        require(_gtAddress != address(0), "_gtAddress is zero");
        gtAddress = _gtAddress;
        treasury = _treasury;
        treasuryCommission = _treasuryCommission;
        teacherCommission = _teacherCommission;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    function createListing(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        // check not lended out
        // check no need repair
        // xfer nft to this contract
        // write listing into storage
        require(
            ICourseToken(_tokenAddress).isLended(_tokenId) == address(0),
            "Token is on loan"
        );
        require(
            ICourseToken(_tokenAddress).repairCost(_tokenId) == 0,
            "Token needs repair"
        );

        IERC721Upgradeable(_tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        uint256 listingIndex = listings.length;
        Listing memory newListing;
        newListing.tokenAddress = _tokenAddress;
        newListing.tokenId = _tokenId;
        newListing.nftOwner = msg.sender;
        newListing.price = _amount;
        newListing.index = listingIndex;
        listings.push(newListing);
        listingMap[_tokenAddress][_tokenId] = newListing;

        xEmitEvent.ListingCreatedEvent(
            _tokenAddress,
            _tokenId,
            msg.sender,
            _amount
        );
    }

    function cancelListing(address _tokenAddress, uint256 _tokenId) external {
        // check msg sender is lister
        // remove listing
        // return nft
        Listing memory toBeRemovedListing = listingMap[_tokenAddress][_tokenId];
        require(
            msg.sender == toBeRemovedListing.nftOwner,
            "msg sender is not lister"
        );
        Listing memory toBeUpdatedListing = listings[listings.length - 1];
        toBeUpdatedListing.index = toBeRemovedListing.index;
        listings[toBeRemovedListing.index] = toBeUpdatedListing;
        listingMap[toBeUpdatedListing.tokenAddress][
            toBeUpdatedListing.tokenId
        ] = toBeUpdatedListing;
        listings.pop();
        delete listingMap[_tokenAddress][_tokenId];
        IERC721Upgradeable(_tokenAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        xEmitEvent.ListingDeletedEvent(_tokenAddress, _tokenId);
    }

    function updateListing(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        // check msg sender is lister
        // update listing
        Listing memory toBeUpdatedListing = listingMap[_tokenAddress][_tokenId];
        require(
            msg.sender == toBeUpdatedListing.nftOwner,
            "msg sender is not lister"
        );
        listingMap[_tokenAddress][_tokenId].price = _amount;
        listings[toBeUpdatedListing.index].price = _amount;

        xEmitEvent.ListingUpdatedEvent(
            _tokenAddress,
            _tokenId,
            toBeUpdatedListing.price,
            _amount
        );
    }

    function buyListing(address _tokenAddress, uint256 _tokenId) external {
        // collect GT
        // pay nft owner
        // pay teachers
        // pay treasury
        // transfer nft

        Listing memory toBeRemovedListing = listingMap[_tokenAddress][_tokenId];
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            address(this),
            toBeRemovedListing.price
        );
        Listing memory toBeUpdatedListing = listings[listings.length - 1];
        toBeUpdatedListing.index = toBeRemovedListing.index;
        listings[toBeRemovedListing.index] = toBeUpdatedListing;
        listingMap[toBeUpdatedListing.tokenAddress][
            toBeUpdatedListing.tokenId
        ] = toBeUpdatedListing;
        listings.pop();
        delete listingMap[_tokenAddress][_tokenId];

        uint256 forTreasury = (toBeRemovedListing.price * treasuryCommission) /
            10000;
        uint256 forTeacher = (toBeRemovedListing.price * teacherCommission) /
            10000;
        uint256 forOwner = toBeRemovedListing.price - forTreasury - forTeacher;

        IERC20Upgradeable(gtAddress).safeIncreaseAllowance(
            _tokenAddress,
            forTeacher
        );
        ICourseToken(_tokenAddress).payTeachers(forTeacher);
        IERC20Upgradeable(gtAddress).safeTransfer(treasury, forTreasury);
        IERC20Upgradeable(gtAddress).safeTransfer(
            toBeRemovedListing.nftOwner,
            forOwner
        );
        IERC721Upgradeable(_tokenAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        xEmitEvent.ListingPurchasedEvent(
            _tokenAddress,
            _tokenId,
            msg.sender,
            toBeRemovedListing.price
        );
    }

    function getAllListings() external view returns (Listing[] memory) {
        return listings;
    }

    function getListingsCount() external view returns (uint256) {
        return listings.length;
    }
}
