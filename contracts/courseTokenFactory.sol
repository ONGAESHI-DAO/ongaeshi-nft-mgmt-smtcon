// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract CourseTokenFactory is OwnableUpgradeable {
    address[] public deployedAddresses;
    address public beaconAddr;
    address public gtAddress;
    mapping(address => bool) public admins;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }
    event CourseDeployed(address indexed courseAddress);

    function initialize(
        address _beaconAddress,
        address _tokenAddr
    ) external initializer {
        beaconAddr = _beaconAddress;
        gtAddress = _tokenAddr;
        admins[msg.sender] = true;
        __Ownable_init();
    }

    function deployCourseToken(
        string calldata _name,
        string calldata _symbol,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _supplyLimit,
        address _teacher
    ) external onlyAdmin {
        string
            memory initializerFunction = "initialize(string,string,string,uint256,uint256,address,address)";
        BeaconProxy newProxyInstance = new BeaconProxy(
            beaconAddr,
            abi.encodeWithSignature(
                initializerFunction,
                _name,
                _symbol,
                _tokenBaseURI,
                _price,
                _supplyLimit,
                _teacher,
                gtAddress
            )
        );
        address newAddr = address(newProxyInstance);
        deployedAddresses.push(newAddr);
        OwnableUpgradeable(newAddr).transferOwnership(msg.sender);
        emit CourseDeployed(newAddr);
    }

    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedAddresses;
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }

}
