// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./JobCore.sol"; 

contract JobPosting is JobCore {
    // enum State {SCREENING, FIRST_INTERVIEW, TECHNICAL_TEST, FINAL_INTERVIEW, HIRED, REJECTED}
    // State public currentState;

    function newApplcation(bytes32 jobid) public {
        Job memory p = Jobs[jobid];
        address[] memory lApplicants = new address[](1);
        lApplicants[p.applicants.length + 1] = msg.sender;
        p = Job(jobid, msg.sender, p.rolesToFill, lApplicants, p.token, p.bountyAmount, false);
        Jobs[jobid] = p;

        // problems
        // prevent msg.sender from applying again
        // appending msg.sender to an existing struct will delete all other applicants
    }

    function getMyApplications() public {}

    function getMyApplicants(bytes32 jobid) public view returns (address[] memory) {
        Job memory p = Jobs[jobid];
        return p.applicants;
    }

    function changeApplicationStatus(address applicantAddress, bytes32 jobid, string memory status) public {}

    function claimBounty(bytes32 jobid) public {
        Job memory p = Jobs[jobid];
        require(p.bountySent != true, "You have already requested a refund");
        
        if (address(p.token) == address(0)) {
            (bool success, ) = address(this).call{value: p.bountyAmount}("");
            require(success, "Failed to send Ether");
        }  else {
            bool success = p.token.transferFrom(msg.sender, address(this), p.bountyAmount);
            require(success, "Failed to send ERC-20 Token");
        }

        p.bountySent = true;
        Jobs[jobid] = p;
        
        //emit event
        //emit BountySent(p.jobid, p.bountySent, p.applicants);
    }
}