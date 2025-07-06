// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Notifications {
    event VoteNotification(address indexed voter, string indexed votedFor, uint256 electionId, uint256 timestamp);
    event ElectionVote(address indexed creator, address indexed voter, string indexed votedFor, uint256 electionId, uint256 timestamp);
    event PaymentReceived(address indexed sender, address indexed receiver, uint256 amount, uint256 timestamp);
    event PaymentSent(address indexed sender, address indexed receiver, uint256 amount, uint256 timestamp);
    event NotifyUserForElection(address indexed voter, uint256 electionId, string electionName, uint256 timestamp);
    event GameWinNotification(address indexed player, uint256 pointsEarned, uint256 timestamp);

    function voteNotification(address _voter, string memory _votedFor, uint256 _electionId) external {
        emit VoteNotification(_voter, _votedFor, _electionId, block.timestamp);
    }

    function notifyVoteCreator(address _creator, address _voter, string memory _votedFor, uint256 _electionId) external {
        emit ElectionVote(_creator, _voter, _votedFor, _electionId, block.timestamp);
    }

    function paymentReceived(address _sender, address _receiver, uint256 _amount) external {
        emit PaymentReceived(_sender, _receiver, _amount, block.timestamp);
    }

    function paymentSent(address _sender, address _receiver, uint256 _amount) external {
        emit PaymentSent(_sender, _receiver, _amount, block.timestamp);
    }

    function notifyUserForElection(address _voter, uint256 _electionId, string memory _electionName) external {
        emit NotifyUserForElection(_voter, _electionId, _electionName, block.timestamp);
    }

    function notifyGameWin(address _player, uint256 _pointsEarned) external {
        emit GameWinNotification(_player, _pointsEarned, block.timestamp);
    }
}