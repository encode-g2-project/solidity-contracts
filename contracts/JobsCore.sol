// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FallbackHandler {
    fallback() external {}
}

contract JobsCore {
    enum LocationSate {REMOTE, HYBRID, IN_PERSON}

    struct Job {
        bytes32 id;
        address employer;
        address applicants;
        IERC20 token;
        uint256 amount;
        bool paid;
        string title;
        string description;
        LocationSate currentState;
    }

    mapping (bytes32 => Job) Jobs;

    event SubmissionSent(bytes32 indexed id, uint256 indexed amount);
    event CancellationSent(bytes32 indexed id, uint256 indexed amount);

    constructor(){}

    function submit(address payable employer, uint256 amount, IERC20 token, string memory title, string memory description) external payable {
        // paying it forward
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
        bytes32 id = keccak256(abi.encodePacked(employer, msg.sender, amount, block.timestamp));
        Job memory p = Job(id, msg.sender, msg.sender, token, amount, false, title, description, LocationSate.REMOTE);
        Jobs[id] = p;

        //emit event
        emit SubmissionSent(id, amount);
    }

    function cancel(bytes32 id) external payable onlyEmployer(id) {
        Job memory p = Jobs[id];
        require(p.paid != true, "You have already requested a refund");
        if (address(p.token) == address(0)) {
            (bool success, ) = p.applicants.call{value: p.amount}("");
            require(success, "Failed to send Ether");
        }  else {
            bool success = p.token.transferFrom(msg.sender, p.applicants, p.amount);
            require(success, "Failed to send ERC-20 Token");
        }

        p.paid = true;
        Jobs[id] = p;
        
        //emit event
        emit CancellationSent(p.id, p.amount);
    }

    function getSubmissionInfo(bytes32 id) external view returns (Job memory) {
        return Jobs[id];
    }

    // function set_value() public {
    //   choice = week_days.Thursday;
    // }

    modifier onlyEmployer(bytes32 id) {
        // check that Job exists
        Job memory p = Jobs[id];
        // check that msg.sender is the employer
        require(msg.sender == p.employer, "You are not the employer");
        _;
    }
}