# Solidity API

## CourseToken

_Token transfers can be disabled using the transferEnabled flag, where only admins may move NFTs.
When transfers are enabled, admins cannot move NFTs.
When the adminRepairOnly flag is true, only admins can repair NFTs._

### isLended

```solidity
mapping(uint256 => bytes20) isLended
```

### needRepairMap

```solidity
mapping(uint256 => bool) needRepairMap
```

### repairCost

```solidity
mapping(uint256 => uint256) repairCost
```

### tokenCID

```solidity
mapping(uint256 => string) tokenCID
```

### admins

```solidity
mapping(address => bool) admins
```

### baseURI

```solidity
string baseURI
```

### price

```solidity
uint256 price
```

### currentSupply

```solidity
uint256 currentSupply
```

### supplyLimit

```solidity
uint256 supplyLimit
```

### gtAddress

```solidity
address gtAddress
```

### treasury

```solidity
address treasury
```

### treasuryFee

```solidity
uint256 treasuryFee
```

### transferEnabled

```solidity
bool transferEnabled
```

### adminRepairOnly

```solidity
bool adminRepairOnly
```

### xEmitEvent

```solidity
contract ICourseTokenEvent xEmitEvent
```

### onlyAdmin

```solidity
modifier onlyAdmin()
```

### onlyEnabled

```solidity
modifier onlyEnabled()
```

### initialize

```solidity
function initialize(string _name, string _symbol, string _tokenBaseURI, uint256 _price, uint256 _treasuryFee, uint256 _supplyLimit, address _treasury, address _tokenAddr, address _emitEventAddr) external
```

### addTeacherShares

```solidity
function addTeacherShares(struct OGSLib.TeacherShare[] _teacherShares) external
```

_Caller must be admin wallet.
This function can only be called before the first NFT mint.
After the first mint, teacher fee distribution is immutable.
Shares in the input array must sum to 100% i.e 10000.
Teacher Shares must be initialised for before minting to function._

### mint

```solidity
function mint(uint256 _amount) external
```

Public minting of ONGAESHI Education NFT, where payment of ONGAESHI Tokens will be made to mint NFT.

_Portion of payment will be taken as tresury fee, paid to the treasury address, remainder is distributed among teachers._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Number of NFTs to mint, request may not exceed supply limit. |

### mintByAdmin

```solidity
function mintByAdmin(uint256 _amount, address _recipient) external
```

Admin minting of ONGAESHI Education NFT, Caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint256 | Number of NFTs to mint, request may not exceed supply limit. |
| _recipient | address | Recipient of newly minted NFTs. |

### setPrice

```solidity
function setPrice(uint256 _newPrice) external
```

Update minting price of NFT, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newPrice | uint256 | New minting price of NFT. |

### setTreasuryFee

```solidity
function setTreasuryFee(uint256 _treasuryFee) external
```

Updates treasury fee, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _treasuryFee | uint256 | New treasury fee, e.g. 500 = 5%, 1000 = 10%. |

### setTreasury

```solidity
function setTreasury(address _treasury) external
```

Updates recipient address of treasury fees. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _treasury | address | New address of treasury. |

### increaseSupplyLimit

```solidity
function increaseSupplyLimit(uint256 _increaseBy) external
```

Increase the NFT supply limit by input number. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _increaseBy | uint256 | number to increase supply limit by, e.g supplyLimit 100, increaseBy 5, new supplyLimit = 105. |

### decreaseSupplyLimit

```solidity
function decreaseSupplyLimit(uint256 _decreaseBy) external
```

Decrease the NFT supply limit by input number. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _decreaseBy | uint256 | number to decrease supply limit by, e.g supplyLimit 100, increaseBy 5, new supplyLimit = 95. |

### lendToken

```solidity
function lendToken(uint256 _tokenId, bytes20 _Id) external
```

Record loan status, caller must be Admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | Token to loan out. |
| _Id | bytes20 | Talent UUID to that is borring the token. |

### returnToken

```solidity
function returnToken(uint256 _tokenId, uint256 _repairCost, bool _isCancel) external
```

Record or Cancel NFT loan, token requires repair after, caller must be Admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | Loaned token to return. |
| _repairCost | uint256 | Cost to repair token. |
| _isCancel | bool | Flag, true indicates this is a cancel, false indicates its a return. |

### breakToken

```solidity
function breakToken(uint256 _tokenId, uint256 _repairCost, bool _isCancel, bytes20 _Id) internal
```

### repairToken

```solidity
function repairToken(uint256 _tokenId) external
```

_Portion of payment will be taken as tresury fee, paid to the treasury address, remainder is distributed among teachers.
adminRepairOnly Flag can disable this function._

### repairTokenByAdmin

```solidity
function repairTokenByAdmin(uint256 _tokenId) external
```

Repair NFT, caller must be admin wallet. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | Token to be repaired. |

### _baseURI

```solidity
function _baseURI() internal view returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### setBaseURI

```solidity
function setBaseURI(string _newBaseURI) external
```

Updates the Base URI for the entire NFT collection.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newBaseURI | string | New base URI. |

### setTokenURI

```solidity
function setTokenURI(uint256 _tokenId, string _cid) external
```

Updates the cid for the input token. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | Token to update cid. |
| _cid | string | New cid for token. |

### setTokenURIs

```solidity
function setTokenURIs(uint256[] _tokenId, string[] _cid) external
```

Batch update cid for input tokens. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256[] | Array of tokens to update cid. |
| _cid | string[] | Array of new cids for token. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

_See {IERC721Metadata-tokenURI}._

### setAdminRepairOnly

```solidity
function setAdminRepairOnly(bool _allow) external
```

Updates adminRepairOnly flag, caller must be admin wallet.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _allow | bool | new status of adminRepairOnly flag. |

### setTransferEnabled

```solidity
function setTransferEnabled(bool _allow) external
```

Updates transferEnabled flag, caller must be admin wallet. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _allow | bool | new status of transferEnabled flag. |

### setGTAddress

```solidity
function setGTAddress(address _gtAddress) external
```

Updates the ONGAESHI token address of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | New ONGAESHI token address. |

### payTeachers

```solidity
function payTeachers(uint256 amount) public
```

Function to distribute ONGAESHI tokens according to established teacher shares of this smart contract.

_Caller must have sufficient ONGAESHI token balance, and approve this contract for spending input amount._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | Amount of ONGAESHI tokens to distribute. |

### getSubTeachers

```solidity
function getSubTeachers() public view returns (struct OGSLib.TeacherShare[])
```

Gets the teacher shares data.

### setEmitEvent

```solidity
function setEmitEvent(address _emitEventAddr) external
```

Updates the contract address for event emitter.

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

### adminTransferFrom

```solidity
function adminTransferFrom(address from, address to, uint256 tokenId) public
```

Admin privilliged TransferFrom function. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | Address of NFT owner. |
| to | address | Address of NFT recipient. |
| tokenId | uint256 | Token Id of NFT to be transferred. |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) public virtual
```

_See {IERC721-transferFrom}._

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) public virtual
```

_See {IERC721-safeTransferFrom}._

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) public virtual
```

_See {IERC721-safeTransferFrom}._

