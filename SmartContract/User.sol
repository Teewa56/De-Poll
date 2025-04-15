// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IPayment {
    function signUpGift(address _receiverAddress) external;
}

interface INotifications {
    function NotifyUserForElection(address _voter, uint256 _electionId, string memory _electionName) external;
}

contract UserContract {
    struct Elections {
        uint256 electionId;
        string electionName;
    }

    struct User {
        string userName;
        address walletAddress;
        string profilePicture;
        uint256 balance;
        mapping(uint256 => Elections) elections;
        mapping(uint256 => Elections) participatingElections;
    }

    mapping(address => User) private users;
    address[] public registeredUsers;

    address public immutable paymentContractAddress;
    address public immutable notificationContractAddress;

    constructor(address _paymentContract, address _notificationContract) {
        paymentContractAddress = _paymentContract;
        notificationContractAddress = _notificationContract;
    }

    function signIn(
        string memory _userName,
        address _walletAddress,
        string memory _profilePic,
        uint256 _balance
    ) public {
        require(users[_walletAddress].walletAddress == address(0), "User already registered");

        User storage newUser = users[_walletAddress];
        newUser.userName = _userName;
        newUser.walletAddress = _walletAddress;
        newUser.profilePicture = _profilePic;
        newUser.balance = _balance;

        registeredUsers.push(_walletAddress);

        IPayment(paymentContractAddress).signUpGift(_walletAddress);
    }

    function getAllUsers() external view returns (address[] memory) {
        return registeredUsers;
    }

    function addUserElection(address _userAddress, uint256 _electionId, string memory _electionName) external {
        users[_userAddress].elections[_electionId] = Elections(_electionId, _electionName);
    }

    function addUserParticipatingElections(address _userAddress, uint256 _electionId, string memory _electionName) external {
        users[_userAddress].participatingElections[_electionId] = Elections(_electionId, _electionName);
        INotifications(notificationContractAddress).NotifyUserForElection(_userAddress, _electionId, _electionName);
    }
}
