// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./manuscript.sol";

contract Journal {
    address public admin; // owner of journal, also has all rights for the peer review process. Would be an array in future iterations
    string public name; // name of the journal
    Manuscript[] manuscripts; // array of manuscripts submitted to the journal, used for the peer review process

    struct Author {
        address addr;
        string name;
        string bio;
    }
    struct Papers {
        Author author;
        string title;
        string url;
        string summary;
    }

    mapping(address => Author) public authors;
    Papers[] public papers; // published papers publicly available

    event authorRegistered(
        address indexed addr,
        string indexed name,
        string indexed bio
    );
    event ManuscriptSubmitted(
        uint256 indexed index, // index of the manuscript in the manuscripts array
        address indexed author,
        string indexed manuscriptTitle
    );
    event ManuscriptPublished(
        uint256 indexed index, // index of the published paper in the papers array
        address indexed author,
        string indexed manuscriptTitle
    );

    constructor(string memory _name) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        admin = msg.sender;
        name = _name;
    }

    function registerAsAuthor(string memory bio, string memory _name) public {
        require(
            authors[msg.sender].addr == address(0),
            "You are already registered"
        );
        require(msg.sender != admin, "Admin cannot be an author");
        authors[msg.sender] = Author(msg.sender, _name, bio);
        emit authorRegistered(msg.sender, _name, bio);
    }

    function submitManuscript(
        string memory manuscriptTitle,
        string memory manuscriptUrl,
        string memory manuscriptAbstract
    ) public {
        require(
            authors[msg.sender].addr != address(0),
            "You must be registered as an author to submit a manuscript"
        );
        Manuscript manuscript = new Manuscript(
            admin,
            msg.sender,
            manuscriptTitle,
            manuscriptUrl,
            manuscriptAbstract
        );
        manuscripts.push(manuscript);
        emit ManuscriptSubmitted(
            manuscripts.length - 1,
            msg.sender,
            manuscriptTitle
        );
    }

    function getManuscriptObject(
        uint256 index
    ) public view returns (Manuscript) {
        require(index < manuscripts.length, "Invalid index");
        return manuscripts[index];
    }

    function publishPaper(
        address author,
        string memory title,
        string memory url,
        string memory summary
    ) public {
        require(
            msg.sender == admin,
            "Only admin can access peer review functionalities"
        );
        papers.push(Papers(authors[author], title, url, summary));
        emit ManuscriptPublished(papers.length - 1, author, title);
    }
}
