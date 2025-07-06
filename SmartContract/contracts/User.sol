// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IPayment {
    function signUpGift(address _receiverAddress) external;
}

interface INotifications {
    function voteNotification(address user, uint256 electionId) external;
    function notifyVoteCreator(address creator, uint256 electionId) external;
    function notifyUserForElection(address user, uint256 electionId, string calldata _electionName) external;
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
        uint256 electionsCount;
        uint256 participatingElectionsCount;
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
        newUser.electionsCount = 0;
        newUser.participatingElectionsCount = 0;

        registeredUsers.push(_walletAddress);

        IPayment(paymentContractAddress).signUpGift(_walletAddress);
    }

    function getAllUsers() external view returns (address[] memory) {
        return registeredUsers;
    }

    function addUserElection(address _userAddress, uint256 _electionId, string memory _electionName) external {
        users[_userAddress].elections[users[_userAddress].electionsCount] = Elections(_electionId, _electionName);
        users[_userAddress].electionsCount++;
    }

    function addUserParticipatingElections(address _userAddress, uint256 _electionId, string memory _electionName) external {
        users[_userAddress].participatingElections[users[_userAddress].participatingElectionsCount] = Elections(_electionId, _electionName);
        users[_userAddress].participatingElectionsCount++;
        INotifications(notificationContractAddress).notifyUserForElection(_userAddress, _electionId, _electionName);
    }

    function getUserElections(address _userAddress) external view returns (Elections[] memory) {
        uint256 count = users[_userAddress].electionsCount;
        Elections[] memory userElections = new Elections[](count);
        for (uint256 i = 0; i < count; i++) {
            userElections[i] = users[_userAddress].elections[i];
        }
        return userElections;
    }

    function getUserParticipatingElections(address _userAddress) external view returns (Elections[] memory) {
        uint256 count = users[_userAddress].participatingElectionsCount;
        Elections[] memory userParticipatingElections = new Elections[](count);
        for (uint256 i = 0; i < count; i++) {
            userParticipatingElections[i] = users[_userAddress].participatingElections[i];
        }
        return userParticipatingElections;
    }
}