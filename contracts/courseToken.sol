// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

contract CourseToken is ERC721Upgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using StringsUpgradeable for uint256;

    mapping(uint256 => bool) public isLended;
    mapping(uint256 => uint256) public repairCost;
    mapping(uint256 => string) public tokenCID;
    mapping(address => bool) public admins;

    string public baseURI;
    uint256 public price;
    uint256 public currentSupply;
    uint256 public supplyLimit;
    address public gtAddress;
    address public teacher;
    OGSLib.TeacherShare[] private teacherShares;
    ICourseTokenEvent public xEmitEvent;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _supplyLimit,
        address _teacher,
        address _tokenAddr,
        address _emitEventAddr
    ) external initializer {
        require(_teacher != address(0), "_teacher is zero");
        require(_tokenAddr != address(0), "_tokenAddr is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_supplyLimit > 0, "_supplyLimit is zero");
        __Ownable_init();
        __ERC721_init(_name, _symbol);
        baseURI = _tokenBaseURI;
        price = _price;
        supplyLimit = _supplyLimit;
        teacher = _teacher;
        gtAddress = _tokenAddr;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
        admins[msg.sender] = true;
    }

    function addTeacherShares(
        OGSLib.TeacherShare[] calldata _teacherShares
    ) external onlyOwner {
        require(
            teacherShares.length == 0,
            "Already initialized Teacher Shares"
        );
        uint256 sum;
        for (uint i = 0; i < _teacherShares.length; i++) {
            teacherShares.push(_teacherShares[i]);
            sum += _teacherShares[i].shares;
        }
        require(sum == 10000, "Shares sum does not equal 10000");
        xEmitEvent.TeacherAddedEvent(address(this), _teacherShares);
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
            xEmitEvent.TokenMintEvent(
                address(this),
                msg.sender,
                currSupply + i,
                price
            );
        }
        currentSupply += _amount;
    }

    function mintByAdmin(
        uint256 _amount,
        address _recipient
    ) external onlyAdmin {
        uint currSupply = currentSupply;
        require(
            currSupply + _amount <= supplyLimit,
            "Mint request exceeds supply limit"
        );
        for (uint256 i = 0; i < _amount; i++) {
            _mint(_recipient, currSupply + i);
            xEmitEvent.TokenMintEvent(
                address(this),
                _recipient,
                currSupply + i,
                price
            );
        }
        currentSupply += _amount;
    }

    function setPrice(uint256 _newPrice) external onlyAdmin {
        xEmitEvent.PriceUpdatedEvent(address(this), price, _newPrice);
        price = _newPrice;
    }

    function increaseSupplyLimit(uint256 _increaseBy) external onlyAdmin {
        uint newSupply = supplyLimit + _increaseBy;
        xEmitEvent.SupplyLimitUpdatedEvent(
            address(this),
            supplyLimit,
            newSupply
        );
        supplyLimit = newSupply;
    }

    function decreaseSupplyLimit(uint256 _decreaseBy) external onlyAdmin {
        require(supplyLimit >= _decreaseBy, "Input greater than supplyLimit");
        require(
            supplyLimit - _decreaseBy >= currentSupply,
            "Request would decrease supply limit lower than current Supply"
        );
        uint newSupply = supplyLimit - _decreaseBy;
        xEmitEvent.SupplyLimitUpdatedEvent(
            address(this),
            supplyLimit,
            newSupply
        );

        supplyLimit = newSupply;
    }

    function lendToken(uint256 _tokenId) external onlyAdmin {
        require(_exists(_tokenId), "Token does not exists");
        require(!isLended[_tokenId], "Token already lended");
        require(repairCost[_tokenId] == 0, "Token needs repair");
        isLended[_tokenId] = true;
    }

    function returnToken(
        uint256 _tokenId,
        uint256 _repairCost
    ) external onlyAdmin {
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId], "Token not on loan");
        isLended[_tokenId] = false;
        breakToken(_tokenId, _repairCost);
    }

    function breakToken(uint256 _tokenId, uint256 _repairCost) internal {
        require(_exists(_tokenId), "Token does not exists");
        require(repairCost[_tokenId] == 0, "Token already needs repair");
        if (_repairCost > 0) {
            repairCost[_tokenId] = _repairCost;
        }
    }

    function repairToken(uint256 _tokenId) external {
        uint256 nftRepairCost = repairCost[_tokenId];
        require(_exists(_tokenId), "Token does not exists");
        require(nftRepairCost > 0, "Token does not need repair");
        delete repairCost[_tokenId];
        payTeachers(nftRepairCost);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata _newBaseURI) external onlyAdmin {
        baseURI = _newBaseURI;
    }

    function setTokenURI(
        uint256 _tokenId,
        string calldata _cid
    ) external onlyAdmin {
        tokenCID[_tokenId] = _cid;
    }

    function setTokenURIs(
        uint256[] calldata _tokenId,
        string[] calldata _cid
    ) external onlyAdmin {
        require(_tokenId.length == _cid.length, "Input lengths mismatch");
        for (uint i = 0; i < _tokenId.length; i++) {
            tokenCID[_tokenId[i]] = _cid[i];
        }
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
        require(teacherShares.length > 0, "Teachers not initialized");
        for (uint i = 0; i < teacherShares.length; i++) {
            uint paymentAmount = (amount * teacherShares[i].shares) / 10000;
            IERC20Upgradeable(gtAddress).safeTransferFrom(
                msg.sender,
                teacherShares[i].teacher,
                paymentAmount
            );
        }
        xEmitEvent.TeacherPaidEvent(address(this), teacherShares, amount);
    }

    function getSubTeachers()
        public
        view
        returns (OGSLib.TeacherShare[] memory)
    {
        return teacherShares;
    }

    function setEmitEvent(address _emitEventAddr) external onlyOwner {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
