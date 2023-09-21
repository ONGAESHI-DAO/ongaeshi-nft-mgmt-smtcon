// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

/// @title ONGAESHI Education NFT Smart Contract
/// @author xWin Finance
/// @notice This NFT supports payment minting, supply limits, loans, and repairs.
/** @dev Token transfers can be disabled using the transferEnabled flag, where only admins may move NFTs.
 * When transfers are enabled, admins cannot move NFTs.
 * When the adminRepairOnly flag is true, only admins can repair NFTs.
 */
contract CourseToken is ERC721Upgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using StringsUpgradeable for uint256;

    mapping(uint256 => bytes20) public isLended; // tokenId => talendId : Ongoing nft loan recipient
    mapping(uint256 => bool) public needRepairMap; // tokenId => bool : Repair requirement status of token
    mapping(uint256 => uint256) public repairCost; // tokenId => repair cost : Repair cost of token
    mapping(uint256 => string) public tokenCID; // tokenId => cid : CID of token
    mapping(address => bool) public admins; // admin mapping

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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
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
        require(_treasury != address(0), "_treasury is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_supplyLimit > 0, "_supplyLimit is zero");
        require(_price > 0, "_price is zero");
        require(_treasuryFee <= 10000, "_tresuryFee cannot exceed 100%");
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

    /// @notice Initialise NFT contract with teacher fee distribution.
    /// @param _teacherShares Array of TeacherShare objects.
    /** @dev Caller must be admin wallet.
     * This function can only be called before the first NFT mint.
     * After the first mint, teacher fee distribution is immutable.
     * Shares in the input array must sum to 100% i.e 10000.
     * Teacher Shares must be initialised for before minting to function.
     */
    function addTeacherShares(
        OGSLib.TeacherShare[] calldata _teacherShares
    ) external onlyAdmin {
        require(
            currentSupply == 0,
            "Cannot update Teachershares after NFT minted"
        );
        require(_teacherShares.length <= 50, "Input exceeded max limit of 50 teachers");
        uint256 sum;
        delete teacherShares;
        for (uint256 i = 0; i < _teacherShares.length; i++) {
            require(
                _teacherShares[i].teacher != address(0),
                "Input teacher address zero"
            );
            teacherShares.push(_teacherShares[i]);
            sum += _teacherShares[i].shares;
        }
        require(sum == 10000, "Shares sum does not equal 10000");
        xEmitEvent.TeacherAddedEvent(address(this), _teacherShares);
    }

    /// @notice Public minting of ONGAESHI Education NFT, where payment of ONGAESHI Tokens will be made to mint NFT.
    /// @param _amount Number of NFTs to mint, request may not exceed supply limit.
    /// @dev Portion of payment will be taken as tresury fee, paid to the treasury address, remainder is distributed among teachers.
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

    /// @notice Admin minting of ONGAESHI Education NFT, Caller must be admin wallet.
    /// @param _amount Number of NFTs to mint, request may not exceed supply limit.
    /// @param _recipient Recipient of newly minted NFTs.
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

    /// @notice Update minting price of NFT, caller must be admin wallet.
    /// @param _newPrice New minting price of NFT.
    function setPrice(uint256 _newPrice) external onlyAdmin {
        require(_newPrice > 0, "_newPrice is zero");
        xEmitEvent.PriceUpdatedEvent(address(this), price, _newPrice);
        price = _newPrice;
    }

    /// @notice Updates treasury fee, caller must be admin wallet.
    /// @param _treasuryFee New treasury fee, e.g. 500 = 5%, 1000 = 10%.
    function setTreasuryFee(uint256 _treasuryFee) external onlyAdmin {
        require(_treasuryFee <= 10000, "treasury fee cannot exceed 100%");
        xEmitEvent.FeeUpdatedEvent(address(this), treasuryFee, _treasuryFee);
        treasuryFee = _treasuryFee;
    }

    /// @notice Updates recipient address of treasury fees. Caller must be admin.
    /// @param _treasury New address of treasury.
    function setTreasury(address _treasury) external onlyAdmin {
        require(_treasury != address(0), "_treasury is 0");
        xEmitEvent.TreasuryUpdatedEvent(address(this), treasury, _treasury);
        treasury = _treasury;
    }

    /// @notice Increase the NFT supply limit by input number. Caller must be admin.
    /// @param _increaseBy number to increase supply limit by, e.g supplyLimit 100, increaseBy 5, new supplyLimit = 105.
    function increaseSupplyLimit(uint256 _increaseBy) external onlyAdmin {
        require(_increaseBy > 0, "_increaseBy is zero");
        uint256 newSupply = supplyLimit + _increaseBy;
        xEmitEvent.SupplyLimitUpdatedEvent(
            address(this),
            supplyLimit,
            newSupply
        );
        supplyLimit = newSupply;
    }

    /// @notice Decrease the NFT supply limit by input number. Caller must be admin.
    /// @param _decreaseBy number to decrease supply limit by, e.g supplyLimit 100, increaseBy 5, new supplyLimit = 95.
    function decreaseSupplyLimit(uint256 _decreaseBy) external onlyAdmin {
        require(_decreaseBy > 0, "_decreaseBy is zero");
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

    /// @notice Record loan status, caller must be Admin.
    /// @param _tokenId Token to loan out.
    /// @param _Id Talent UUID to that is borring the token.
    function lendToken(uint256 _tokenId, bytes20 _Id) external onlyAdmin {
        require(_Id != 0, "_Id is zero");
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId] == 0, "Token already lended");
        require(repairCost[_tokenId] == 0, "Token needs repair");
        isLended[_tokenId] = _Id;
        xEmitEvent.TokenLendedEvent(address(this), _tokenId, _Id);
    }

    /// @notice Record or Cancel NFT loan, token requires repair after, caller must be Admin.
    /// @param _tokenId  Loaned token to return.
    /// @param _repairCost Cost to repair token.
    /// @param _isCancel Flag, true indicates this is a cancel, false indicates its a return.
    function returnToken(
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel
    ) external onlyAdmin {
        require(_exists(_tokenId), "Token does not exists");
        require(isLended[_tokenId] != 0, "Token not on loan");
        bytes20 _Id = isLended[_tokenId];
        delete isLended[_tokenId];
        breakToken(_tokenId, _repairCost, _isCancel, _Id);
    }

    function breakToken(
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel,
        bytes20 _Id
    ) internal {
        require(_exists(_tokenId), "Token does not exists");
        require(!needRepairMap[_tokenId], "Token already needs repair");
        needRepairMap[_tokenId] = true;
        repairCost[_tokenId] = _repairCost;
        xEmitEvent.NeedRepairEvent(
            address(this),
            _tokenId,
            _repairCost,
            _isCancel,
            _Id
        );
    }

    /// @notice Public repair NFT, where payment of ONGAESHI Tokens will be made to mint NFT.
    /// @param _tokenId Token to be repaired.
    /** @dev Portion of payment will be taken as tresury fee, paid to the treasury address, remainder is distributed among teachers.
     * adminRepairOnly Flag can disable this function.
     */
    function repairToken(uint256 _tokenId) external {
        bool needRepair = needRepairMap[_tokenId];
        uint256 nftRepairCost = repairCost[_tokenId];
        require(_exists(_tokenId), "Token does not exists");
        require(needRepair, "Token does not need repair");
        require(!adminRepairOnly, "Can only be repaired by admin");
        require(gtAddress != address(0), "GT not available");
        delete repairCost[_tokenId];
        delete needRepairMap[_tokenId];

        uint256 treasuryCut = (nftRepairCost * treasuryFee) / 10000;
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            treasury,
            treasuryCut
        );
        payTeachers(nftRepairCost - treasuryCut);
        xEmitEvent.RepairedEvent(address(this), _tokenId);
    }

    /// @notice Repair NFT, caller must be admin wallet. Caller must be admin.
    /// @param _tokenId Token to be repaired.
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

    /// @notice Updates the Base URI for the entire NFT collection.
    /// @param _newBaseURI New base URI.
    function setBaseURI(string calldata _newBaseURI) external onlyAdmin {
        baseURI = _newBaseURI;
    }

    /// @notice Updates the cid for the input token. Caller must be admin.
    /// @param _tokenId Token to update cid.
    /// @param _cid New cid for token.
    function setTokenURI(
        uint256 _tokenId,
        string calldata _cid
    ) external onlyAdmin {
        tokenCID[_tokenId] = _cid;
    }

    /// @notice Batch update cid for input tokens. Caller must be admin.
    /// @param _tokenId Array of tokens to update cid.
    /// @param _cid Array of new cids for token.
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

    /// @notice Updates adminRepairOnly flag, caller must be admin wallet.
    /// @param _allow new status of adminRepairOnly flag.
    function setAdminRepairOnly(bool _allow) external onlyAdmin {
        adminRepairOnly = _allow;
    }

    /// @notice Updates transferEnabled flag, caller must be admin wallet. Caller must be admin.
    /// @param _allow new status of transferEnabled flag.
    function setTransferEnabled(bool _allow) external onlyAdmin {
        transferEnabled = _allow;
    }

    /// @notice Updates the ONGAESHI token address of this smart contract. Caller must be admin.
    /// @param _gtAddress New ONGAESHI token address.
    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    /// Function to distribute ONGAESHI tokens according to established teacher shares of this smart contract.
    /// @param amount Amount of ONGAESHI tokens to distribute.
    /// @dev Caller must have sufficient ONGAESHI token balance, and approve this contract for spending input amount.
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

    /// @notice Gets the teacher shares data.
    function getSubTeachers()
        public
        view
        returns (OGSLib.TeacherShare[] memory)
    {
        return teacherShares;
    }

    /// @notice Updates the contract address for event emitter.
    /// @param _emitEventAddr New event emitter contract address.
    /// @dev Ensure that this contract has access to emit events on the new event emitter.
    function setEmitEvent(address _emitEventAddr) external onlyAdmin {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    /// @notice Set admin status to any wallet, caller must be contract owner.
    /// @param _address Address to set admin status.
    /// @param _allow Admin status, true to give admin access, false to revoke.
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }

    /// @notice Admin privilliged TransferFrom function. Caller must be admin.
    /// @param from Address of NFT owner.
    /// @param to  Address of NFT recipient.
    /// @param tokenId Token Id of NFT to be transferred.
    function adminTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public onlyAdmin {
        require(
            !transferEnabled,
            "Transfers Enabled, use owner or approved functions"
        );
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
