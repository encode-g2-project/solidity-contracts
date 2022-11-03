// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./JobCore.sol"; 

contract FallbackHandler {
    fallback() external {}
}

contract JobPosting is JobCore {
    event JobSubmissionSent(bytes32 indexed jobid, uint256 indexed amount);
    event JobCancellationSent(bytes32 indexed jobid, uint256 indexed amount);

    constructor(){}

    function publishJob(uint256 rolesToFill, uint256 bountyAmount, IERC20 token) external payable {
        if (bountyAmount == 0)
            require(msg.value != 0, "bounty can't be zero");
        if (msg.value == 0)
            require(bountyAmount != 0, "bounty can't be zero");        

        // saving the details in Job struct
        bytes32 jobid = keccak256(abi.encodePacked(msg.sender, bountyAmount, block.timestamp));
        address[] memory lApplicants = new address[](1);
        lApplicants[0] = msg.sender;
        Job memory p = Job(jobid, msg.sender, rolesToFill, lApplicants, token, bountyAmount, false);
        Jobs[jobid] = p;

        //emit event
        emit JobSubmissionSent(jobid, bountyAmount);
    }

    function unpublishJob(bytes32 jobid) external payable onlyEmployer(jobid) {
        Job memory p = Jobs[jobid];
        require(p.unpublished != true, "You have already unpublished this job");
        p.unpublished = true;
        Jobs[jobid] = p;
        
        // OR
        // we can delete the struct, but this will be gas intensive
        delete Jobs[jobid];

        //emit event
        emit JobCancellationSent(p.jobid, p.bountyAmount);

    }

    function getJobInfo(bytes32 jobid) external view returns (Job memory) {
        return Jobs[jobid];
    }

    modifier onlyEmployer(bytes32 jobid) {
        // check that Job exists
        Job memory p = Jobs[jobid];
        // check that msg.sender is the employer
        require(msg.sender == p.employer, "You are not the employer");
        _;
    }
}
