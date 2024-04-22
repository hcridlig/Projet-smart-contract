pragma solidity ^0.4.12;

import "./Ownable.sol";
import "./Whitelist.sol";

contract Election is Ownable, Whitelist {
    // Structure pour représenter une résolution
    struct Resolution {
        string title;
        uint votesFor;
        uint votesAgainst;
        uint votesNeutral;
        bool passed;
        mapping(address => bool) hasVoted;
    }

    // Structure pour représenter une assemblée générale
    struct GeneralMeeting {
        uint year;
        address president;
        address scrutineer;
        address secretary;
        mapping(uint => Resolution) resolutions;
        uint resolutionCount;
    }

    // Tableau d'assemblées générales
    GeneralMeeting[] public generalMeetings;

    // Événement pour signaler un nouveau vote
    event Voted(address indexed voter, uint indexed meetingId, uint indexed resolutionId, string vote);

    // Fonction pour ajouter une résolution à une assemblée générale spécifique
    function addResolution(uint _meetingId, string memory _title) public onlyOwner {
        require(_meetingId < generalMeetings.length, "Invalid meeting ID");
        GeneralMeeting storage meeting = generalMeetings[_meetingId];
        meeting.resolutions[meeting.resolutionCount] = Resolution(_title, 0, 0, 0, false);
        meeting.resolutionCount++;
    }

    // Fonction pour voter sur une résolution d'une assemblée générale spécifique
    function vote(uint _meetingId, uint _resolutionId, uint _vote) public {
        require(isWhitelisted(msg.sender), "You are not authorized to vote");
        require(_meetingId < generalMeetings.length, "Invalid meeting ID");
        GeneralMeeting storage meeting = generalMeetings[_meetingId];
        require(_resolutionId < meeting.resolutionCount, "Invalid resolution ID");
        require(_vote >= 1 && _vote <= 3, "Invalid vote");
        require(!meeting.resolutions[_resolutionId].hasVoted[msg.sender], "You have already voted for this resolution");

        Resolution storage resolution = meeting.resolutions[_resolutionId];

        if (_vote == 1) {
            resolution.votesFor++;
        } else if (_vote == 2) {
            resolution.votesAgainst++;
        } else {
            resolution.votesNeutral++;
        }

        // Enregistrer que l'électeur a voté pour cette résolution
        resolution.hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _meetingId, _resolutionId, _vote == 1 ? "FOR" : (_vote == 2 ? "AGAINST" : "NEUTRAL"));
    }

    // Fonction pour créer une nouvelle assemblée générale pour une année donnée
    function createGeneralMeeting(uint _year, address _president, address _scrutineer, address _secretary) public onlyOwner {
        GeneralMeeting memory newMeeting;
        newMeeting.year = _year;
        newMeeting.president = _president;
        newMeeting.scrutineer = _scrutineer;
        newMeeting.secretary = _secretary;
        generalMeetings.push(newMeeting);
    }

    // Fonction pour récupérer le nombre total de résolutions à voter pour une assemblée générale donnée
    function getTotalResolutions(uint _meetingId) public view returns (uint) {
        require(_meetingId < generalMeetings.length, "Invalid meeting ID");
        return generalMeetings[_meetingId].resolutionCount;
    }

    // Fonction pour récupérer le titre de chaque résolution à voter pour une assemblée générale donnée
    function getResolutionTitle(uint _meetingId, uint _resolutionId) public view returns (string memory) {
        require(_meetingId < generalMeetings.length, "Invalid meeting ID");
        require(_resolutionId < generalMeetings[_meetingId].resolutionCount, "Invalid resolution ID");
        return generalMeetings[_meetingId].resolutions[_resolutionId].title;
    }

// Fonction pour récupérer les identifiants de chaque résolution pour une année donnée
function getResolutionIdsForYear(uint _year) public view returns (uint[] memory) {
    uint count = 0;
    // Comptons d'abord combien de résolutions existent pour cette année
    for (uint i = 0; i < generalMeetings.length; i++) {
        if (generalMeetings[i].year == _year) {
            count += generalMeetings[i].resolutionCount;
        }
    }

    // Initialisons le tableau avec la bonne taille maintenant que nous connaissons le nombre total de résolutions
    uint[] memory resolutionIds = new uint[](count);
    uint currentIndex = 0;
    // Maintenant, parcourons à nouveau pour collecter les identifiants
    for (uint j = 0; j < generalMeetings.length; j++) {
        if (generalMeetings[j].year == _year) {
            uint resolutionCount = generalMeetings[j].resolutionCount;
            for (uint k = 0; k < resolutionCount; k++) {
                resolutionIds[currentIndex] = k;
                currentIndex++;
            }
        }
    }
    return resolutionIds;
}

function countVotesForResolution(uint _meetingId, uint _resolutionId) public view returns (uint, uint, uint) {
    require(_meetingId < generalMeetings.length, "Invalid meeting ID");
    GeneralMeeting storage meeting = generalMeetings[_meetingId];
    require(_resolutionId < meeting.resolutionCount, "Invalid resolution ID");

    Resolution storage resolution = meeting.resolutions[_resolutionId];
    return (resolution.votesFor, resolution.votesAgainst, resolution.votesNeutral);
}



}
