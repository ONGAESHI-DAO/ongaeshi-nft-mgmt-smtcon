// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Interface/ICourseToken.sol";

contract TalentMatch is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct MatchData {
        address coach;
        address sponsor;
        address teacher;
        address nftAddress;
        uint256 tokenId;
    }
    address gtAddress;
    uint64 talentShare;
    uint64 coachShare;
    uint64 sponsorShare;
    uint64 teacherShare;

    mapping(address => MatchData) public matchRegistry;
    mapping(address => bool) public admins;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    function initialize(
        address _tokenAddr,
        uint64 _talentShare,
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare
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
        MatchData memory newMatch;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.teacher = _teacher;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;

        matchRegistry[_talent] = newMatch;
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
        MatchData memory newMatch;
        newMatch.coach = _coach;
        newMatch.sponsor = _sponsor;
        newMatch.teacher = _teacher;
        newMatch.nftAddress = _nftAddress;
        newMatch.tokenId = _tokenId;

        matchRegistry[_talent] = newMatch;
    }

    function deleteTalentMatch(address _talent) external onlyAdmin {
        delete matchRegistry[_talent];
    }

    function confirmTalentMatch(
        address _talent,
        uint256 _amount
    ) external onlyAdmin {
        MatchData memory matchData = matchRegistry[_talent];
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
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
