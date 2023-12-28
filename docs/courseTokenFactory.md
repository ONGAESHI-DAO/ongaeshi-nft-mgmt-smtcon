# Solidity API

## CourseTokenFactory

This is a factory contract that deploys ONGAESHI Education NFT Smart Contracts.

### deployedAddresses

```solidity
address[] deployedAddresses
```

### beaconAddr

```solidity
address beaconAddr
```

### gtAddress

```solidity
address gtAddress
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
function initialize(address _beaconAddress, address _tokenAddr, address _emitEventAddr) external
```

Initializer function for deploying CourseTokenFactory contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _beaconAddress | address | Beacon implementation of CourseToken: ONGAESHI Education NFT. |
| _tokenAddr | address | ONGAESHI Token Contract Address. |
| _emitEventAddr | address | Event emitter. |

### deployCourseToken

```solidity
function deployCourseToken(string _name, string _symbol, string _tokenBaseURI, uint256 _price, uint256 _treasuryFee, uint256 _supplyLimit, address _treasury) external
```

This deploys a new ONGAESHI Education NFT onto the blockchain network, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _name | string | Name of the new NFT. |
| _symbol | string | Symbol of the new NFT. |
| _tokenBaseURI | string | Base URI for the new NFT. |
| _price | uint256 | Minting price in ONGAESHI Token. |
| _treasuryFee | uint256 | Treasury fee percentage, e.g 500 = 5%, 1000 = 10%. |
| _supplyLimit | uint256 | Total supply limit of the new NFT. |
| _treasury | address | Address of the treasury, to receive treasury fees. |

### getAllDeployedTokens

```solidity
function getAllDeployedTokens() external view returns (address[])
```

Returns all ONGAESHI Education NFT contract addresses deployed via this factory.

### setBeaconAddr

```solidity
function setBeaconAddr(address _beaconAddress) external
```

Updates the beacon proxy address containing the implementation of ONGAESHI Education NFT Smart Contract, Caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _beaconAddress | address | New beacon address. |

### setGTAddress

```solidity
function setGTAddress(address _gtAddress) external
```

Updates the ONGAESHI token address of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | New ONGAESHI token address. |

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

