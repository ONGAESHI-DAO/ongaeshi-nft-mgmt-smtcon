// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract CourseTokenFactory is OwnableUpgradeable {
    address[] public deployedAddresses;
    address public beaconAddr;
    address public treasury;

    function initialize(address _beaconAddress, address _treasuryWallet) public initializer {
        beaconAddr = _beaconAddress;
        treasury = _treasuryWallet;
        __Ownable_init();
    }

    function deployCourseToken(
        string memory _name, 
        string memory _symbol, 
        string memory _collectionURI, 
        uint256 _price, 
        uint256 _supplyLimit) 
    external onlyOwner returns (address) {
        string memory initializerFunction = "initialize(string,string,string,uint256,uint256,address)";
        BeaconProxy newProxyInstance = new BeaconProxy(
            beaconAddr,
            abi.encodeWithSignature(
                initializerFunction, 
                _name, 
                _symbol,
                _collectionURI,
                _price,
                _supplyLimit,
                treasury
            )
        );
        address newAddr = address(newProxyInstance);
        deployedAddresses.push(newAddr);
        OwnableUpgradeable(newAddr).transferOwnership(treasury);
        return newAddr;
    }

    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedAddresses;
    }

}
