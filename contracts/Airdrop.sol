// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title An Airdrop Engine that sends tokens to many addresses in one transaction.
/// @author xWin Finance
contract Airdrop is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public immutable gtAddress;
    mapping(address => bool) public admins;

    /// @notice Deploys the airdrop contract, deployer wallet is set as owner and admin.
    /// @param _gtAddress Address of token to airdrop.
    constructor(address _gtAddress) {
        gtAddress = _gtAddress;
        admins[msg.sender] = true;
    }

    /// @notice Airdrops Tokens, recommended batch size of 300-500 addresses. Caller must be an admin wallet.
    /// @param _recipients Array of addresses to receive the airdrop tokens.
    /// @param _amounts Array of token amounts, corresponding to the recipients array.
    /** @dev Caller needs to have sufficient amounts of GT, and have approved GT spending to this contract before calling.
     * Recipient array must be the same length as amounts array.
    */
    function airdrop(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external payable nonReentrant onlyAdmin {
        uint256 len = _amounts.length;
        require(len == _recipients.length, "length mismatch");
        for (uint256 i = 0; i < len; i++) {
            IERC20(gtAddress).safeTransferFrom(
                msg.sender,
                _recipients[i],
                _amounts[i]
            );
        }
    }

    /// @notice Set admin status to any wallet, caller must be contract owner.
    /// @param _address Address to set admin status.
    /// @param _allow Admin status, true to give admin access, false to revoke.
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }
}
