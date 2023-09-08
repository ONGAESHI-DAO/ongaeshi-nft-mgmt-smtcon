// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library OGSLib {
    struct TeacherShare {
        address teacher;
        uint256 shares;
    }

    struct MatchData {
        address talent;
        address coach;
        address sponsor;
        address nftAddress;
        uint256 tokenId;
        uint256 amount;
        uint256 matchDate;
        uint256 payDate;
    }
}
