// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract CourseTokenFactory is OwnableUpgradeable {
    address[] public deployedAddresses;
    address public beaconAddr;
    address public gtAddress;

    function initialize(
        address _beaconAddress,
        address _tokenAddr
    ) public initializer {
        beaconAddr = _beaconAddress;
        gtAddress = _tokenAddr;
        __Ownable_init();
    }

    function deployCourseToken(
        string memory _name,
        string memory _symbol,
        string memory _collectionURI,
        string memory _tokenBaseURI,
        uint256 _price,
        uint256 _supplyLimit,
        address _teacher
    ) external onlyOwner returns (address) {
        string
            memory initializerFunction = "initialize(string,string,string,string,uint256,uint256,address,address)";
        BeaconProxy newProxyInstance = new BeaconProxy(
            beaconAddr,
            abi.encodeWithSignature(
                initializerFunction,
                _name,
                _symbol,
                _collectionURI,
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
        return newAddr;
    }

    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedAddresses;
    }
}
