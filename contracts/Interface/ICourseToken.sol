// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICourseToken {
    function payTeachers(uint256 amount) external;
    function setAdmin(address _address, bool _allow) external;
    
}