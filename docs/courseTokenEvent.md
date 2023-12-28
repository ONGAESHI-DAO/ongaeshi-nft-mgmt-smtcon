# Solidity API

## CourseTokenEvent

Emits all Events for ONGAESHI DAO for NFT mint, loan, repair, talent match and contract parameter updates.

### onlyExecutor

```solidity
modifier onlyExecutor()
```

### executors

```solidity
mapping(address => bool) executors
```

### CourseDeployed

```solidity
event CourseDeployed(address courseAddress, address sender)
```

### TokenMint

```solidity
event TokenMint(address destAddress, address courseAddress, uint256 tokenId, uint256 price)
```

### PriceUpdated

```solidity
event PriceUpdated(address courseAddress, uint256 oldPrice, uint256 newPrice)
```

### FeeUpdated

```solidity
event FeeUpdated(address courseAddress, uint256 oldFee, uint256 newFee)
```

### TreasuryUpdated

```solidity
event TreasuryUpdated(address courseAddress, address oldTreasury, address newTreasury)
```

### SupplyLimitUpdated

```solidity
event SupplyLimitUpdated(address courseAddress, uint256 oldSupplyLimit, uint256 newSupplyLimit)
```

### TeacherPaid

```solidity
event TeacherPaid(address courseAddress, struct OGSLib.TeacherShare[] teachers, uint256 totalamount)
```

### TeacherAdded

```solidity
event TeacherAdded(address courseAddress, struct OGSLib.TeacherShare[] teachers)
```

### TalentMatchAdded

```solidity
event TalentMatchAdded(struct OGSLib.MatchData newMatch, bytes20 _Id, uint256 amount)
```

### TalentMatchConfirmed

```solidity
event TalentMatchConfirmed(struct OGSLib.MatchData existingMatch, bytes20 _Id, uint256 coachTotal, uint256 sponsorTotal, uint256 actualTreasuryTotal, uint256 teacherAmount)
```

### TalentMatchUpdated

```solidity
event TalentMatchUpdated(struct OGSLib.MatchData existingMatch, bytes20 _Id, uint256 amount)
```

### TalentMatchDeleted

```solidity
event TalentMatchDeleted(struct OGSLib.MatchData existingMatch, bytes20 _Id)
```

### ShareSchemeUpdated

```solidity
event ShareSchemeUpdated(uint256 coachShare, uint256 sponsorShare, uint256 teacherShare)
```

### NeedRepair

```solidity
event NeedRepair(address courseAddress, uint256 tokenId, uint256 repairCost, bool isCancel, bytes20 loanId)
```

### Repaired

```solidity
event Repaired(address courseAddress, uint256 tokenId)
```

### TokenLended

```solidity
event TokenLended(address courseAddress, uint256 tokenId, bytes20 loanId)
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize() external
```

### ShareSchemeUpdatedEvent

```solidity
function ShareSchemeUpdatedEvent(uint256 _coachShare, uint256 _sponsorShare, uint256 _teacherShare) external
```

### TalentMatchAddedEvent

```solidity
function TalentMatchAddedEvent(struct OGSLib.MatchData _newMatch, bytes20 _Id, uint256 _amount) external
```

### TalentMatchConfirmedEvent

```solidity
function TalentMatchConfirmedEvent(struct OGSLib.MatchData _match, bytes20 _Id, uint256 coachTotal, uint256 sponsorTotal, uint256 actualTreasuryTotal, uint256 teacherAmount) external
```

### TalentMatchDeletedEvent

```solidity
function TalentMatchDeletedEvent(struct OGSLib.MatchData _match, bytes20 _Id) external
```

### TalentMatchUpdatedEvent

```solidity
function TalentMatchUpdatedEvent(struct OGSLib.MatchData _match, bytes20 _Id, uint256 _amount) external
```

### TokenMintEvent

```solidity
function TokenMintEvent(address _courseAddress, address _destiny, uint256 _tokenId, uint256 _price) external
```

### PriceUpdatedEvent

```solidity
function PriceUpdatedEvent(address _courseAddress, uint256 _oldPrice, uint256 _newPrice) external
```

### FeeUpdatedEvent

```solidity
function FeeUpdatedEvent(address _courseAddress, uint256 _oldFee, uint256 _newFee) external
```

### TreasuryUpdatedEvent

```solidity
function TreasuryUpdatedEvent(address _courseAddress, address _oldTreasury, address _newTreasury) external
```

### SupplyLimitUpdatedEvent

```solidity
function SupplyLimitUpdatedEvent(address _courseAddress, uint256 _oldSupplyLimit, uint256 _newSupplyLimit) external
```

### CourseDeployedEvent

```solidity
function CourseDeployedEvent(address _courseAddress, address _sender) external
```

### TeacherPaidEvent

```solidity
function TeacherPaidEvent(address _courseAddress, struct OGSLib.TeacherShare[] _teachers, uint256 _totalamount) external
```

### TeacherAddedEvent

```solidity
function TeacherAddedEvent(address _courseAddress, struct OGSLib.TeacherShare[] _teachers) external
```

### NeedRepairEvent

```solidity
function NeedRepairEvent(address _courseAddress, uint256 _tokenId, uint256 _repairCost, bool _isCancel, bytes20 _Id) external
```

### RepairedEvent

```solidity
function RepairedEvent(address _courseAddress, uint256 _tokenId) external
```

### TokenLendedEvent

```solidity
function TokenLendedEvent(address _courseAddress, uint256 _tokenId, bytes20 _Id) external
```

### setExecutor

```solidity
function setExecutor(address _address, bool _allow) external
```

Set executor status to any contract, caller must be an Executor

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | Address to set executor status |
| _allow | bool | Executor status, true to give access, false to revoke |

