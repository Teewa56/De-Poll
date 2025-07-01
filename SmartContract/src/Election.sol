// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface INotifications {
    function VoteNotification(address _voter, string memory _votedFor, uint256 _electionId) external;
    function NotifyVoteCreator(address _creator, address _voter, string memory _votedFor, uint256 _electionId) external;
}

interface IPayment {
    function payForVoteCreation(address _senderAddress) external;
    function payForVoting(address _voterAddress, address _voteCreator) external;
}

interface IUserContract {
    function AddUserElection(address _userAddress, uint _electionId, string memory _electionName) external;
    function AddUserParticipatingElections(address _userAddress, uint _electionId, string memory _electionName) external;
}

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
        mapping(address => uint) earnedPoints; // Points earned by voters
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
    uint[] public topElections;

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
        require(!elections[_electionId].ongoing, "Election ID already exists");

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
            election.earnedPoints[_allowedVoters[i]] = 0; // Initialize points
        }

        ongoingElections.push(_electionId);
        IUserContract(userContract).AddUserElection(msg.sender, _electionId, _electionName);
    }

    function vote(uint _electionId, string memory _candidateName) external payable{
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

        INotifications(notificationContract).VoteNotification(msg.sender, _candidateName, _electionId);
        INotifications(notificationContract).NotifyVoteCreator(election.creator, msg.sender, _candidateName, _electionId);

        // Reward voter with points
        election.earnedPoints[msg.sender] += 10;
        rewardsToken.transfer(msg.sender, 10 * (10 ** rewardsToken.decimals())); // Distribute token rewards
    }

    function getUserPoints(uint _electionId, address _user) external view returns (uint) {
        return elections[_electionId].earnedPoints[_user];
    }

    function closeElection(uint _electionId) external {
        ElectionData storage election = elections[_electionId];
        require(msg.sender == election.creator, "Only the election creator can close the election");
        require(block.timestamp >= election.closeTime, "Election is still ongoing");

        election.ongoing = false;
        closedElections.push(_electionId);
    }

    function removeClosedPolls() external {
        for (uint i = 0; i < closedElections.length; i++) {
            if (elections[closedElections[i]].closeTime + 24 * 60 * 60 < block.timestamp) {
                closedElections[i] = closedElections[closedElections.length - 1];
                closedElections.pop();
            }
        }
    }

    function getCandidates(uint _electionId) external view returns (string[] memory) {
        return elections[_electionId].candidatesName;
    }

    function getVotesForCandidate(uint _electionId, string memory _candidateName) external view returns (uint) {
        return elections[_electionId].votes[_candidateName];
    }

    function getTopElections() external view returns (uint[] memory) {
        uint maxVotes = 0;
        for (uint i = 0; i < closedElections.length; i++) {
            uint highestVotes = 0;
            for (uint j = 0; j < elections[closedElections[i]].candidatesName.length; j++) {
                string memory candidateName = elections[closedElections[i]].candidatesName[j];
                if (elections[closedElections[i]].votes[candidateName] > highestVotes) {
                    highestVotes = elections[closedElections[i]].votes[candidateName];
                }
            }
            if (highestVotes > maxVotes) {
                maxVotes = highestVotes;
                topElections.push(closedElections[i]);
            }
        }
        return topElections;
    }
}
