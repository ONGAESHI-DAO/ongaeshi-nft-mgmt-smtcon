// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

contract NFTMarketplace is OwnableUpgradeable, IERC721ReceiverUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Listing {
        address tokenAddress;
        uint256 tokenId;
        address nftOwner;
        uint256 price;
        uint256 index;
    }
    mapping(address => mapping(uint256 => Listing)) public listingMap;
    mapping(address => bool) public admins;
    Listing[] public listings;

    address public treasury;
    uint256 public treasuryCommission;
    uint256 public teacherCommission;
    address public gtAddress;

    event Received(address, address, uint256);

    event ListingCreated(
        address indexed courseAddress,
        uint256 indexed tokenId,
        address lister,
        uint256 price
    );
    event ListingUpdated(
        address indexed courseAddress,
        uint256 indexed tokenId,
        uint256 oldPrice,
        uint256 newPrice
    );
    event ListingDeleted(
        address indexed courseAddress,
        uint256 indexed tokenId
    );
    event ListingPurchased(
        address indexed courseAddress,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );

    function initialize(
        address _gtAddress,
        address _treasury,
        uint256 _treasuryCommission,
        uint256 _teacherCommission
    ) external initializer {
        require(_treasury != address(0), "_treasury is zero");
        require(_gtAddress != address(0), "_gtAddress is zero");
        require(
            _treasuryCommission <= 3000,
            "_treasuryCommission cannot exceed 30%"
        );
        require(
            _teacherCommission <= 2000,
            "_teacherCommission cannot exceed 20%"
        );

        __Ownable_init();
        gtAddress = _gtAddress;
        treasury = _treasury;
        treasuryCommission = _treasuryCommission;
        teacherCommission = _teacherCommission;
        admins[msg.sender] = true;
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
            ICourseToken(_tokenAddress).isLended(_tokenId) == bytes20(0),
            "Token is on loan, listing is not permitted"
        );
        require(
            ICourseToken(_tokenAddress).repairCost(_tokenId) == 0,
            "Token needs repair, listing is not permitted"
        );
        require(_amount > 0, "Listing price must not be zero");

        transferCourseToken(_tokenAddress, msg.sender, address(this), _tokenId);

        uint256 listingIndex = listings.length;
        Listing memory newListing;
        newListing.tokenAddress = _tokenAddress;
        newListing.tokenId = _tokenId;
        newListing.nftOwner = msg.sender;
        newListing.price = _amount;
        newListing.index = listingIndex;
        listings.push(newListing);
        listingMap[_tokenAddress][_tokenId] = newListing;

        emit ListingCreated(_tokenAddress, _tokenId, msg.sender, _amount);
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

        transferCourseToken(_tokenAddress, address(this), msg.sender, _tokenId);

        emit ListingDeleted(_tokenAddress, _tokenId);
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

        emit ListingUpdated(
            _tokenAddress,
            _tokenId,
            toBeUpdatedListing.price,
            _amount
        );
    }

    function buyListing(address _tokenAddress, uint256 _tokenId) external {
        // collect GT | pay nft owner | pay teachers | pay treasury | transfer nft

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
        transferCourseToken(_tokenAddress, address(this), msg.sender, _tokenId);


        emit ListingPurchased(
            _tokenAddress,
            _tokenId,
            msg.sender,
            toBeRemovedListing.price
        );
    }

    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    function setTreasury(address _newTreasury) external onlyAdmin {
        require(_newTreasury != address(0), "newTreasury address 0");
        treasury = _newTreasury;
    }

    function setTreasuryCommission(
        uint256 _newTreasuryCommission
    ) external onlyAdmin {
        require(
            _newTreasuryCommission <= 3000,
            "_newTreasuryCommission cannot exceed 30%"
        );
        treasuryCommission = _newTreasuryCommission;
    }

    function setTeacherCommission(
        uint256 _newTeacherCommission
    ) external onlyAdmin {
        require(
            _newTeacherCommission <= 2000,
            "_newTeacherCommission cannot exceed 20%"
        );
        teacherCommission = _newTeacherCommission;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        data;
        emit Received(operator, from, tokenId);
        return 0x150b7a02;
    }

    function getListing(
        address _tokenAddress,
        uint256 _tokenId
    ) external view returns (Listing memory) {
        return listingMap[_tokenAddress][_tokenId];
    }

    function getAllListings() external view returns (Listing[] memory) {
        return listings;
    }

    function getListingsCount() external view returns (uint256) {
        return listings.length;
    }

    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    function transferCourseToken(
        address courseToken,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (ICourseToken(courseToken).transferEnabled()) {
            IERC721Upgradeable(courseToken).safeTransferFrom(from, to, tokenId);
        } else {
            ICourseToken(courseToken).adminTransferFrom(from, to, tokenId);
        }
    }
}
