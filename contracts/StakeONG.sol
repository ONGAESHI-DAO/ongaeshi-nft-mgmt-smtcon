// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @title A Staking Contract where users can earn incentives
/// @author xWin Finance
contract StakeONG is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct DepositData {
        uint256 amount;
        uint256 depositDuration;
        uint256 releaseTimestamp;
    }

    address public gtAddress;
    uint256 public MIN_DEPOSIT_DURATION;
    uint256 public MAX_DEPOSIT_DURATION;
    uint32 public MAX_INCENTIVE;
    mapping(address => mapping(uint32 => DepositData)) public userStakePosition;
    mapping(uint32 => address[]) public userList;
    mapping(uint32 => uint256) public totalDeposits;
    mapping(address => bool) public admins;

    event StakedToken(
        address indexed wallet,
        uint256 indexed releaseTimestamp,
        uint256 amount,
        uint256 depositDuration
    );
    event WithdrawToken(
        address indexed wallet,
        uint256 indexed releaseTimestamp,
        uint256 amount,
        uint256 depositDuration
    );

    /// Initializer function for ONGAESHI NFT Marketplace.
    /// @param _gtAddress ONGAESHI Token address.
    /// @param _maxIncentive Total number of incentive types.
    /// @param _maxDuration Maximum staking duration.
    /// @param _minDuration Minimum staking duration.
    function initialize(
        address _gtAddress,
        uint32 _maxIncentive,
        uint256 _maxDuration,
        uint256 _minDuration
    ) external initializer {
        require(_gtAddress != address(0), "token address input zero");
        require(_minDuration < _maxDuration, "Duration input invalid");
        __Ownable_init();
        gtAddress = _gtAddress;
        MAX_INCENTIVE = _maxIncentive;
        MAX_DEPOSIT_DURATION = _maxDuration;
        MIN_DEPOSIT_DURATION = _minDuration;
        admins[msg.sender] = true;
    }

    /// Locks ONGAESHI Tokens for a specified duration
    /// @param _amount amount of ONGAESHI Tokens to stake.
    /// @param _duration Stake duration in seconds
    /// @param _incentive Incentive type
    /// @dev Caller must have sufficient ONGAESHI token balance, and approve this contract for spending input amount.
    /// @dev Caller must not have an existing stake in the same incentive
    function stake(
        uint256 _amount,
        uint256 _duration,
        uint32 _incentive
    ) external {
        require(_amount > 0, "Amount must not be zero");
        require(_incentive > 0, "Invalid incentive zero");
        require(
            _duration >= MIN_DEPOSIT_DURATION,
            " Duration input below minimum"
        );
        require(_duration <= MAX_DEPOSIT_DURATION, "Exceed maximum duration");
        require(_incentive <= MAX_INCENTIVE, "Invalid incentive input");
        require(
            userStakePosition[msg.sender][_incentive].amount == 0,
            "Already have staking position"
        );
        IERC20Upgradeable(gtAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        DepositData memory newPosition;
        newPosition.amount = _amount;
        newPosition.depositDuration = _duration;
        newPosition.releaseTimestamp = block.timestamp + _duration;
        userStakePosition[msg.sender][_incentive] = newPosition;
        userList[_incentive].push(msg.sender);
        totalDeposits[_incentive] += _amount;
        //emit event
        emit StakedToken(
            msg.sender,
            newPosition.releaseTimestamp,
            _amount,
            _duration
        );
    }

    /// Withdraws ONGAESHI Tokens after stake duration has ended
    /// @param _incentive Incentive type to withdraw from
    /// @dev Block timestamp must be greater than user's stake releaseTimestamp
    function withdraw(uint32 _incentive) external {
        DepositData memory data = userStakePosition[msg.sender][_incentive];
        require(data.amount > 0, "No Stake detected on this incentive");
        require(
            data.releaseTimestamp < block.timestamp,
            "Stake duration still ongoing"
        );
        delete userStakePosition[msg.sender][_incentive];
        deleteUserFromArray(msg.sender, _incentive);
        totalDeposits[_incentive] -= data.amount;
        IERC20Upgradeable(gtAddress).safeTransfer(
            msg.sender,
            data.amount
        );

        emit WithdrawToken(
            msg.sender,
            data.releaseTimestamp,
            data.amount,
            data.depositDuration
        );
    }

    function deleteUserFromArray(address _user, uint32 _incentive) internal {
        for (uint256 i; i < userList[_incentive].length; i++) {
            if (userList[_incentive][i] == _user) {
                userList[_incentive][i] = userList[_incentive][
                    userList[_incentive].length - 1
                ];
                userList[_incentive].pop();
                return;
            }
        }
        require(false, "Error: User with stake position, but not in user list");
    }

    function setMaxIncentive(uint32 _newMaxIncentive) external onlyAdmin {
        MAX_INCENTIVE = _newMaxIncentive;
    }

    /// @notice Sets min and max staking duration of this smart contract. Caller must be admin.
    /// @param _newMinDuration New min duration for stake.
    /// @param _newMaxDuration New max duration for stake.
    function setMinMaxDuration(
        uint256 _newMinDuration,
        uint256 _newMaxDuration
    ) external onlyAdmin {
        require(MIN_DEPOSIT_DURATION < MAX_DEPOSIT_DURATION, "Invalid input");
        MIN_DEPOSIT_DURATION = _newMinDuration;
        MAX_DEPOSIT_DURATION = _newMaxDuration;
    }

    /// @notice Updates the ONGAESHI token address of this smart contract. Caller must be admin.
    /// @param _newAddr New ONGAESHI token address.
    function setTokenAddr(address _newAddr) external onlyAdmin {
        require(_newAddr != address(0), "input must not be 0");
        gtAddress = _newAddr;
    }

    /// Gets all stake wallet addresses for the input incentive
    /// @param _incentive incentive type
    function getAllUser(
        uint32 _incentive
    ) external view returns (address[] memory) {
        return userList[_incentive];
    }

    /// Gets a user's staking position in a given incentive
    /// @param _user Wallet address of user
    /// @param _incentive incentive type
    function getUserPosition(
        address _user,
        uint32 _incentive
    ) external view returns (DepositData memory) {
        return userStakePosition[_user][_incentive];
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
