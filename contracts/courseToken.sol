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

    mapping(uint256 => bytes20) public isLended;
    mapping(uint256 => bool) public needRepairMap;
    mapping(uint256 => uint256) public repairCost;
    mapping(uint256 => string) public tokenCID;
    mapping(address => bool) public admins;

    string public baseURI;
    uint256 public price;
    uint256 public currentSupply;
    uint256 public supplyLimit;
    address public gtAddress;
    address public treasury;
    uint256 public treasuryFee;
    bool public transferEnabled;
    bool public adminRepairOnly;

    OGSLib.TeacherShare[] private teacherShares;
    ICourseTokenEvent public xEmitEvent;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    modifier onlyEnabled() {
        require(transferEnabled, "Transfers have been disabled for this NFT");
        _;
    }

    function initialize(
        string calldata _name,
        string calldata _symbol,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _treasuryFee,
        uint256 _supplyLimit,
        address _treasury,
        address _tokenAddr,
        address _emitEventAddr
    ) external initializer {
        require(_treasury != address(0), "_teacher is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_supplyLimit > 0, "_supplyLimit is zero");
        __Ownable_init();
        __ERC721_init(_name, _symbol);
        baseURI = _tokenBaseURI;
        price = _price;
        supplyLimit = _supplyLimit;
        treasury = _treasury;
        treasuryFee = _treasuryFee;
        gtAddress = _tokenAddr;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
        admins[msg.sender] = true;
        transferEnabled = false;
        adminRepairOnly = false;
    }

    function addTeacherShares(
        OGSLib.TeacherShare[] calldata _teacherShares
    ) external onlyAdmin {
        require(
            currentSupply == 0,
            "Cannot update Teachershares after NFT minted"
        );
        uint256 sum;
        for (uint256 i = 0; i < _teacherShares.length; i++) {
            teacherShares.push(_teacherShares[i]);
            sum += _teacherShares[i].shares;
        }
        require(sum == 10000, "Shares sum does not equal 10000");
        xEmitEvent.TeacherAddedEvent(address(this), _teacherShares);
    }

    function mint(uint256 _amount) external {
        require(teacherShares.length > 0, "teacherShares not initialized");
        require(price > 0, "This nft cannot be minted by public");
        require(gtAddress != address(0), "GT not available");
        uint256 currSupply = currentSupply;
        require(
            currSupply + _amount <= supplyLimit,
            "Mint request exceeds supply limit"
        );
        uint256 fullAmountPrice = _amount * price;
        uint256 treasuryCut = (fullAmountPrice * treasuryFee) / 10000;
        payTeachers(fullAmountPrice - treasuryCut);
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            treasury,
            treasuryCut
        );
        for (uint256 i = 1; i <= _amount; i++) {
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
        require(teacherShares.length > 0, "teacherShares not initialized");
        uint256 currSupply = currentSupply;
        require(
            currSupply + _amount <= supplyLimit,
            "Mint request exceeds supply limit"
        );
        for (uint256 i = 1; i <= _amount; i++) {
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

    function setTreasuryFee(uint256 _treasuryFee) external onlyAdmin {
        require(_treasuryFee <= 10000, "treasury fee cannot exceed 100%");
        xEmitEvent.FeeUpdatedEvent(address(this), treasuryFee, _treasuryFee);
        treasuryFee = _treasuryFee;
    }

    function setTreasury(address _treasury) external onlyAdmin {
        require(_treasury != address(0), "_treasury is 0");
        xEmitEvent.TreasuryUpdatedEvent(address(this), treasury, _treasury);
        treasury = _treasury;
    }

    function increaseSupplyLimit(uint256 _increaseBy) external onlyAdmin {
        uint256 newSupply = supplyLimit + _increaseBy;
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
        uint256 newSupply = supplyLimit - _decreaseBy;
        xEmitEvent.SupplyLimitUpdatedEvent(
            address(this),
            supplyLimit,
            newSupply
        );

        supplyLimit = newSupply;
    }

    function lendToken(uint256 _tokenId, bytes20 _Id) external onlyAdmin {
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId] == 0, "Token already lended");
        require(repairCost[_tokenId] == 0, "Token needs repair");
        isLended[_tokenId] = _Id;
        xEmitEvent.TokenLendedEvent(address(this), _tokenId, _Id);
    }

    function returnToken(
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel
    ) external onlyAdmin {
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId] != 0, "Token not on loan");
        delete isLended[_tokenId];
        breakToken(_tokenId, _repairCost, _isCancel);
    }

    function breakToken(
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel
    ) internal {
        require(_exists(_tokenId), "Token does not exists");
        require(!needRepairMap[_tokenId], "Token already needs repair");
        needRepairMap[_tokenId] = true;
        repairCost[_tokenId] = _repairCost;
        xEmitEvent.NeedRepairEvent(
            address(this),
            _tokenId,
            _repairCost,
            _isCancel
        );
    }

    function repairToken(uint256 _tokenId) external {
        bool needRepair = needRepairMap[_tokenId];
        uint256 nftRepairCost = repairCost[_tokenId];
        require(_exists(_tokenId), "Token does not exists");
        require(needRepair, "Token does not need repair");
        require(!adminRepairOnly, "Can only be repaired by admin");
        require(gtAddress != address(0), "GT not available");
        delete repairCost[_tokenId];

        uint256 treasuryCut = (nftRepairCost * treasuryFee) / 10000;
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            treasury,
            treasuryCut
        );
        payTeachers(nftRepairCost - treasuryCut);
        xEmitEvent.RepairedEvent(address(this), _tokenId);
    }

    function repairTokenByAdmin(uint256 _tokenId) external onlyAdmin {
        bool needRepair = needRepairMap[_tokenId];
        require(_exists(_tokenId), "Token does not exists");
        require(needRepair, "Token does not need repair");
        delete repairCost[_tokenId];
        delete needRepairMap[_tokenId];
        xEmitEvent.RepairedEvent(address(this), _tokenId);
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
        for (uint256 i = 0; i < _tokenId.length; i++) {
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

    function setAdminRepairOnly(bool _allow) external onlyAdmin {
        adminRepairOnly = _allow;
    }

    function setTransferEnabled(bool _allow) external onlyAdmin {
        transferEnabled = _allow;
    }

    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    function payTeachers(uint256 amount) public {
        require(teacherShares.length > 0, "Teachers not initialized");
        require(gtAddress != address(0), "GT not available");
        for (uint256 i = 0; i < teacherShares.length; i++) {
            uint256 paymentAmount = (amount * teacherShares[i].shares) / 10000;
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

    function adminTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyAdmin {
        require(!transferEnabled, "Transfers Enabled, use owner or approved functions");
        _transfer(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyEnabled {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyEnabled {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override onlyEnabled {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }
}
