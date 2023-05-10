// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";
import "./OGSLib.sol";

contract TalentMatch is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public gtAddress;
    uint64 public talentShare;
    uint64 public coachShare;
    uint64 public sponsorShare;
    uint64 public teacherShare;

    mapping(address => OGSLib.MatchData) public matchRegistry;
    mapping(address => bool) public admins;
    ICourseTokenEvent public xEmitEvent;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    function initialize(
        address _tokenAddr,
        uint64 _talentShare,
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare,
        address _emitEventAddr
    ) public initializer {
        require(
            _talentShare + _coachShare + _sponsorShare + _teacherShare == 10000,
            "Shares do not sum to 10000"
        );
        __Ownable_init();
        gtAddress = _tokenAddr;
        talentShare = _talentShare;
        coachShare = _coachShare;
        sponsorShare = _sponsorShare;
        teacherShare = _teacherShare;
        admins[msg.sender] = true;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);        
    }

    function updateShareScheme(
        uint64 _talentShare,
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare
    ) external onlyAdmin {
        require(
            _talentShare + _coachShare + _sponsorShare + _teacherShare == 10000,
            "Shares do not sum to 10000"
        );
        talentShare = _talentShare;
        coachShare = _coachShare;
        sponsorShare = _sponsorShare;
        teacherShare = _teacherShare;
        xEmitEvent.ShareSchemeUpdatedEvent(_talentShare, _coachShare, _sponsorShare, _teacherShare);
    }

    function addTalentMatch(
        address _talent,
        address _coach,
        address _sponsor,
        address _teacher,
        address _nftAddress,
        uint256 _tokenId
    ) external onlyAdmin {
        require(
            matchRegistry[_talent].nftAddress == address(0),
            "match data already exists"
        );
        OGSLib.MatchData memory newMatch;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.teacher = _teacher;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;

        matchRegistry[_talent] = newMatch;
        xEmitEvent.TalentMatchAddedEvent(newMatch, _talent);    
    }

    function updateTalentMatch(
        address _talent,
        address _coach,
        address _sponsor,
        address _teacher,
        address _nftAddress,
        uint256 _tokenId
    ) external onlyAdmin {
        require(
            matchRegistry[_talent].nftAddress != address(0),
            "match data does not exists"
        );
        OGSLib.MatchData memory newMatch;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.teacher = _teacher;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;

        matchRegistry[_talent] = newMatch;
        xEmitEvent.TalentMatchUpdatedEvent(newMatch, _talent);
    }

    function deleteTalentMatch(address _talent) external onlyAdmin {
        OGSLib.MatchData memory _match = matchRegistry[_talent];
        xEmitEvent.TalentMatchDeletedEvent(_match, _talent);
        delete matchRegistry[_talent];
    }

    function confirmTalentMatch(
        address _talent,
        uint256 _amount
    ) external onlyAdmin {
        OGSLib.MatchData memory matchData = matchRegistry[_talent];
        require(matchData.nftAddress != address(0), "match does not exist");
        delete matchRegistry[_talent];

        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            _talent,
            (_amount * talentShare) / 10000
        );
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            matchData.coach,
            (_amount * coachShare) / 10000
        );
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            matchData.sponsor,
            (_amount * sponsorShare) / 10000
        );

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
        xEmitEvent.TalentMatchConfirmedEvent(matchData, _talent, _amount);
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
