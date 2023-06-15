// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";

contract CourseTokenFactory is OwnableUpgradeable {
    address[] public deployedAddresses;
    address public beaconAddr;
    address public gtAddress;
    mapping(address => bool) public admins;
    ICourseTokenEvent public xEmitEvent;

    modifier onlyAdmin() {
        require(admins[msg.sender], "admin: wut?");
        _;
    }

    function initialize(
        address _beaconAddress,
        address _tokenAddr,
        address _emitEventAddr
    ) external initializer {
        require(_beaconAddress != address(0), "_beaconAddress is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        require(_tokenAddr != address(0), "_tokenAddr is zero");
        beaconAddr = _beaconAddress;
        gtAddress = _tokenAddr;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
        admins[msg.sender] = true;
        __Ownable_init();
    }

    function deployCourseToken(
        string calldata _name,
        string calldata _symbol,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _commissionFee,
        uint256 _supplyLimit,
        address _treasury
    ) external onlyAdmin {
        string
            memory initializerFunction = "initialize(string,string,string,uint256,uint256,uint256,address,address,address)";
        BeaconProxy newProxyInstance = new BeaconProxy(
            beaconAddr,
            abi.encodeWithSignature(
                initializerFunction,
                _name,
                _symbol,
                _tokenBaseURI,
                _price,
                _commissionFee,
                _supplyLimit,
                _treasury,
                gtAddress,
                address(xEmitEvent)
            )
        );
        address newAddr = address(newProxyInstance);
        deployedAddresses.push(newAddr);
        xEmitEvent.setExecutor(newAddr, true);
        ICourseToken(newAddr).setAdmin(msg.sender, true);
        OwnableUpgradeable(newAddr).transferOwnership(msg.sender);
        xEmitEvent.CourseDeployedEvent(newAddr, msg.sender);
    }

    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedAddresses;
    }

    function setBeaconAddr(address _beaconAddress) external onlyOwner {
        require(_beaconAddress != address(0), "_beaconAddress is zero");
        beaconAddr = _beaconAddress;
    }

    function setEmitEvent(address _emitEventAddr) external onlyOwner {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    // Support multiple wallets or address as admin
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
