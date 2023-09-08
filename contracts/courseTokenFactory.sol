// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./Interface/ICourseToken.sol";
import "./Interface/ICourseTokenEvent.sol";

/// @title ONGAESHI Education NFT Smart Contract Factory
/// @author xWin Finance
/// @notice This is a factory contract that deploys ONGAESHI Education NFT Smart Contracts.
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializer function for deploying CourseTokenFactory contract.
    /// @param _beaconAddress Beacon implementation of CourseToken: ONGAESHI Education NFT.
    /// @param _tokenAddr ONGAESHI Token Contract Address.
    /// @param _emitEventAddr Event emitter.
    function initialize(
        address _beaconAddress,
        address _tokenAddr,
        address _emitEventAddr
    ) external initializer {
        require(_beaconAddress != address(0), "_beaconAddress is zero");
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        beaconAddr = _beaconAddress;
        gtAddress = _tokenAddr;
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
        admins[msg.sender] = true;
        __Ownable_init();
    }

    /// @notice This deploys a new ONGAESHI Education NFT onto the blockchain network, caller must be admin wallet.
    /// @param _name Name of the new NFT.
    /// @param _symbol Symbol of the new NFT.
    /// @param _tokenBaseURI Base URI for the new NFT.
    /// @param _price Minting price in ONGAESHI Token.
    /// @param _treasuryFee Treasury fee percentage, e.g 500 = 5%, 1000 = 10%.
    /// @param _supplyLimit Total supply limit of the new NFT.
    /// @param _treasury Address of the treasury, to receive treasury fees.
    function deployCourseToken(
        string calldata _name,
        string calldata _symbol,
        string calldata _tokenBaseURI,
        uint256 _price,
        uint256 _treasuryFee,
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
                _treasuryFee,
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

    /// @notice Returns all ONGAESHI Education NFT contract addresses deployed via this factory.
    function getAllDeployedTokens() external view returns (address[] memory) {
        return deployedAddresses;
    }

    /// @notice Updates the beacon proxy address containing the implementation of ONGAESHI Education NFT Smart Contract, Caller must be admin wallet.
    /// @param _beaconAddress New beacon address.
    function setBeaconAddr(address _beaconAddress) external onlyAdmin {
        require(_beaconAddress != address(0), "_beaconAddress is zero");
        beaconAddr = _beaconAddress;
    }

    /// @notice Updates the ONGAESHI token address of this smart contract. Caller must be admin.
    /// @param _gtAddress New ONGAESHI token address.
    function setGTAddress(address _gtAddress) external onlyAdmin {
        gtAddress = _gtAddress;
    }

    /// @notice Updates the contract address for event emitter. Caller must be admin.
    /// @param _emitEventAddr New event emitter contract address.
    /// @dev Ensure that this contract has access to emit events on the new event emitter.
    function setEmitEvent(address _emitEventAddr) external onlyAdmin {
        require(_emitEventAddr != address(0), "_emitEventAddr is zero");
        xEmitEvent = ICourseTokenEvent(_emitEventAddr);
    }

    /// @notice Set admin status to any wallet, caller must be contract owner.
    /// @param _address Address to set admin status.
    /// @param _allow Admin status, true to give admin access, false to revoke.
    function setAdmin(address _address, bool _allow) external onlyOwner {
        admins[_address] = _allow;
    }
}
