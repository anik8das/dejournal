pragma solidity ^0.8.0;

contract PeerReview {
    address admin;
    address author;
    string manuscriptLink;
    string manuscriptAbstract;
    address[2] assignedReviewers;
    address assignedEditor;
    uint256 numReviewed;
    uint256 status; /* 
        0: not reviewed
        1: Reviewers Assigned
        2: Editors Assigned
        3: Comments Submitted
        4: Manuscript Accepted
        5: Manuscript Rejected
        6: Peer review approved (admin)
        7: Peer review cancelled (admin) 
    */
    uint256 public balance; // money donated to the peer review

    struct Reviewer {
        address addr;
        uint256 reputation;
        bool hasReviewed;
    }
    struct Editor {
        address addr;
        uint256 reputation;
    }

    mapping(address => Reviewer) public reviewers;
    address[] listOfReviewers; // for looping purposes
    mapping(address => Editor) public editors;
    address[] listOfEditors; // for looping purposes

    event ReviewerAssigned(
        address indexed reviewerAddr1,
        address indexed reviewerAddr2
    );
    event EditorAssigned(address indexed editorAddr);
    event CommentsSubmitted(address indexed reviewerAddr);
    event CommentsSubmitted();
    event ManuscriptAccepted();
    event ManuscriptRejected(string reason);
    event ReviewApproved();
    event ReputationAwarded();
    event ReviewCancelled(string reason);
    event ReputationStripped();

    constructor(
        address _author,
        string memory _manuscriptUrl,
        string memory _manuscriptAbstract
    ) {
        admin = msg.sender;
        author = _author;
        status = 0;
        manuscriptLink = _manuscriptUrl;
        manuscriptAbstract = _manuscriptAbstract;
        numReviewed = 0;
        assignedReviewers = [address(0), address(0)];
        assignedEditor = address(0);
    }

    function isPayable(address testAddress) private returns (bool) {
        return payable(testAddress).send(0);
    }

    function receiveFunds() public payable {
        require(
            status < 6,
            "Thank you for wanting to donate. However, this peer review has already ended."
        );
        balance += msg.value;
    }

    function stakeReputation(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0.");
        require(status == 0, "Manuscript is already under review.");
        if (reviewers[msg.sender].addr == msg.sender) {
            reviewers[msg.sender].reputation += amount;
        } else {
            require(isPayable(msg.sender), "Sender is not a payable address.");
            reviewers[msg.sender] = Reviewer(msg.sender, amount, false);
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
        require(amount > 0, "Amount to be withdrawn must be greater than 0.");
        require(status == 0, "Manuscript is already under review.");
        reviewers[msg.sender].reputation -= amount;
    }

    function assignReviewers() public {
        require(msg.sender == admin, "Only admin can assign reviewers.");
        require(
            listOfReviewers.length >= 2,
            "At least two staked reviewers are required for review assignment."
        );
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
        assignedReviewers = assigned;
        status = 1;
        returnReputationToUnassigned();
        emit ReviewerAssigned(assignedReviewers[0], assignedReviewers[1]);
    }

    function returnReputationToUnassigned() public {
        require(msg.sender == admin, "Only admin can assign reviewers.");
        require(status == 1, "Reviewers have not been assigned yet.");
        for (uint256 i = 0; i < listOfReviewers.length; i++) {
            if (
                listOfReviewers[i] != assignedReviewers[0] &&
                listOfReviewers[i] != assignedReviewers[1]
            ) {
                payable(listOfReviewers[i]).transfer(
                    reviewers[listOfReviewers[i]].reputation
                );
            }
        }
    }

    function assignEditor() public {
        require(msg.sender == admin, "Only admin can assign reviewers.");
        require(
            listOfEditors.length >= 1,
            "At least one staked editor is required for review assignment."
        );
        require(
            assignedReviewers[0] != address(0) &&
                assignedReviewers[1] != address(0),
            "Reviewers must be assigned first."
        );
        uint256 totalReputationStaked = 0;
        uint256 numEditors = listOfEditors.length;
        address[] memory eligibleEditors = new address[](numEditors);
        uint256[] memory reputationStaked = new uint256[](numEditors);
        for (uint256 i = 0; i < listOfEditors.length; i++) {
            eligibleEditors[i] = listOfEditors[i];
            reputationStaked[i] = reviewers[listOfEditors[i]].reputation;
            totalReputationStaked += reviewers[listOfEditors[i]].reputation;
        }

        require(totalReputationStaked > 10, "Not enough reputation staked");

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

        assignedEditor = assigned;
        status = 2;
        emit EditorAssigned(assignedEditor);
    }

    function submitComments() public {
        require(
            status == 3,
            "Editors and Reviewers need to be assigned first."
        );
        require(
            msg.sender == assignedReviewers[0] ||
                msg.sender == assignedReviewers[1],
            "Only assigned reviewers can submit comments"
        );
        require(
            reviewers[msg.sender].hasReviewed == false,
            "Reviewer has already submitted comments"
        );
        reviewers[msg.sender].hasReviewed = true;
        numReviewed += 1;
        if (numReviewed == 2) {
            status = 3;
            emit CommentsSubmitted();
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

        status = 4;
        emit ManuscriptAccepted();
    }

    function rejectReview(string memory _reason) public {
        require(
            msg.sender == assignedEditor,
            "Only assigned editor can reject the review"
        );
        require(
            reviewers[assignedReviewers[0]].hasReviewed == true &&
                reviewers[assignedReviewers[1]].hasReviewed == true,
            "Comments not finalized"
        );
        require(
            bytes(_reason).length >= 50,
            "Reason must be at least 50 characters"
        );

        status = 5;
        emit ManuscriptRejected(_reason);
    }

    function confirmReview() public {
        require(msg.sender == admin, "Only admin can confirm the review");
        require(
            status == 4 || status == 5,
            "Manuscript not accepted or rejected"
        );
        status = 6;
        awardReputation();
        emit ReviewApproved();
    }

    function awardReputation() private {
        // transfer reputation to the assigned reviewers
        payable(assignedReviewers[0]).transfer(
            reviewers[assignedReviewers[0]].reputation
        );
        payable(assignedReviewers[1]).transfer(
            reviewers[assignedReviewers[1]].reputation
        );
        // transfer reputation to the assigned editor
        payable(assignedEditor).transfer(reviewers[assignedEditor].reputation);
        // pay 80% of the balance to the assigned reviewers based on their reputation staked
        uint256 totalReputationStaked = reviewers[assignedReviewers[0]]
            .reputation + reviewers[assignedReviewers[1]].reputation;
        uint256 reputationToBeAwarded = uint256((balance * 80) / 100);
        payable(assignedReviewers[0]).transfer(
            (reviewers[assignedReviewers[0]].reputation /
                totalReputationStaked) * reputationToBeAwarded
        );
        payable(assignedReviewers[1]).transfer(
            (reviewers[assignedReviewers[1]].reputation /
                totalReputationStaked) * reputationToBeAwarded
        );
        // pay 20% of the balance to the assigned editor
        payable(assignedEditor).transfer(uint256((balance * 20) / 100));
        balance = 0;
        reviewers[assignedReviewers[0]].reputation = 0;
        reviewers[assignedReviewers[1]].reputation = 0;
        editors[assignedEditor].reputation = 0;
        emit ReputationAwarded();
    }

    function stripReputation() private {
        payable(admin).transfer(
            reviewers[assignedReviewers[0]].reputation +
                reviewers[assignedReviewers[1]].reputation +
                editors[assignedEditor].reputation
        );
        reviewers[assignedReviewers[0]].reputation = 0;
        reviewers[assignedReviewers[1]].reputation = 0;
        editors[assignedEditor].reputation = 0;
        // send balance back to author
        payable(author).transfer(balance);
        emit ReputationStripped();
    }

    function cancelReview(string memory _reason) public {
        require(msg.sender == admin, "Only admin can cancel the review");
        require(
            status == 4 || status == 5,
            "Manuscript not accepted or rejected"
        );
        require(
            bytes(_reason).length >= 50,
            "Reason must be at least 50 characters"
        );
        status = 7;
        stripReputation();
        emit ReviewCancelled(_reason);
    }
}
