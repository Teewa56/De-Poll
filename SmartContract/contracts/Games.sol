// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

interface INotification {
    function notifyGameWin(address _player, uint256 _pointsEarned) external;
}

contract GameContract is Ownable {
    struct Game {
        uint gameId;
        uint highScore;
        address[] gamers;
        address[] topPlayers;
        uint gamersCount;
        uint topPlayersCount;
        mapping(address => uint) scores;
        mapping(address => uint) earnedPoints;
    }

    mapping(uint => Game) public games;
    mapping(address => uint[]) public userGames;
    mapping(address => bool) public isOnline;
    address[] public onlinePlayers;

    address public notificationContractAddress;

    event GameStarted(uint gameId, address indexed gamer);
    event GameEnded(uint gameId, address indexed gamer, uint finalScore);
    event PlayerOnline(address indexed gamer);
    event PlayerOffline(address indexed gamer);

    constructor(address _owner, address _notificationContractAddress) Ownable(_owner) {
        games[_hash("cashflow")].gameId = _hash("cashflow");
        games[_hash("inj/dead")].gameId = _hash("inj/dead");
        games[_hash("satoshi")].gameId = _hash("satoshi");
        notificationContractAddress = _notificationContractAddress;
    }

    function _hash(string memory _gameName) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(_gameName)));
    }

    function startGame(uint _gameId) external {
        require(games[_gameId].gameId != 0, "Game does not exist");
        require(games[_gameId].scores[msg.sender] == 0, "You have already started this game");

        games[_gameId].gamers.push(msg.sender);
        games[_gameId].gamersCount++;
        games[_gameId].scores[msg.sender] = 0;
        userGames[msg.sender].push(_gameId);
        emit GameStarted(_gameId, msg.sender);
    }

    function endGame(uint _gameId, address _winnerAddress, uint256 _pointsEarned, bool _isWinner) external {
        require(games[_gameId].gameId != 0, "Game does not exist");
        require(games[_gameId].scores[_winnerAddress] >= 0, "Player has not played this game");

        games[_gameId].earnedPoints[_winnerAddress] += _pointsEarned;
        games[_gameId].scores[_winnerAddress] += _pointsEarned;

        if (games[_gameId].scores[_winnerAddress] > games[_gameId].highScore) {
            games[_gameId].highScore = games[_gameId].scores[_winnerAddress];
            // Clear previous top players and add new one
            delete games[_gameId].topPlayers;
            games[_gameId].topPlayersCount = 0;
            games[_gameId].topPlayers.push(_winnerAddress);
            games[_gameId].topPlayersCount++;
        } else if (games[_gameId].scores[_winnerAddress] == games[_gameId].highScore && games[_gameId].highScore > 0) {
            games[_gameId].topPlayers.push(_winnerAddress);
            games[_gameId].topPlayersCount++;
        }

        emit GameEnded(_gameId, _winnerAddress, games[_gameId].scores[_winnerAddress]);

        if (_isWinner) {
            INotification(notificationContractAddress).notifyGameWin(_winnerAddress, _pointsEarned);
        }
    }

    function getTopPlayers(uint _gameId) external view returns (address[] memory) {
        uint count = games[_gameId].topPlayersCount;
        address[] memory topPlayers = new address[](count);
        for (uint i = 0; i < count; i++) {
            topPlayers[i] = games[_gameId].topPlayers[i];
        }
        return topPlayers;
    }

    function goOnline() external {
        if (!isOnline[msg.sender]) {
            isOnline[msg.sender] = true;
            onlinePlayers.push(msg.sender);
            emit PlayerOnline(msg.sender);
        }
    }

    function goOffline() external {
        if (isOnline[msg.sender]) {
            isOnline[msg.sender] = false;
            // Remove from online players array
            for (uint i = 0; i < onlinePlayers.length; i++) {
                if (onlinePlayers[i] == msg.sender) {
                    onlinePlayers[i] = onlinePlayers[onlinePlayers.length - 1];
                    onlinePlayers.pop();
                    break;
                }
            }
            emit PlayerOffline(msg.sender);
        }
    }

    function getOnlinePlayers(uint _gameId) external view returns (address[] memory) {
        uint count = 0;
        for (uint i = 0; i < games[_gameId].gamersCount; i++) {
            if (isOnline[games[_gameId].gamers[i]]) {
                count++;
            }
        }
        address[] memory onlineList = new address[](count);
        uint index = 0;
        for (uint i = 0; i < games[_gameId].gamersCount; i++) {
            if (isOnline[games[_gameId].gamers[i]]) {
                onlineList[index] = games[_gameId].gamers[i];
                index++;
            }
        }
        return onlineList;
    }

    function getAllOnlinePlayers() external view returns (address[] memory) {
        return onlinePlayers;
    }

    function getUserPoints(uint _gameId, address _user) external view returns (uint) {
        return games[_gameId].earnedPoints[_user];
    }

    function getUserGames(address _user) external view returns (uint[] memory) {
        return userGames[_user];
    }
}