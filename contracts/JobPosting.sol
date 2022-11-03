// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./JobCore.sol"; 

contract FallbackHandler {
    fallback() external {}
}

contract JobPosting is JobCore {
    event JobSubmissionSent(bytes32 indexed jobid, uint256 indexed amount);
    event JobCancellationSent(bytes32 indexed jobid, uint256 indexed amount);

    constructor(){}

    function postJob(address payable employer, uint256 amount, IERC20 token) external payable {
        if (msg.value != 0) {
            // eth transaction
            (bool success, ) = employer.call{value: msg.value}("");
            require(success, "Failed to send Ether");
            amount = msg.value;
        } else {
            // erc20 tx
            bool success = token.transferFrom(msg.sender, employer, amount);
            require(success, "Failed to send ERC-20 Token");
        } 

        // saving the details in Job struct
        bytes32 jobid = keccak256(abi.encodePacked(employer, msg.sender, amount, block.timestamp));
        Job memory p = Job(jobid, msg.sender, msg.sender, token, amount, false);
        Jobs[jobid] = p;

        //emit event
        emit JobSubmissionSent(jobid, amount);
    }

    function unpostJob(bytes32 jobid) external payable onlyEmployer(jobid) {
        Job memory p = Jobs[jobid];
        require(p.paid != true, "You have already requested a refund");
        if (address(p.token) == address(0)) {
            (bool success, ) = p.applicants.call{value: p.amount}("");
            require(success, "Failed to send Ether");
        }  else {
            bool success = p.token.transferFrom(msg.sender, p.applicants, p.amount);
            require(success, "Failed to send ERC-20 Token");
        }

        p.paid = true;
        Jobs[jobid] = p;
        
        //emit event
        emit JobCancellationSent(p.jobid, p.amount);
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
