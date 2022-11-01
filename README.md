# solidity-contracts
Please see package.json to gauge dependencies used.

## JobsCore
Main smart contract that will handle the core functionality of the protocol.

### Functions
### submit()
Will be called by an employer that wants to create a job. Arguments include, but are not limited to:
- id: job posting id
- employer: company creating the job posting
- applicants: people applying to the role
- token/ether: send in the bounty within the function
- amount: token/ether amount
- paid: whether bounty has been distributed or not
- title: job title
- description: job description
- currentState: whether job is remote, in-person, or hybrid

### cancel()
Will be called by an employer to cancel the created job. This will fetch the id created by the seller in order to cancel/remove it.

### Improvements?
Will be best to host all job postings using IPFS rather than storing on-chain (expensive). Anyone with experience doing that?