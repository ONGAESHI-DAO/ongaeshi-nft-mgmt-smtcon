# Solidity API

## NFTMarketplace

This contract serves as a simple listing based NFT marketplace for ONGAESHI Education NFTs

### Listing

```solidity
struct Listing {
  address tokenAddress;
  uint256 tokenId;
  address nftOwner;
  uint256 price;
  uint256 index;
}
```

### listingMap

```solidity
mapping(address => mapping(uint256 => struct NFTMarketplace.Listing)) listingMap
```

### admins

```solidity
mapping(address => bool) admins
```

### listings

```solidity
struct NFTMarketplace.Listing[] listings
```

### treasury

```solidity
address treasury
```

### treasuryCommission

```solidity
uint256 treasuryCommission
```

### teacherCommission

```solidity
uint256 teacherCommission
```

### gtAddress

```solidity
address gtAddress
```

### Received

```solidity
event Received(address, address, uint256)
```

### ListingCreated

```solidity
event ListingCreated(address courseAddress, uint256 tokenId, address lister, uint256 price)
```

### ListingUpdated

```solidity
event ListingUpdated(address courseAddress, uint256 tokenId, uint256 oldPrice, uint256 newPrice)
```

### ListingDeleted

```solidity
event ListingDeleted(address courseAddress, uint256 tokenId)
```

### ListingPurchased

```solidity
event ListingPurchased(address courseAddress, uint256 tokenId, address buyer, uint256 price)
```

### initialize

```solidity
function initialize(address _gtAddress, address _treasury, uint256 _treasuryCommission, uint256 _teacherCommission) external
```

Initializer function for ONGAESHI NFT Marketplace.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | ONGAESHI Token address. |
| _treasury | address | Treasury wallet address. |
| _treasuryCommission | uint256 | Treasury commission fee percentage, e.g. 500 = 5%. |
| _teacherCommission | uint256 | Teacher commission fee percentage, e.g. 1200 = 12%. |

### createListing

```solidity
function createListing(address _tokenAddress, uint256 _tokenId, uint256 _amount) external
```

_NFT must not be currently lended out to a talent.
The NFT cannot be listed if it needs to be repaired.
The caller wallet must be the owner of the NFT.
This contract will hold ownership of the NFT while the listing is active._

### cancelListing

```solidity
function cancelListing(address _tokenAddress, uint256 _tokenId) external
```

Cancels an active listing and returns NFT to owner.

_Caller must the listing creator._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | ONGAESHI Education NFT Address. |
| _tokenId | uint256 | ID of NFT listing to remove. |

### updateListing

```solidity
function updateListing(address _tokenAddress, uint256 _tokenId, uint256 _amount) external
```

Updates the price of an existing listing, caller must be original listing creator.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | ONGAESHI Education NFT Address. |
| _tokenId | uint256 | ID of NFT listing to update. |
| _amount | uint256 | New price of NFT listing. |

### buyListing

```solidity
function buyListing(address _tokenAddress, uint256 _tokenId) external
```

_NFT will be transferred to the caller.
ONGAESHI Tokens will be paid to the listing creator, treasury and teachers specified in the NFT smart contract._

### setGTAddress

```solidity
function setGTAddress(address _gtAddress) external
```

Updates the ONGAESHI token address of this smart contract. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _gtAddress | address | New ONGAESHI token address. |

### setTreasury

```solidity
function setTreasury(address _newTreasury) external
```

Updates recipient address of treasury commission fees. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newTreasury | address | New address of treasury. |

### setTreasuryCommission

```solidity
function setTreasuryCommission(uint256 _newTreasuryCommission) external
```

Updates new treasury commission fee percentage.Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newTreasuryCommission | uint256 | New treasury commission fee. |

### setTeacherCommission

```solidity
function setTeacherCommission(uint256 _newTeacherCommission) external
```

Updates new teacher commission fee percentage. Caller must be admin.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newTeacherCommission | uint256 | New teacher commission fee. |

### onERC721Received

```solidity
function onERC721Received(address operator, address from, uint256 tokenId, bytes data) external returns (bytes4)
```

_Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called.

It must return its Solidity selector to confirm the token transfer.
If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.

The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`._

### getListing

```solidity
function getListing(address _tokenAddress, uint256 _tokenId) external view returns (struct NFTMarketplace.Listing)
```

### getAllListings

```solidity
function getAllListings() external view returns (struct NFTMarketplace.Listing[])
```

### getListingsCount

```solidity
function getListingsCount() external view returns (uint256)
```

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

### transferCourseToken

```solidity
function transferCourseToken(address courseToken, address from, address to, uint256 tokenId) internal
```

