# Peer review smart contract

This smart contract is designed to facilitate the peer review process for scholarly articles. It allows authors to submit manuscripts for review and assigns reviewers to provide feedback. An editor is responsible for overseeing the review process and making the final decision on whether to accept or reject the manuscript. The goal is to provide a secure and transparent way to manage the peer review process for scholarly articles. It ensures that the review process is fair and unbiased, and attempts to elminate friction between authors, reviewers, and editors.

## Contract Functions:

1. addEditor(address \_editor, uint256 \_reputation) public: This function is used to add an editor to the contract. The editor's address and reputation are provided as input.
2. addReviewer(address \_reviewer, uint256 \_reputation) public: This function is used to add a reviewer to the contract. The reviewer's address and reputation are provided as input.
3. submitManuscript(string memory \_title, string memory \_abstract) public: This function allows an author to submit a manuscript for review. The title and abstract of the manuscript are provided as input.
4. assignReviewers() public: This function assigns two reviewers to review the submitted manuscript. The reviewers are chosen at random based on their reputation.
5. assignEditor() public: This function assigns an editor to oversee the review process. The editor is chosen at random based on their reputation.
6. submitReview() public: This function allows a reviewer to submit their review of the manuscript. Only the assigned reviewers can complete the review.
7. acceptReview() public: This function allows the assigned editor to accept the review and make a decision on whether to accept or reject the manuscript.
8. rejectReview(string memory \_reason) public: This function allows the assigned editor to reject the review and provide a reason for the rejection.

## Contract Variables:

status: This variable tracks the status of the manuscript. The possible values are: 0 (Submitted), 1 (Under Review), 2 (Review Complete - Pending Editor Decision), 3 (Accepted), 4 (Rejected).

1. reviewed: This variable indicates whether the manuscript has been reviewed or not.
2. numReviewed: This variable tracks the number of reviews that have been completed.
3. assignedReviewers: This array stores the addresses of the two reviewers assigned to review the manuscript.
4. assignedEditor: This variable stores the address of the editor assigned to oversee the review process.
5. manuscript: This struct stores information about the manuscript, including the title, abstract, and author.
6. reviewers: This mapping stores information about the reviewers, including their reputation and whether they have completed their review.
7. listOfReviewers: This array stores the addresses of all the reviewers added to the contract.
8. listOfEditors: This array stores the addresses of all the editors added to the contract.
