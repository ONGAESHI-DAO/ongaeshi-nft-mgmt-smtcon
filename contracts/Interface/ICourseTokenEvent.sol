// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "../OGSLib.sol";

interface ICourseTokenEvent {
    
	function TokenMintEvent(address _courseAddress, address _destiny, uint _tokenId, uint _price) external;
	function PriceUpdatedEvent(address _courseAddress, uint _oldPrice, uint _newPrice) external;
	function SupplyLimitUpdatedEvent(address _courseAddress, uint _oldSupplyLimit, uint _newSupplyLimit) external;
	function CourseDeployedEvent(address _courseAddress, address _sender) external;
	function TeacherPaidEvent(address _courseAddress, OGSLib.TeacherShare[] calldata _teachers, uint _totalamount) external;
	function TeacherAddedEvent(address _courseAddress, OGSLib.TeacherShare[] calldata _teachers) external;
	function TalentMatchAddedEvent(OGSLib.MatchData memory _newMatch, address _talentAddr) external;
	function TalentMatchConfirmedEvent(OGSLib.MatchData memory _match, address _talentAddr, uint _amount) external;
	function TalentMatchDeletedEvent(OGSLib.MatchData memory _match, address _talentAddr) external;
	function TalentMatchUpdatedEvent(OGSLib.MatchData calldata _match, address _talentAddr) external;
	function ShareSchemeUpdatedEvent(uint _talentShare, uint _coachShare, uint _sponsorShare, uint _teacherShare) external;
	function setExecutor(address _address, bool _allow) external;
}


