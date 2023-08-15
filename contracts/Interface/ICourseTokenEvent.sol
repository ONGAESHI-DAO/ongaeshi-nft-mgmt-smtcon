// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../OGSLib.sol";

interface ICourseTokenEvent {
    function TokenMintEvent(
        address _courseAddress,
        address _destiny,
        uint256 _tokenId,
        uint256 _price
    ) external;

    function PriceUpdatedEvent(
        address _courseAddress,
        uint256 _oldPrice,
        uint256 _newPrice
    ) external;

    function FeeUpdatedEvent(
        address _courseAddress,
        uint256 _oldFee,
        uint256 _newFee
    ) external;

    function TreasuryUpdatedEvent(
        address _courseAddress,
        address _oldTreasury,
        address _newTreasury
    ) external;

    function SupplyLimitUpdatedEvent(
        address _courseAddress,
        uint256 _oldSupplyLimit,
        uint256 _newSupplyLimit
    ) external;

    function CourseDeployedEvent(
        address _courseAddress,
        address _sender
    ) external;

    function TeacherPaidEvent(
        address _courseAddress,
        OGSLib.TeacherShare[] calldata _teachers,
        uint256 _totalamount
    ) external;

    function TeacherAddedEvent(
        address _courseAddress,
        OGSLib.TeacherShare[] calldata _teachers
    ) external;

    function TalentMatchAddedEvent(
        OGSLib.MatchData memory _newMatch,
        address _talentAddr,
        uint256 _amount
    ) external;

    function TalentMatchConfirmedEvent(
        OGSLib.MatchData memory _match,
        address _talentAddr,
        uint256 coachTotal,
        uint256 sponsorTotal,
        uint256 actualTreasuryTotal,
        uint256 teacherAmount
    ) external;

    function TalentMatchDeletedEvent(
        OGSLib.MatchData memory _match,
        address _talentAddr
    ) external;

    function TalentMatchUpdatedEvent(
        OGSLib.MatchData calldata _match,
        address _talentAddr,
        uint256 _amount
    ) external;

    function ShareSchemeUpdatedEvent(
        uint256 _coachShare,
        uint256 _sponsorShare,
        uint256 _teacherShare
    ) external;

    function setExecutor(address _address, bool _allow) external;

    function NeedRepairEvent(
        address _courseAddress,
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel
    ) external;

    function RepairedEvent(address _courseAddress, uint256 _tokenId) external;

    function TokenLendedEvent(
        address _courseAddress,
        uint256 _tokenId,
        bytes20 _Id
    ) external;
}
