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

    function initialize(
        address _tokenAddr,
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare,
        address _emitEventAddr,
        address _treasuryAddress
    ) public initializer {
        // require(_tokenAddr != address(0), "_tokenAddr is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_treasuryAddress != address(0), "_treasuryAddress is zero");
        require(
            _coachShare + _sponsorShare + _teacherShare ==
                10000,
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

    function updateShareScheme(
        uint64 _coachShare,
        uint64 _sponsorShare,
        uint64 _teacherShare
    ) external onlyAdmin {
        require(
            _coachShare + _sponsorShare + _teacherShare ==
                10000,
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

    function deleteTalentMatch(bytes20 _Id) external onlyAdmin {
        OGSLib.MatchData memory _match = matchRegistry[_Id];
        require(_match.nftAddress != address(0), "match data does not exists");
        xEmitEvent.TalentMatchDeletedEvent(_match, _Id);
        delete matchRegistry[_Id];
    }

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
        xEmitEvent.TalentMatchConfirmedEvent(matchData, _Id, coachTotal, sponsorTotal, actualTreasuryTotal, teacherAmount);
    }

    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyAdmin {
        require(_treasuryAddress != address(0), "_treasuryAddress is zero");
        treasuryAddress = _treasuryAddress;
    }

    function setEmitEvent(address _emitEventAddr) external onlyAdmin {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
