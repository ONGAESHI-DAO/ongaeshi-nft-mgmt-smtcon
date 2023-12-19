# Solidity API

## StakeONG

### DepositData

```solidity
struct DepositData {
  uint256 amount;
  uint256 depositDuration;
  uint256 releaseTimestamp;
}
```

### gtAddress

```solidity
address gtAddress
```

### MIN_DEPOSIT_DURATION

```solidity
uint256 MIN_DEPOSIT_DURATION
```

### MAX_DEPOSIT_DURATION

```solidity
uint256 MAX_DEPOSIT_DURATION
```

### MAX_INCENTIVE

```solidity
uint32 MAX_INCENTIVE
```

### userStakePosition

```solidity
mapping(address => mapping(uint32 => struct StakeONG.DepositData)) userStakePosition
```

### userList

```solidity
mapping(uint32 => address[]) userList
```

### totalDeposits

```solidity
mapping(uint32 => uint256) totalDeposits
```

### admins

```solidity
mapping(address => bool) admins
```

### StakedToken

```solidity
event StakedToken(address wallet, uint256 releaseTimestamp, uint256 amount, uint256 depositDuration)
```

### WithdrawToken

```solidity
event WithdrawToken(address wallet, uint256 releaseTimestamp, uint256 amount, uint256 depositDuration)
```

### initialize

```solidity
function initialize(address _gtAddress, uint32 _maxIncentive, uint256 _maxDuration, uint256 _minDuration) external
```

Initializer function for ONGAESHI NFT Marketplace.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | ONGAESHI Token address. |
| _maxIncentive | uint32 | Total number of incentive types. |
| _maxDuration | uint256 | Maximum staking duration. |
| _minDuration | uint256 | Minimum staking duration. |

### stake

```solidity
function stake(uint256 _amount, uint256 _duration, uint32 _incentive) external
```

Locks ONGAESHI Tokens for a specified duration

_Caller must have sufficient ONGAESHI token balance, and approve this contract for spending input amount.
Caller must not have an existing stake in the same incentive_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | amount of ONGAESHI Tokens to stake. |
| _duration | uint256 | Stake duration in seconds |
| _incentive | uint32 | Incentive type |

### withdraw

```solidity
function withdraw(uint32 _incentive) external
```

Withdraws ONGAESHI Tokens after stake duration has ended

_Block timestamp must be greater than user's stake releaseTimestamp_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _incentive | uint32 | Incentive type to withdraw from |

### deleteUserFromArray

```solidity
function deleteUserFromArray(address _user, uint32 _incentive) internal
```

### setMaxIncentive

```solidity
function setMaxIncentive(uint32 _newMaxIncentive) external
```

### setMinMaxDuration

```solidity
function setMinMaxDuration(uint256 _newMinDuration, uint256 _newMaxDuration) external
```

Sets min and max staking duration of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newMinDuration | uint256 | New min duration for stake. |
| _newMaxDuration | uint256 | New max duration for stake. |

### setTokenAddr

```solidity
function setTokenAddr(address _newAddr) external
```

Updates the ONGAESHI token address of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newAddr | address | New ONGAESHI token address. |

### getAllUser

```solidity
function getAllUser(uint32 _incentive) external view returns (address[])
```

Gets all stake wallet addresses for the input incentive

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _incentive | uint32 | incentive type |

### getUserPosition

```solidity
function getUserPosition(address _user, uint32 _incentive) external view returns (struct StakeONG.DepositData)
```

Gets a user's staking position in a given incentive

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _user | address | Wallet address of user |
| _incentive | uint32 | incentive type |

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

### onlyAdmin

```solidity
modifier onlyAdmin()
```

