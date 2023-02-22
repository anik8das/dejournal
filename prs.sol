pragma solidity ^0.8.0;

contract PeerReview {
    // Define state variables
    address author; // the address of the author who submitted the manuscript
    string manuscriptLink; // a link to the manuscript
    string manuscriptAbstract; // a short abstract of the manuscript
    bool reviewed; // a flag to indicate if the manuscript has been reviewed or not
    address[] assignedReviewers; // an array of addresses of reviewers assigned to review the manuscript
    address assignedEditor; // the address of the editor assigned to review the manuscript
    uint256 numReviewed = 0; // the number of reviewers who have completed their reviews
    uint256 status; // 0: submitted, 1: under review, 2: review completed, 3: accepted, 4: rejected

    // Define the Reviewer struct
    struct Reviewer {
        address addr; // the address of the reviewer
        uint256 reputation; // the reputation of the reviewer
        bool isAssigned; // a flag to indicate if the reviewer is assigned to review the manuscript or not
        bool hasReviewed; // a flag to indicate if the reviewer has completed their review or not
    }

    // Define the Editor struct
    struct Editor {
        address addr; // the address of the editor
        uint256 reputation; // the reputation of the editor
        bool isAssigned; // a flag to indicate if the editor is assigned to review the manuscript or not
        bool isAccepted; // a flag to indicate if the editor has accepted the manuscript or not
    }

    // Define the mapping for reviewers
    mapping(address => Reviewer) public reviewers; // a mapping to keep track of the reviewers in the contract
    address[] listOfReviewers; // an array of addresses of the reviewers in the contract

    // Define the mapping for editors
    mapping(address => Editor) public editors; // a mapping to keep track of the editors in the contract
    address[] listOfEditors; // an array of addresses of the editors in the contract

    // Define events
    event ReviewerAssigned(
        address indexed reviewerAddr1,
        address indexed reviewerAddr2
    ); // emitted when reviewers are assigned to review the manuscript
    event EditorAssigned(address indexed editorAddr); // emitted when an editor is assigned to review the manuscript
    event ReviewSubmitted(); // emitted when the author submits the manuscript
    event ReviewAccepted(); // emitted when the editor accepts the manuscript
    event ReviewRejected(string reason); // emitted when the editor rejects the manuscript

    // Define functions for author, reviewer, and editor actions

    function submitManuscript(string memory _manuscriptUrl) public {
        // Set the author as the message sender
        author = msg.sender;
        // Set the manuscript link to the provided URL
        manuscriptLink = _manuscriptUrl;
        // Set the manuscript status to "submitted"
        status = 0;
        // Set the manuscript review status to false
        reviewed = false;
    }

    function stakeReputation(uint256 amount) public payable {
        // Check if the reviewer is already in the reviewers mapping, and update their reputation if so
        if (reviewers[msg.sender].addr == msg.sender) {
            reviewers[msg.sender].reputation += amount;
        } else {
            // Otherwise, add the reviewer to the reviewers mapping with the given reputation
            reviewers[msg.sender] = Reviewer(msg.sender, amount, false, false);
            // Add the reviewer to the list of reviewers
            listOfReviewers.push(msg.sender);
        }
    }

    function withdrawReputation(uint256 amount) public {
        // Ensure that the sender is a registered reviewer
        require(
            reviewers[msg.sender].addr == msg.sender,
            "Sender is not a registered reviewer."
        );
        // Ensure that the reviewer has enough reputation to withdraw the requested amount
        require(
            reviewers[msg.sender].reputation >= amount,
            "Not enough reputation to withdraw."
        );
        // Subtract the requested amount from the reviewer's reputation
        reviewers[msg.sender].reputation -= amount;
    }

    function assignReviewers() public {
        // Ensure that there are at least two reviewers in the list of reviewers
        require(
            listOfReviewers.length >= 2,
            "At least two reviewers are required for review assignment."
        );

        // Calculate the total reputation staked by all reviewers
        uint256 totalReputationStaked = 0;
        uint256 numReviewers = listOfReviewers.length;
        address[] memory eligibleReviewers = new address[](numReviewers);
        uint256[] memory reputationStaked = new uint256[](numReviewers);
        for (uint256 i = 0; i < listOfReviewers.length; i++) {
            eligibleReviewers[i] = listOfReviewers[i];
            reputationStaked[i] = reviewers[listOfReviewers[i]].reputation;
            totalReputationStaked += reviewers[listOfReviewers[i]].reputation;
        }

        // Ensure that there is enough reputation staked by the reviewers to assign two reviewers
        require(totalReputationStaked > 2, "Not enough reputation staked");

        // Assign two reviewers at random based on their staked reputation
        address[2] memory assigned;
        uint256 numAssignedReviewers = 0;
        while (numAssignedReviewers < 2) {
            uint256 randomValue = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % totalReputationStaked;
            for (uint256 i = 0; i < numReviewers; i++) {
                if (eligibleReviewers[i] != address(0)) {
                    if (randomValue < reputationStaked[i]) {
                        assignedReviewers[
                            numAssignedReviewers
                        ] = eligibleReviewers[i];
                        numAssignedReviewers++;
                        totalReputationStaked -= reputationStaked[i];
                        eligibleReviewers[i] = address(0);
                        break;
                    } else {
                        randomValue -= reputationStaked[i];
                    }
                }
            }
        }

        // Save the assigned reviewers
        assignedReviewers = assigned;
        emit ReviewerAssigned(assignedReviewers[0], assignedReviewers[1]);
    }

    function assignEditor() public {
        require(
            listOfEditors.length >= 1,
            "At least one editor are required for review assignment."
        );

        // Calculate the total reputation staked by all editors
        uint256 totalReputationStaked = 0;
        uint256 numEditors = listOfEditors.length;
        address[] memory eligibleEditors = new address[](numEditors);
        uint256[] memory reputationStaked = new uint256[](numEditors);
        for (uint256 i = 0; i < listOfEditors.length; i++) {
            eligibleEditors[i] = listOfEditors[i];
            reputationStaked[i] = reviewers[listOfEditors[i]].reputation;
            totalReputationStaked += reviewers[listOfEditors[i]].reputation;
        }

        require(totalReputationStaked > 1, "Not enough reputation staked");

        // Assign an editor at random based on their staked reputation
        address assigned;
        uint256 numAssignedEditor = 0;
        while (numAssignedEditor < 1) {
            uint256 randomValue = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % totalReputationStaked;
            for (uint256 i = 0; i < numEditors; i++) {
                if (eligibleEditors[i] != address(0)) {
                    if (randomValue < reputationStaked[i]) {
                        assigned = eligibleEditors[i];
                        numAssignedEditor++;
                        break;
                    } else {
                        randomValue -= reputationStaked[i];
                    }
                }
            }
        }

        // Save the assigned reviewers
        assignedEditor = assigned;
        emit EditorAssigned(assignedEditor);
    }

    function submitReview() public {
        require(reviewed == false, "Manuscript has already been reviewed");
        // Check if the caller is one of the assigned reviewers
        if (
            msg.sender == assignedReviewers[0] ||
            msg.sender == assignedReviewers[1]
        ) {
            // Mark the reviewer as having submitted their review
            reviewers[msg.sender].hasReviewed = true;
            numReviewed += 1;
            // If both assigned reviewers have submitted their reviews, change the manuscript status to "Review Submitted"
            if (numReviewed == 2) {
                status = 2;
                emit ReviewSubmitted();
            }
        } else {
            revert("Only assigned reviewers can complete the review");
        }
    }

    function acceptReview() public {
        require(
            msg.sender == assignedEditor,
            "Only assigned editor can accept the review"
        );
        // Check if both assigned reviewers have submitted their reviews
        require(
            reviewers[assignedReviewers[0]].hasReviewed == true &&
                reviewers[assignedReviewers[1]].hasReviewed == true,
            "Comments not finalized"
        );
        // Change the manuscript status to "Review Accepted"
        status = 3;
        emit ReviewAccepted();
    }

    function rejectReview(string memory _reason) public {
        require(
            msg.sender == assignedEditor,
            "Only assigned editor can accept the review"
        );
        // Check if both assigned reviewers have submitted their reviews
        require(
            reviewers[assignedReviewers[0]].hasReviewed == true &&
                reviewers[assignedReviewers[1]].hasReviewed == true,
            "Comments not finalized"
        );
        // Change the manuscript status to "Review Rejected" and emit a reason for the rejection
        status = 4;
        emit ReviewRejected(_reason);
    }
}
