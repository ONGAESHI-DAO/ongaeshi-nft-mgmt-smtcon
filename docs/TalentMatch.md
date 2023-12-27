# Solidity API

## TalentMatch

This contract can perform tasks of create, update, delete, payout, and confirm for the talent matching system.

### gtAddress

```solidity
address gtAddress
```

### treasuryAddress

```solidity
address treasuryAddress
```

### coachShare

```solidity
uint64 coachShare
```

### sponsorShare

```solidity
uint64 sponsorShare
```

### teacherShare

```solidity
uint64 teacherShare
```

### matchRegistry

```solidity
mapping(bytes20 => struct OGSLib.MatchData) matchRegistry
```

### admins

```solidity
mapping(address => bool) admins
```

### xEmitEvent

```solidity
contract ICourseTokenEvent xEmitEvent
```

### onlyAdmin

```solidity
modifier onlyAdmin()
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address _tokenAddr, uint64 _coachShare, uint64 _sponsorShare, uint64 _teacherShare, address _emitEventAddr, address _treasuryAddress) public
```

Initializer function for contract deployment.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddr | address | ONGAESHI Token Address. |
| _coachShare | uint64 | Percentage share for the coach. |
| _sponsorShare | uint64 | Percentage share for the sponsor. |
| _teacherShare | uint64 | Percentage share for the teachers. |
| _emitEventAddr | address | Event emitter contract address. |
| _treasuryAddress | address | Treasury address to receive token payments. |

### updateShareScheme

```solidity
function updateShareScheme(uint64 _coachShare, uint64 _sponsorShare, uint64 _teacherShare) external
```

_Percentage values have 2 decimal padding, e.g. 2100 = 21%, 300 = 3%.
Share total must be 10000, which represents 100%._

### addTalentMatch

```solidity
function addTalentMatch(bytes20 _Id, address _talent, address _coach, address _sponsor, address _nftAddress, uint256 _tokenId, uint256 _amount, uint256 _matchDate, uint256 _payDate) external
```

Adds a new talent match record into the smart contract, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _Id | bytes20 | Talent UUID, used as key for smart contract hashmap storage. |
| _talent | address | Talent wallet address, may be empty if talent wallet is unavailable. |
| _coach | address | Coach wallet address to receive coach share reward, may be empty if talent did not have a coach. |
| _sponsor | address | Sponsor wallet to receive sponsor share reward. |
| _nftAddress | address | Address of ONGAESHI Education NFT loaned and returned to talent. |
| _tokenId | uint256 | NFT ID. |
| _amount | uint256 | Talent matching payment reward amount. |
| _matchDate | uint256 | Date of talent matching. |
| _payDate | uint256 | Expected payment date of talent matching. |

### updateTalentMatch

```solidity
function updateTalentMatch(bytes20 _Id, address _talent, address _coach, address _sponsor, address _nftAddress, uint256 _tokenId, uint256 _amount, uint256 _matchDate, uint256 _payDate) external
```

Updates existing talent match record, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _Id | bytes20 | Talent UUID. |
| _talent | address | Talent wallet address, may be empty if talent wallet is unavailable. |
| _coach | address | Coach wallet address to receive coach share reward, may be empty if talent did not have a coach. |
| _sponsor | address | Sponsor wallet to receive sponsor share reward. |
| _nftAddress | address | Address of ONGAESHI Education NFT loaned and returned to talent. |
| _tokenId | uint256 | NFT ID. |
| _amount | uint256 | Talent matching payment reward amount. |
| _matchDate | uint256 | Date of talent matching. |
| _payDate | uint256 | Expected payment date of talent matching. |

### deleteTalentMatch

```solidity
function deleteTalentMatch(bytes20 _Id) external
```

Deletes existing talent match record, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _Id | bytes20 | Talent UUID |

### confirmTalentMatch

```solidity
function confirmTalentMatch(bytes20 _Id, uint256 _amount) external
```

_Caller needs to have sufficient ONGAESHI tokens and has given spending approval to this contract.
Teacher's reward will be distributed based on the teacher share scheme of the original ONGAESHI Education NFT in the talent matching.
Supported edge case:
1) If talent is their own sponsor, talent shares are given to the treasury instead.
2) If talent completed their education without a coach, coach address will be empty, and coach shares are given to the treasury._

### setGTAddress

```solidity
function setGTAddress(address _gtAddress) external
```

Updates the ONGAESHI token address of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | New ONGAESHI token address. |

### setTreasuryAddress

```solidity
function setTreasuryAddress(address _treasuryAddress) external
```

Updates recipient address of treasury fees. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _treasuryAddress | address | New address of treasury. |

### setEmitEvent

```solidity
function setEmitEvent(address _emitEventAddr) external
```

Updates the contract address for event emitter. Caller must be admin.

_Ensure that this contract has access to emit events on the new event emitter._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _emitEventAddr | address | New event emitter contract address. |

### setAdmin

```solidity
function setAdmin(address _address, bool _allow) external
```

Set admin status to any wallet, caller must be contract owner.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _address | address | Address to set admin status. |
| _allow | bool | Admin status, true to give admin access, false to revoke. |

