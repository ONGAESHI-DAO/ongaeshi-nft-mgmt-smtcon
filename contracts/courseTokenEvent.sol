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
        uint tokenId,
        uint price
    );
    event PriceUpdated(
        address indexed courseAddress,
        uint oldPrice,
        uint newPrice
    );
    event SupplyLimitUpdated(
        address indexed courseAddress,
        uint oldSupplyLimit,
        uint newSupplyLimit
    );
    event TeacherPaid(
        address indexed courseAddress,
        OGSLib.TeacherShare[] teachers,
        uint totalamount
    );
    event TeacherAdded(
        address indexed courseAddress,
        OGSLib.TeacherShare[] teachers
    );
    event TalentMatchAdded(
        OGSLib.MatchData newMatch,
        address indexed talentAddr
    );
    event TalentMatchConfirmed(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr,
        uint amount
    );
    event TalentMatchUpdated(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr
    );
    event TalentMatchDeleted(
        OGSLib.MatchData existingMatch,
        address indexed talentAddr
    );
    event ShareSchemeUpdated(
        uint talentShare,
        uint coachShare,
        uint sponsorShare,
        uint teacherShare
    );

    function initialize() external initializer {
        __Ownable_init();
        executors[msg.sender] = true;
    }

    function ShareSchemeUpdatedEvent(
        uint _talentShare,
        uint _coachShare,
        uint _sponsorShare,
        uint _teacherShare
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
        address _talentAddr
    ) external onlyExecutor {
        emit TalentMatchAdded(_newMatch, _talentAddr);
    }

    function TalentMatchConfirmedEvent(
        OGSLib.MatchData memory _match,
        address _talentAddr,
        uint _amount
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
        address _talentAddr
    ) external onlyExecutor {
        emit TalentMatchUpdated(_match, _talentAddr);
    }

    function TokenMintEvent(
        address _courseAddress,
        address _destiny,
        uint _tokenId,
        uint _price
    ) external onlyExecutor {
        emit TokenMint(_destiny, _courseAddress, _tokenId, _price);
    }

    function PriceUpdatedEvent(
        address _courseAddress,
        uint _oldPrice,
        uint _newPrice
    ) external onlyExecutor {
        emit PriceUpdated(_courseAddress, _oldPrice, _newPrice);
    }

    function SupplyLimitUpdatedEvent(
        address _courseAddress,
        uint _oldSupplyLimit,
        uint _newSupplyLimit
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
        uint _totalamount
    ) external onlyExecutor {
        emit TeacherPaid(_courseAddress, _teachers, _totalamount);
    }

    function TeacherAddedEvent(
        address _courseAddress,
        OGSLib.TeacherShare[] calldata _teachers
    ) external onlyExecutor {
        emit TeacherAdded(_courseAddress, _teachers);
    }

    // Support multiple wallets or address as admin
    function setExecutor(address _address, bool _allow) external onlyExecutor {
        executors[_address] = _allow;
    }
}
