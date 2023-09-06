# Solidity API

## Airdrop

### gtAddress

```solidity
address gtAddress
```

### admins

```solidity
mapping(address => bool) admins
```

### constructor

```solidity
constructor(address _gtAddress) public
```

Deploys the airdrop contract, deployer wallet is set as owner and admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | Address of token to airdrop. |

### airdrop

```solidity
function airdrop(address[] _recipients, uint256[] _amounts) external payable
```

_Caller needs to have sufficient amounts of GT, and have approved GT spending to this contract before calling.
Recipient array must be the same length as amounts array._

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

