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
        address[] onlinePlayers;
        mapping(address => uint) scores;
        mapping(address => uint) earnedPoints;
    }

    mapping(uint => Game) public games;
    mapping(address => uint[]) public userGames;
    mapping(address => bool) public isOnline;

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
        games[_gameId].scores[msg.sender] = 0;
        emit GameStarted(_gameId, msg.sender);
    }

    function endGame(uint _gameId, address _winnerAddress, uint256 _pointsEarned, bool _isWinner) external {
        require(games[_gameId].gameId != 0, "Game does not exist");
        require(games[_gameId].scores[_winnerAddress] >= 0, "Player has not played this game");

        games[_gameId].earnedPoints[_winnerAddress] += _pointsEarned;
        games[_gameId].scores[_winnerAddress] += _pointsEarned;

        if (games[_gameId].scores[_winnerAddress] > games[_gameId].highScore) {
            games[_gameId].highScore = games[_gameId].scores[_winnerAddress];
        }

        if (games[_gameId].scores[_winnerAddress] == games[_gameId].highScore) {
            games[_gameId].topPlayers.push(_winnerAddress);
        }

        emit GameEnded(_gameId, _winnerAddress, games[_gameId].scores[_winnerAddress]);

        if (_isWinner) {
            INotification(notificationContractAddress).notifyGameWin(_winnerAddress, _pointsEarned);
        }
    }

    function getTopPlayers(uint _gameId) external view returns (address[] memory) {
        return games[_gameId].topPlayers;
    }

    function goOnline() external {
        isOnline[msg.sender] = true;
        emit PlayerOnline(msg.sender);
    }

    function goOffline() external {
        isOnline[msg.sender] = false;
        emit PlayerOffline(msg.sender);
    }

    function getOnlinePlayers(uint _gameId) external view returns (address[] memory) {
        address[] memory onlineList = new address[](games[_gameId].gamers.length);
        uint index = 0;

        for (uint i = 0; i < games[_gameId].gamers.length; i++) {
            if (isOnline[games[_gameId].gamers[i]]) {
                onlineList[index] = games[_gameId].gamers[i];
                index++;
            }
        }

        return onlineList;
    }

    function getUserPoints(uint _gameId, address _user) external view returns (uint) {
        return games[_gameId].earnedPoints[_user];
    }
}
