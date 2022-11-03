// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./JobCore.sol"; 

contract JobPosting is JobCore {
    enum State {SCREENING, FIRST_INTERVIEW, TECHNICAL_TEST, FINAL_INTERVIEW, HIRED, REJECTED}
    State public currentState;

    function newApplcation(bytes32 jobid) public {}

    function getMyApplications() public {}

    function getMyApplicants(bytes32 jobid) public {}

    function changeApplicationStatus(address applicantAddress, bytes32 jobid, string memory status) public {}

    function claimBounty(bytes32 jobid) public {}
}