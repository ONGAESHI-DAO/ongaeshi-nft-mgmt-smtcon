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

    function isLended(uint256 _tokenId) external returns (bytes20);

    function repairCost(uint256 _tokenId) external returns (uint256);

    function transferEnabled() external returns(bool);

    function adminTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
