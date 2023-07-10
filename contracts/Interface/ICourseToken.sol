// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICourseToken {
    struct TeacherShare {
        address teacher;
        uint256 shares;
    }

    function payTeachers(uint256 amount) external;

    function setAdmin(address _address, bool _allow) external;

    function addTeacherShares(TeacherShare[] calldata _teacherShares) external;

    function isLended(uint256 _tokenId) external returns (address);

    function repairCost(uint256 _tokenId) external returns (uint256); 
}
