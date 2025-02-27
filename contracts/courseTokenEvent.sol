// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./OGSLib.sol";

/// @title Event emitter Contract
/// @author xWin Finance
/// @notice Emits all Events for ONGAESHI DAO for NFT mint, loan, repair, talent match and contract parameter updates.
contract CourseTokenEvent is OwnableUpgradeable {
    modifier onlyExecutor() {
        require(executors[msg.sender], "executor: wut?");
        _;
    }

    mapping(address => bool) public executors;
    event CourseDeployed(address indexed courseAddress, address indexed sender);
    event TokenMint(
        address indexed destAddress,
        address indexed courseAddress,
        uint256 tokenId,
        uint256 price
    );
    event PriceUpdated(
        address indexed courseAddress,
        uint256 oldPrice,
        uint256 newPrice
    );
    event FeeUpdated(
        address indexed courseAddress,
        uint256 oldFee,
        uint256 newFee
    );
    event TreasuryUpdated(
        address indexed courseAddress,
        address oldTreasury,
        address newTreasury
    );
    event SupplyLimitUpdated(
        address indexed courseAddress,
        uint256 oldSupplyLimit,
        uint256 newSupplyLimit
    );
    event TeacherPaid(
        address indexed courseAddress,
        OGSLib.TeacherShare[] teachers,
        uint256 totalamount
    );
    event TeacherAdded(
        address indexed courseAddress,
        OGSLib.TeacherShare[] teachers
    );
    event TalentMatchAdded(
        OGSLib.MatchData newMatch,
        bytes20 indexed _Id,
        uint256 amount
    );
    event TalentMatchConfirmed(
        OGSLib.MatchData existingMatch,
        bytes20 _Id,
        uint256 coachTotal,
        uint256 sponsorTotal,
        uint256 actualTreasuryTotal,
        uint256 teacherAmount
    );
    event TalentMatchUpdated(
        OGSLib.MatchData existingMatch,
        bytes20 indexed _Id,
        uint256 amount
    );
    event TalentMatchDeleted(
        OGSLib.MatchData existingMatch,
        bytes20 indexed _Id
    );
    event ShareSchemeUpdated(
        uint256 coachShare,
        uint256 sponsorShare,
        uint256 teacherShare
    );
    event NeedRepair(
        address indexed courseAddress,
        uint256 indexed tokenId,
        uint256 repairCost,
        bool isCancel,
        bytes20 loanId
    );
    event Repaired(address indexed courseAddress, uint256 indexed tokenId);
    event TokenLended(
        address indexed courseAddress,
        uint256 indexed tokenId,
        bytes20 loanId
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() external initializer {
        __Ownable_init();
        executors[msg.sender] = true;
    }

    function ShareSchemeUpdatedEvent(
        uint256 _coachShare,
        uint256 _sponsorShare,
        uint256 _teacherShare
    ) external onlyExecutor {
        emit ShareSchemeUpdated(_coachShare, _sponsorShare, _teacherShare);
    }

    function TalentMatchAddedEvent(
        OGSLib.MatchData memory _newMatch,
        bytes20 _Id,
        uint256 _amount
    ) external onlyExecutor {
        emit TalentMatchAdded(_newMatch, _Id, _amount);
    }

    function TalentMatchConfirmedEvent(
        OGSLib.MatchData memory _match,
        bytes20 _Id,
        uint256 coachTotal,
        uint256 sponsorTotal,
        uint256 actualTreasuryTotal,
        uint256 teacherAmount
    ) external onlyExecutor {
        emit TalentMatchConfirmed(
            _match,
            _Id,
            coachTotal,
            sponsorTotal,
            actualTreasuryTotal,
            teacherAmount
        );
    }

    function TalentMatchDeletedEvent(
        OGSLib.MatchData memory _match,
        bytes20 _Id
    ) external onlyExecutor {
        emit TalentMatchDeleted(_match, _Id);
    }

    function TalentMatchUpdatedEvent(
        OGSLib.MatchData calldata _match,
        bytes20 _Id,
        uint256 _amount
    ) external onlyExecutor {
        emit TalentMatchUpdated(_match, _Id, _amount);
    }

    function TokenMintEvent(
        address _courseAddress,
        address _destiny,
        uint256 _tokenId,
        uint256 _price
    ) external onlyExecutor {
        emit TokenMint(_destiny, _courseAddress, _tokenId, _price);
    }

    function PriceUpdatedEvent(
        address _courseAddress,
        uint256 _oldPrice,
        uint256 _newPrice
    ) external onlyExecutor {
        emit PriceUpdated(_courseAddress, _oldPrice, _newPrice);
    }

    function FeeUpdatedEvent(
        address _courseAddress,
        uint256 _oldFee,
        uint256 _newFee
    ) external onlyExecutor {
        emit FeeUpdated(_courseAddress, _oldFee, _newFee);
    }

    function TreasuryUpdatedEvent(
        address _courseAddress,
        address _oldTreasury,
        address _newTreasury
    ) external onlyExecutor {
        emit TreasuryUpdated(_courseAddress, _oldTreasury, _newTreasury);
    }

    function SupplyLimitUpdatedEvent(
        address _courseAddress,
        uint256 _oldSupplyLimit,
        uint256 _newSupplyLimit
    ) external onlyExecutor {
        emit SupplyLimitUpdated(
            _courseAddress,
            _oldSupplyLimit,
            _newSupplyLimit
        );
    }

    function CourseDeployedEvent(
        address _courseAddress,
        address _sender
    ) external onlyExecutor {
        emit CourseDeployed(_courseAddress, _sender);
    }

    function TeacherPaidEvent(
        address _courseAddress,
        OGSLib.TeacherShare[] calldata _teachers,
        uint256 _totalamount
    ) external onlyExecutor {
        emit TeacherPaid(_courseAddress, _teachers, _totalamount);
    }

    function TeacherAddedEvent(
        address _courseAddress,
        OGSLib.TeacherShare[] calldata _teachers
    ) external onlyExecutor {
        emit TeacherAdded(_courseAddress, _teachers);
    }

    function NeedRepairEvent(
        address _courseAddress,
        uint256 _tokenId,
        uint256 _repairCost,
        bool _isCancel,
        bytes20 _Id
    ) external onlyExecutor {
        emit NeedRepair(_courseAddress, _tokenId, _repairCost, _isCancel, _Id);
    }

    function RepairedEvent(
        address _courseAddress,
        uint256 _tokenId
    ) external onlyExecutor {
        emit Repaired(_courseAddress, _tokenId);
    }

    function TokenLendedEvent(
        address _courseAddress,
        uint256 _tokenId,
        bytes20 _Id
    ) external onlyExecutor {
        emit TokenLended(_courseAddress, _tokenId, _Id);
    }

    /// @notice Set executor status to any contract, caller must be an Executor
    /// @param _address Address to set executor status
    /// @param _allow Executor status, true to give access, false to revoke
    function setExecutor(address _address, bool _allow) external onlyExecutor {
        executors[_address] = _allow;
    }
}
