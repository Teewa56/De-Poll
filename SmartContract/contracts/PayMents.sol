// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface INotifications {
    function PaymentReceived(address _sender, address _receiver, uint256 _amount) external;
    function PaymentSent(address _sender, address _receiver, uint256 _amount) external;
}

contract Payments is Ownable {
    ERC20 public rewardsToken;
    uint256 public signupBonus = 50;
    uint256 public voteCreationFee = 10;
    uint256 public votingFee = 3;

    mapping(address => bool) public hasSignedUp;
    mapping(address => uint256) public earnedPoints;
    address public notificationContract;

    constructor(address _tokenAddress, address _notificationContract, address _owner) Ownable(_owner) {
        rewardsToken = ERC20(_tokenAddress);
        notificationContract = _notificationContract;
    }

    function signUpGift(address _receiverAddress) external {
        require(!hasSignedUp[_receiverAddress], "User already received signup bonus");
        require(rewardsToken.balanceOf(address(this)) >= signupBonus * (10 ** rewardsToken.decimals()), "Insufficient contract balance");
        rewardsToken.transfer(_receiverAddress, signupBonus * (10 ** rewardsToken.decimals()));
        hasSignedUp[_receiverAddress] = true;
        earnedPoints[_receiverAddress] += signupBonus;
        INotifications(notificationContract).paymentReceived(address(this), _receiverAddress, signupBonus);
    }

    function payForVoteCreation(address _senderAddress) external {
        require(rewardsToken.balanceOf(_senderAddress) >= voteCreationFee * (10 ** rewardsToken.decimals()), "Insufficient funds");
        rewardsToken.transferFrom(_senderAddress, owner(), voteCreationFee * (10 ** rewardsToken.decimals()));
        earnedPoints[_senderAddress] += 5;

        INotifications(notificationContract).paymentSent(_senderAddress, owner(), voteCreationFee);
    }

    function payForVoting(address _voterAddress, address _voteCreator) external {
        require(rewardsToken.balanceOf(_voterAddress) >= votingFee * (10 ** rewardsToken.decimals()), "Insufficient funds");
        rewardsToken.transferFrom(_voterAddress, _voteCreator, votingFee * (10 ** rewardsToken.decimals()));
        earnedPoints[_voterAddress] += 10;

        INotifications(notificationContract).paymentSent(_voterAddress, _voteCreator, votingFee);
        INotifications(notificationContract).paymentReceived(_voteCreator, _voterAddress, votingFee);
    }

    function setSignupBonus(uint256 _newBonus) external onlyOwner {
        signupBonus = _newBonus;
    }

    function setVoteCreationFee(uint256 _newFee) external onlyOwner {
        voteCreationFee = _newFee;
    }

    function setVotingFee(uint256 _newFee) external onlyOwner {
        votingFee = _newFee;
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(rewardsToken.balanceOf(address(this)) >= _amount, "Insufficient contract balance");
        rewardsToken.transfer(owner(), _amount);
    }
}