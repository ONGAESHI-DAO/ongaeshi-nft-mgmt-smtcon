// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract CourseToken is ERC721Upgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using StringsUpgradeable for uint256;

    mapping(uint256 => bool) public isLended;
    mapping(uint256 => bool) public needRepair;
    mapping(uint256 => string) public tokenCID;

    string public collectionMetadataURI;
    string public baseURI;
    uint256 public price;
    uint256 public currentSupply;
    uint256 public supplyLimit;
    address private gtAddress;
    address private teacher;
    address[] public teachers;
    uint64[] public teacherShares;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _collectionMetadataURI,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _supplyLimit,
        address _teacher,
        address _tokenAddr
    ) external initializer {
        __Ownable_init();
        __ERC721_init(_name, _symbol);
        collectionMetadataURI = _collectionMetadataURI;
        baseURI = _tokenBaseURI;
        price = _price;
        supplyLimit = _supplyLimit;
        teacher = _teacher;
        gtAddress = _tokenAddr;
    }

    function addTeacherShares(
        address[] calldata _teachers,
        uint64[] calldata _shares
    ) external onlyOwner {
        require(teachers.length == 0, "Teacher shares already initialized");
        require(_teachers.length == _shares.length, "Input lengths mismatch");
        uint64 sum;
        for (uint i = 0; i < _teachers.length; i++) {
            teachers.push(_teachers[i]);
            teacherShares.push(_shares[i]);
            sum += _shares[i];
        }
        require(sum == 10000, "Shares sum does not equal 10000");
    }

    function mint(uint256 _amount) external {
        uint currSupply = currentSupply;
        require(
            currSupply + _amount <= supplyLimit,
            "Mint request exceeds supply limit"
        );
        payTeachers(_amount * price);
        for (uint256 i = 0; i < _amount; i++) {
            _mint(msg.sender, currSupply + i);
        }
        currentSupply += _amount;
    }

    function mintByAdmin(
        uint256 _amount,
        address _recipient
    ) external onlyOwner {
        uint currSupply = currentSupply;
        for (uint256 i = 0; i < _amount; i++) {
            _mint(_recipient, currSupply + i);
        }
        currentSupply += _amount;
    }

    function setCollectionMetadata(
        string calldata _newMetadataURI
    ) external onlyOwner {
        collectionMetadataURI = _newMetadataURI;
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function increaseSupplyLimit(uint256 _increaseBy) external onlyOwner {
        supplyLimit += _increaseBy;
    }

    function decreaseSupplyLimit(uint256 _decreaseBy) external onlyOwner {
        require(supplyLimit >= _decreaseBy, "Input greater than supply");
        require(
            supplyLimit - _decreaseBy >= currentSupply,
            "Request would decrease supply limit lower than current Supply"
        );
        supplyLimit -= _decreaseBy;
    }

    function lendToken(uint256 _tokenId) external onlyOwner {
        require(_exists(_tokenId), "Token does not exists");
        require(!isLended[_tokenId], "Token already lended");
        isLended[_tokenId] = true;
    }

    function returnToken(uint256 _tokenId) external onlyOwner {
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId], "Token not on loan");
        isLended[_tokenId] = false;
    }

    function breakToken(uint256 _tokenId) external onlyOwner {
        require(_exists(_tokenId), "Token does not exists");
        require(!needRepair[_tokenId], "Token already needs repair");
        needRepair[_tokenId] = true;
    }

    function repairToken(uint256 _tokenId) external onlyOwner {
        require(_exists(_tokenId), "Token does not exists");
        require(needRepair[_tokenId], "Token does not need repair");
        needRepair[_tokenId] = false;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setTokenURI(
        uint256 _tokenId,
        string memory _cid
    ) external onlyOwner {
        tokenCID[_tokenId] = _cid;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireMinted(tokenId);
        string memory tokenCidString = tokenCID[tokenId];

        if (bytes(baseURI).length > 0) {
            return
                bytes(tokenCidString).length > 0
                    ? string(abi.encodePacked(baseURI, tokenCidString))
                    : string(abi.encodePacked(baseURI, tokenId.toString()));
        } else {
            return "";
        }
    }

    function payTeachers(uint256 amount) public {
        require(teachers.length > 0, "Teachers not initialized");
        for (uint i = 0; i < teachers.length; i++) {
            uint paymentAmount = (amount * teacherShares[i]) / 10000;
            IERC20Upgradeable(gtAddress).safeTransferFrom(
                msg.sender,
                teachers[i],
                paymentAmount
            );
        }
    }
}
