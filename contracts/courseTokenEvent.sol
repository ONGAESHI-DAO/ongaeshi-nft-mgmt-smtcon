// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./OGSLib.sol";

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
        address indexed talentAddr,
        uint256 amount
    );
    event TalentMatchConfirmed(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr,
        uint256 amount
    );
    event TalentMatchUpdated(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr,
        uint256 amount
    );
    event TalentMatchDeleted(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr
    );
    event ShareSchemeUpdated(
        uint256 talentShare,
        uint256 coachShare,
        uint256 sponsorShare,
        uint256 teacherShare
    );
    event NeedRepair(
        address indexed courseAddress,
        uint256 indexed tokenId,
        uint256 repairCost,
        bool isCancel
    );
    event Repaired(address indexed courseAddress, uint256 indexed tokenId);
    event TokenLended(
        address indexed courseAddress,
        uint256 indexed tokenId,
        address destiny
    );
    event ListingCreated(
        address indexed courseAddress,
        uint256 indexed tokenId,
        address lister,
        uint256 price
    );
    event ListingUpdated(
        address indexed courseAddress,
        uint256 indexed tokenId,
        uint256 oldPrice,
        uint256 newPrice
    );
    event ListingDeleted(
        address indexed courseAddress,
        uint256 indexed tokenId
    );
    event ListingPurchased(
        address indexed courseAddress,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );

    function initialize() external initializer {
        __Ownable_init();
        executors[msg.sender] = true;
    }

    function ShareSchemeUpdatedEvent(
        uint256 _talentShare,
        uint256 _coachShare,
        uint256 _sponsorShare,
        uint256 _teacherShare
    ) external onlyExecutor {
        emit ShareSchemeUpdated(
            _talentShare,
            _coachShare,
            _sponsorShare,
            _teacherShare
        );
    }

    function TalentMatchAddedEvent(
        OGSLib.MatchData memory _newMatch,
        address _talentAddr,
        uint256 _amount
    ) external onlyExecutor {
        emit TalentMatchAdded(_newMatch, _talentAddr, _amount);
    }

    function TalentMatchConfirmedEvent(
        OGSLib.MatchData memory _match,
        address _talentAddr,
        uint256 _amount
    ) external onlyExecutor {
        emit TalentMatchConfirmed(_match, _talentAddr, _amount);
    }

    function TalentMatchDeletedEvent(
        OGSLib.MatchData memory _match,
        address _talentAddr
    ) external onlyExecutor {
        emit TalentMatchDeleted(_match, _talentAddr);
    }

    function TalentMatchUpdatedEvent(
        OGSLib.MatchData calldata _match,
        address _talentAddr,
        uint256 _amount
    ) external onlyExecutor {
        emit TalentMatchUpdated(_match, _talentAddr, _amount);
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
        emit PriceUpdated(_courseAddress, _oldFee, _newFee);
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
        bool _isCancel
    ) external onlyExecutor {
        emit NeedRepair(_courseAddress, _tokenId, _repairCost, _isCancel);
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
        address destiny
    ) external onlyExecutor {
        emit TokenLended(_courseAddress, _tokenId, destiny);
    }

    function ListingCreatedEvent(
        address _courseAddress,
        uint256 _tokenId,
        address _lister,
        uint256 _price
    ) external onlyExecutor {
        emit ListingCreated(_courseAddress, _tokenId, _lister, _price);
    }

    function ListingUpdatedEvent(
        address _courseAddress,
        uint256 _tokenId,
        uint256 _oldPrice,
        uint256 _newPrice
    ) external onlyExecutor {
        emit ListingUpdated(_courseAddress, _tokenId, _oldPrice, _newPrice);
    }

    function ListingDeletedEvent(
        address _courseAddress,
        uint256 _tokenId
    ) external onlyExecutor {
        emit ListingDeleted(_courseAddress, _tokenId);
    }

    function ListingPurchasedEvent(
        address _courseAddress,
        uint256 _tokenId,
        address _buyer,
        uint256 _price
    ) external onlyExecutor {
        emit ListingPurchased(_courseAddress, _tokenId, _buyer, _price);
    }

    // Support multiple wallets or address as admin
    function setExecutor(address _address, bool _allow) external onlyExecutor {
        executors[_address] = _allow;
    }
}
