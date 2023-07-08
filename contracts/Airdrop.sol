// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Airdrop is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    address public immutable gtAddress;
    mapping(address => bool) public admins;

    constructor(address _gtAddress) {
        gtAddress = _gtAddress;
        admins[msg.sender] = true;
    }

    // max airdrop I've seen is 3500 addresses with fixed amount with 1 gwei gas price
    // given that we give 2 arrays instead of 1
    // max airdrop should be ~1000 addresses @ 1 gwei or ~300 addresses @ 3 gwei
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

    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }
}
