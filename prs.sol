pragma solidity ^0.8.0;

contract PeerReview {
    // Define state variables
    address author;
    string manuscriptLink;
    string manuscriptAbstract;
    bool reviewed;
    address[] assignedReviewers;
    address assignedEditor;
    uint256 numReviewed = 0;
    uint256 status; // 0: submitted, 1: under review, 2: review completed, 3: accepted, 4: rejected

    // Define the Reviewer struct
    struct Reviewer {
        address addr;
        uint256 reputation;
        bool isAssigned;
        bool hasReviewed;
    }

    // Define the Editor struct
    struct Editor {
        address addr;
        uint256 reputation;
        bool isAssigned;
        bool isAccepted;
    }

    // Define the mapping for reviewers
    mapping(address => Reviewer) public reviewers;
    address[] listOfReviewers;

    // Define the mapping for editors
    mapping(address => Editor) public editors;
    address[] listOfEditors;

    // Define events
    event ReviewerAssigned(
        address indexed reviewerAddr1,
        address indexed reviewerAddr2
    );
    event EditorAssigned(address indexed editorAddr);
    event ReviewSubmitted();
    event ReviewAccepted();
    event ReviewRejected(string reason);

    // Define functions for author, reviewer, and editor actions

    function submitManuscript(string memory _manuscriptUrl) public {
        author = msg.sender;
        manuscriptLink = _manuscriptUrl;
        status = 0;
        reviewed = false;
    }

    function stakeReputation(uint256 amount) public payable {
        // check if the reviewer is in the reviewers list or else add them
        if (reviewers[msg.sender].addr == msg.sender) {
            reviewers[msg.sender].reputation += amount;
        } else {
            reviewers[msg.sender] = Reviewer(msg.sender, amount, false, false);
            listOfReviewers.push(msg.sender);
        }
    }

    function withdrawReputation(uint256 amount) public {
        require(
            reviewers[msg.sender].addr == msg.sender,
            "Sender is not a registered reviewer."
        );
        require(
            reviewers[msg.sender].reputation >= amount,
            "Not enough reputation to withdraw."
        );
        reviewers[msg.sender].reputation -= amount;
    }

    function assignReviewers() public {
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

        // Emit an event
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

        // Emit an event
        emit EditorAssigned(assignedEditor);
    }

    function submitReview() public {
        require(reviewed == false, "Manuscript has already been reviewed");
        if (
            msg.sender == assignedReviewers[0] ||
            msg.sender == assignedReviewers[1]
        ) {
            reviewers[msg.sender].hasReviewed = true;
            numReviewed += 1;
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
        require(
            reviewers[assignedReviewers[0]].hasReviewed == true &&
                reviewers[assignedReviewers[1]].hasReviewed == true,
            "Comments not finalized"
        );
        status = 3;
        emit ReviewAccepted();
    }

    function rejectReview(string memory _reason) public {
        require(
            msg.sender == assignedEditor,
            "Only assigned editor can accept the review"
        );
        require(
            reviewers[assignedReviewers[0]].hasReviewed == true &&
                reviewers[assignedReviewers[1]].hasReviewed == true,
            "Comments not finalized"
        );
        status = 4;
        emit ReviewRejected(_reason);
    }
}
