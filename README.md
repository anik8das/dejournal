# Peer Review Smart Contract

This is a smart contract implemented in Solidity that enables peer review for manuscripts. The contract defines a series of functions and events that govern the review process. The contract has an admin, an author, assigned reviewers, assigned editor, and various states through which the manuscript moves during the review process.

## States

The manuscript goes through various states during the review process:

-   0: not reviewed
-   1: Reviewers Assigned
-   2: Editors Assigned
-   3: Comments Submitted
-   4: Manuscript Accepted
-   5: Manuscript Rejected
-   6: Peer review approved (admin)
-   7: Peer review cancelled (admin)

## Variables

-   admin: address of the contract admin
-   author: address of the manuscript author
-   manuscriptLink: string representing the URL where the manuscript can be accessed
-   manuscriptAbstract: string representing the abstract of the manuscript
-   assignedReviewers: array of two addresses representing the assigned reviewers
-   assignedEditor: address of the assigned editor
-   numReviewed: the number of reviewers who have submitted their comments
-   status: an integer representing the current state of the review process
-   balance: the amount of ether donated to the peer review

## Events

-   ReviewerAssigned: triggered when reviewers are assigned to the manuscript
-   EditorAssigned: triggered when an editor is assigned to the manuscript
-   CommentsSubmitted: triggered when reviewers submit their comments
-   ManuscriptAccepted: triggered when the manuscript is accepted
-   ManuscriptRejected: triggered when the manuscript is rejected
-   ReviewApproved: triggered when the peer review is approved by the admin
-   ReputationAwarded: triggered when reputation is awarded to the reviewers and editor
-   ReviewCancelled: triggered when the peer review is cancelled by the admin
-   ReputationStripped: triggered when the reputation is stripped from the reviewers and editor

## Functions

-   receiveFunds(): allows the contract to receive funds from donations
-   stakeReputation(uint256 amount): allows reviewers to stake their reputation in the peer review
-   withdrawReputation(uint256 amount): allows reviewers to withdraw their staked reputation
-   assignReviewers(): assigns reviewers to the manuscript based on their staked reputation
-   returnReputationToUnassigned(): returns the staked reputation to unassigned reviewers
-   assignEditor(): assigns an editor to the manuscript based on their staked reputation
-   submitComments(): allows reviewers to submit their comments on the manuscript
-   acceptReview(): allows the assigned editor to accept the manuscript
-   rejectReview(string memory \_reason): allows the assigned editor to reject the manuscript with a reason
-   confirmReview(): allows the admin to confirm the peer review
-   awardReputation(): awards reputation to the reviewers and editor and pays them based on their staked reputation
-   stripReputation(): strips the reputation from the reviewers and editor and returns the funds to the author
-   cancelReview(string memory \_reason): allows the admin to cancel the peer review with a reason

## Deployment

The smart contract can be deployed on the Ethereum network using Solidity compiler version 0.8.0 or higher. Once deployed, the contract can be interacted with by sending transactions to its functions. The contract can be accessed through its address, and the functions can be called using a web3 provider or any Ethereum client library.
