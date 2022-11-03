// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract JobCore { 
    // enum LocationSate {REMOTE, HYBRID, IN_PERSON}

    struct Job {
        bytes32 jobid;
        address employer;
        address applicants;
        IERC20 token;
        uint256 amount;
        bool paid;
        // string title;
        // string description;
        // LocationSate currentState;
    }

    mapping (bytes32 => Job) Jobs;
}