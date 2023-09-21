// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

/// @title ONGAESHI Talent Matching Smart Contract
/// @author xWin Finance
/// @notice This contract can perform tasks of create, update, delete, payout, and confirm for the talent matching system.
contract TalentMatch is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public gtAddress;
    address public treasuryAddress;
    uint64 public coachShare;
    uint64 public sponsorShare;
    uint64 public teacherShare;

    mapping(bytes20 => OGSLib.MatchData) public matchRegistry;
    mapping(address => bool) public admins;
    ICourseTokenEvent public xEmitEvent;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializer function for contract deployment.
    /// @param _tokenAddr ONGAESHI Token Address.
    /// @param _coachShare Percentage share for the coach.
    /// @param _sponsorShare Percentage share for the sponsor.
    /// @param _teacherShare Percentage share for the teachers.
    /// @param _emitEventAddr Event emitter contract address.
    /// @param _treasuryAddress Treasury address to receive token payments.
    function initialize(
        address _tokenAddr,
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare,
        address _emitEventAddr,
        address _treasuryAddress
    ) public initializer {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_treasuryAddress != address(0), "_treasuryAddress is zero");
        require(
            _coachShare + _sponsorShare + _teacherShare == 10000,
            "Shares do not sum to 10000"
        );
        __Ownable_init();
        gtAddress = _tokenAddr;
        treasuryAddress = _treasuryAddress;
        coachShare = _coachShare;
        sponsorShare = _sponsorShare;
        teacherShare = _teacherShare;
        admins[msg.sender] = true;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    /// @notice Updates the share scheme, caller must be admin wallet.
    /// @param _coachShare New coach share percentage.
    /// @param _sponsorShare New sponsor share percentage.
    /// @param _teacherShare New teachers share percentage.
    /** @dev Percentage values have 2 decimal padding, e.g. 2100 = 21%, 300 = 3%.
     * Share total must be 10000, which represents 100%.
     */
    function updateShareScheme(
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare
    ) external onlyAdmin {
        require(
            _coachShare + _sponsorShare + _teacherShare == 10000,
            "Shares do not sum to 10000"
        );
        coachShare = _coachShare;
        sponsorShare = _sponsorShare;
        teacherShare = _teacherShare;
        xEmitEvent.ShareSchemeUpdatedEvent(
            _coachShare,
            _sponsorShare,
            _teacherShare
        );
    }

    /// @notice Adds a new talent match record into the smart contract, caller must be admin wallet.
    /// @param _Id Talent UUID, used as key for smart contract hashmap storage.
    /// @param _talent Talent wallet address, may be empty if talent wallet is unavailable.
    /// @param _coach Coach wallet address to receive coach share reward, may be empty if talent did not have a coach.
    /// @param _sponsor Sponsor wallet to receive sponsor share reward.
    /// @param _nftAddress Address of ONGAESHI Education NFT loaned and returned to talent.
    /// @param _tokenId NFT ID.
    /// @param _amount Talent matching payment reward amount.
    /// @param _matchDate Date of talent matching.
    /// @param _payDate Expected payment date of talent matching.
    function addTalentMatch(
        bytes20 _Id,
        address _talent,
        address _coach,
        address _sponsor,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _matchDate,
        uint256 _payDate
    ) external onlyAdmin {
        require(
            matchRegistry[_Id].nftAddress == address(0),
            "match data already exists"
        );
        OGSLib.MatchData memory newMatch;
        newMatch.talent = _talent;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;
        newMatch.amount = _amount;
        newMatch.matchDate = _matchDate;
        newMatch.payDate = _payDate;

        matchRegistry[_Id] = newMatch;
        xEmitEvent.TalentMatchAddedEvent(newMatch, _Id, _amount);
    }

    /// @notice Updates existing talent match record, caller must be admin wallet.
    /// @param _Id Talent UUID.
    /// @param _talent Talent wallet address, may be empty if talent wallet is unavailable.
    /// @param _coach Coach wallet address to receive coach share reward, may be empty if talent did not have a coach.
    /// @param _sponsor Sponsor wallet to receive sponsor share reward.
    /// @param _nftAddress Address of ONGAESHI Education NFT loaned and returned to talent.
    /// @param _tokenId NFT ID.
    /// @param _amount Talent matching payment reward amount.
    /// @param _matchDate Date of talent matching.
    /// @param _payDate Expected payment date of talent matching.
    function updateTalentMatch(
        bytes20 _Id,
        address _talent,
        address _coach,
        address _sponsor,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _matchDate,
        uint256 _payDate
    ) external onlyAdmin {
        require(
            matchRegistry[_Id].nftAddress != address(0),
            "match data does not exists"
        );
        OGSLib.MatchData memory newMatch;
        newMatch.talent = _talent;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;
        newMatch.amount = _amount;
        newMatch.matchDate = _matchDate;
        newMatch.payDate = _payDate;

        matchRegistry[_Id] = newMatch;
        xEmitEvent.TalentMatchUpdatedEvent(newMatch, _Id, _amount);
    }

    /// @notice Deletes existing talent match record, caller must be admin wallet.
    /// @param _Id Talent UUID
    function deleteTalentMatch(bytes20 _Id) external onlyAdmin {
        OGSLib.MatchData memory _match = matchRegistry[_Id];
        require(_match.nftAddress != address(0), "match data does not exists");
        xEmitEvent.TalentMatchDeletedEvent(_match, _Id);
        delete matchRegistry[_Id];
    }

    /// @notice Confirm talent matching, and payout ONGAESHI tokens to relevant stakeholders, caller must be admin wallet.
    /// @param _Id Talent UUID
    /// @param _amount Amount of ONGAESHI tokens that is awarded for the talent matching.
    /** @dev Caller needs to have sufficient ONGAESHI tokens and has given spending approval to this contract.
     * Teacher's reward will be distributed based on the teacher share scheme of the original ONGAESHI Education NFT in the talent matching.
     * Supported edge case:
     * 1) If talent is their own sponsor, talent shares are given to the treasury instead.
     * 2) If talent completed their education without a coach, coach address will be empty, and coach shares are given to the treasury.
     */
    function confirmTalentMatch(
        bytes20 _Id,
        uint256 _amount
    ) external onlyAdmin {
        OGSLib.MatchData memory matchData = matchRegistry[_Id];
        require(matchData.nftAddress != address(0), "match does not exist");
        require(matchData.amount == _amount, "amount does not match");
        require(gtAddress != address(0), "GT not available");
        delete matchRegistry[_Id];

        uint64 actualTreasuryShare = 0;

        uint256 sponsorTotal = 0;
        if (matchData.sponsor != matchData.talent) {
            sponsorTotal = (_amount * sponsorShare) / 10000;
            IERC20Upgradeable(gtAddress).safeTransferFrom(
                msg.sender,
                matchData.sponsor,
                sponsorTotal
            );
        } else {
            actualTreasuryShare += sponsorShare;
        }

        uint256 coachTotal = 0;
        if (matchData.coach != address(0)) {
            coachTotal = (_amount * coachShare) / 10000;
            IERC20Upgradeable(gtAddress).safeTransferFrom(
                msg.sender,
                matchData.coach,
                coachTotal
            );
        } else {
            actualTreasuryShare += coachShare;
        }

        uint256 actualTreasuryTotal = 0;
        if (actualTreasuryShare > 0) {
            actualTreasuryTotal = (_amount * actualTreasuryShare) / 10000;
            IERC20Upgradeable(gtAddress).safeTransferFrom(
                msg.sender,
                treasuryAddress,
                actualTreasuryTotal
            );
        }

        uint256 teacherAmount = (_amount * teacherShare) / 10000;

        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            address(this),
            teacherAmount
        );
        IERC20Upgradeable(gtAddress).safeIncreaseAllowance(
            matchData.nftAddress,
            teacherAmount
        );
        ICourseToken(matchData.nftAddress).payTeachers(teacherAmount);
        xEmitEvent.TalentMatchConfirmedEvent(
            matchData,
            _Id,
            coachTotal,
            sponsorTotal,
            actualTreasuryTotal,
            teacherAmount
        );
    }

    /// @notice Updates the ONGAESHI token address of this smart contract. Caller must be admin.
    /// @param _gtAddress New ONGAESHI token address.
    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    /// @notice Updates recipient address of treasury fees. Caller must be admin.
    /// @param _treasuryAddress New address of treasury.
    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        require(_treasuryAddress != address(0), "_treasuryAddress is zero");
        treasuryAddress = _treasuryAddress;
    }

    /// @notice Updates the contract address for event emitter. Caller must be admin.
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
}
