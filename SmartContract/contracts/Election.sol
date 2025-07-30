// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface INotifications {
    function voteNotification(address _voter, string memory _votedFor, uint256 _electionId) external;
    function notifyVoteCreator(address _creator, address _voter, string memory _votedFor, uint256 _electionId) external;
    function paymentReceived(address _sender, address _receiver, uint256 _amount) external;
    function paymentSent(address _sender, address _receiver, uint256 _amount) external;
    function notifyUserForElection(address _voter, uint256 _electionId, string memory _electionName) external;
    function notifyGameWin(address _player, uint256 _pointsEarned) external;
}

interface IPayment {
    function payForVoteCreation(address _senderAddress) external;
    function payForVoting(address _voterAddress, address _voteCreator) external;
    function signUpGift(address _receiverAddress) external;
}

interface IUserContract {
    function addUserElection(address _userAddress, uint _electionId, string memory _electionName) external;
    function addUserParticipatingElections(address _userAddress, uint _electionId, string memory _electionName) external;
}

// =======================
// ELECTION CONTRACT
// =======================
contract Election {
    ERC20 public rewardsToken;

    struct ElectionData {
        string electionName;
        string[] candidatesName;
        address creator;
        bool ongoing;
        uint closeTime;
        mapping(string => uint) votes;
        mapping(address => bool) allowedVoters;
        mapping(address => uint) earnedPoints;
    }

    struct Voter {
        bool hasVoted;
        string votedFor;
    }

    mapping(uint => ElectionData) public elections;
    mapping(address => mapping(uint => Voter)) public voters;
    mapping(address => bool) public allowedVoteCreators;
    uint[] public ongoingElections;
    uint[] public closedElections;
    uint[] public topElections; // This can be removed if using Solution 2

    address public immutable notificationContract;
    address public immutable paymentContract;
    address public immutable userContract;

    constructor(address _notificationContract, address _paymentContract, address _userContract, address _rewardsToken) {
        notificationContract = _notificationContract;
        paymentContract = _paymentContract;
        userContract = _userContract;
        rewardsToken = ERC20(_rewardsToken);
    }

    modifier AllowedVoteCreators() {
        require(allowedVoteCreators[msg.sender], "You are not allowed to create elections.");
        _;
    }

    function registerAsVoteCreator() external {
        IPayment(paymentContract).payForVoteCreation(msg.sender);
        allowedVoteCreators[msg.sender] = true;
    }

    function createElection(
        uint _electionId,
        string memory _electionName,
        string[] memory _candidateNames,
        address[] memory _allowedVoters,
        uint _closeTime
    ) external AllowedVoteCreators {
        require(!elections[_electionId].ongoing && bytes(elections[_electionId].electionName).length == 0, "Election ID already exists");
        require(_closeTime > block.timestamp, "Close time must be in the future");

        ElectionData storage election = elections[_electionId];
        election.electionName = _electionName;
        election.creator = msg.sender;
        election.ongoing = true;
        election.closeTime = _closeTime;

        for (uint i = 0; i < _candidateNames.length; i++) {
            election.candidatesName.push(_candidateNames[i]);
        }

        for (uint i = 0; i < _allowedVoters.length; i++) {
            election.allowedVoters[_allowedVoters[i]] = true;
            election.earnedPoints[_allowedVoters[i]] = 0;
        }

        ongoingElections.push(_electionId);
        IUserContract(userContract).addUserElection(msg.sender, _electionId, _electionName);
    }

    function vote(uint _electionId, string memory _candidateName) external {
        ElectionData storage election = elections[_electionId];
        Voter storage voter = voters[msg.sender][_electionId];

        require(election.ongoing, "Election has already been closed.");
        require(!voter.hasVoted, "You have already voted.");
        require(election.allowedVoters[msg.sender], "You are not an allowed voter.");

        IPayment(paymentContract).payForVoting(msg.sender, election.creator);

        bool validCandidate = false;
        for (uint i = 0; i < election.candidatesName.length; i++) {
            if (keccak256(abi.encodePacked(election.candidatesName[i])) == keccak256(abi.encodePacked(_candidateName))) {
                validCandidate = true;
                break;
            }
        }
        require(validCandidate, "Invalid candidate.");

        election.votes[_candidateName]++;
        voter.hasVoted = true;
        voter.votedFor = _candidateName;

        INotifications(notificationContract).voteNotification(msg.sender, _candidateName, _electionId);
        INotifications(notificationContract).notifyVoteCreator(election.creator, msg.sender, _candidateName, _electionId);

        election.earnedPoints[msg.sender] += 10;
        rewardsToken.transfer(msg.sender, 10 * (10 ** rewardsToken.decimals()));
    }

    function getUserPoints(uint _electionId, address _user) external view returns (uint) {
        return elections[_electionId].earnedPoints[_user];
    }

    function closeElection(uint _electionId) external {
        ElectionData storage election = elections[_electionId];
        require(msg.sender == election.creator, "Only the election creator can close the election");
        require(block.timestamp >= election.closeTime, "Election is still ongoing");

        election.ongoing = false;
        
        for (uint i = 0; i < ongoingElections.length; i++) {
            if (ongoingElections[i] == _electionId) {
                ongoingElections[i] = ongoingElections[ongoingElections.length - 1];
                ongoingElections.pop();
                break;
            }
        }
        
        closedElections.push(_electionId);
    }

    function removeClosedPolls() external {
        for (uint i = 0; i < closedElections.length; i++) {
            if (elections[closedElections[i]].closeTime + 24 * 60 * 60 < block.timestamp) {
                closedElections[i] = closedElections[closedElections.length - 1];
                closedElections.pop();
                i--; 
            }
        }
    }

    function getCandidates(uint _electionId) external view returns (string[] memory) {
        return elections[_electionId].candidatesName;
    }

    function getVotesForCandidate(uint _electionId, string memory _candidateName) external view returns (uint) {
        return elections[_electionId].votes[_candidateName];
    }

    // Solution 2: Keep as 'view' and calculate dynamically without modifying state
    function getTopElections() external view returns (uint[] memory) {
        // Create a temporary array to hold results
        uint[] memory tempTopElections = new uint[](closedElections.length);
        uint topCount = 0;
        
        uint maxVotes = 0;
        
        // First pass: find the maximum vote count across all elections
        for (uint i = 0; i < closedElections.length; i++) {
            uint highestVotesInElection = 0;
            for (uint j = 0; j < elections[closedElections[i]].candidatesName.length; j++) {
                string memory candidateName = elections[closedElections[i]].candidatesName[j];
                uint candidateVotes = elections[closedElections[i]].votes[candidateName];
                if (candidateVotes > highestVotesInElection) {
                    highestVotesInElection = candidateVotes;
                }
            }
            if (highestVotesInElection > maxVotes) {
                maxVotes = highestVotesInElection;
            }
        }
        
        // Second pass: collect elections with the maximum vote count
        for (uint i = 0; i < closedElections.length; i++) {
            uint highestVotesInElection = 0;
            for (uint j = 0; j < elections[closedElections[i]].candidatesName.length; j++) {
                string memory candidateName = elections[closedElections[i]].candidatesName[j];
                uint candidateVotes = elections[closedElections[i]].votes[candidateName];
                if (candidateVotes > highestVotesInElection) {
                    highestVotesInElection = candidateVotes;
                }
            }
            if (highestVotesInElection == maxVotes) {
                tempTopElections[topCount] = closedElections[i];
                topCount++;
            }
        }
        
        // Create final array with correct size
        uint[] memory result = new uint[](topCount);
        for (uint i = 0; i < topCount; i++) {
            result[i] = tempTopElections[i];
        }
        
        return result;
    }
}