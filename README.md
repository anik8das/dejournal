# Decentralized Journal Smart Contract

This project is a decentralized journal smart contract that uses blockchain technology to enable a fair and transparent peer review system. The project consists of two files: manuscript.sol and journal.sol.

### Manuscript.sol

The manuscript.sol file contains the smart contract for the peer review system. It enables authors to submit manuscripts and reviewers to stake their reputation in order to participate in the peer review process. Editors can also stake their reputation to participate in the process.

Once a manuscript has been submitted, the smart contract randomly selects two reviewers and an editor based on their staked reputation. The reviewers and editor are then responsible for reviewing the manuscript and providing feedback.

If the manuscript is accepted, the reviewers and editor receive a reward for their work. If the manuscript is rejected or if there is a discrepancy in the review process, the staked reputation is cut off.

### Journal.sol

The journal.sol file contains the smart contract for the registration of authors, submission of manuscripts, and the repository of published papers. It enables authors to register, submit their manuscripts for review, and publish their work.

The smart contract ensures that the peer review process is fair and transparent by using the manuscript.sol contract for the peer review system.

### Getting Started

To get started with this project, you will need to deploy the smart contracts to a blockchain network such as Ethereum. You will also need to interact with the smart contracts using a tool such as Remix or Truffle. I would personally recommending testing these out on the Remix platform on a testnet.
