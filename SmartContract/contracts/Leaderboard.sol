// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IGameContract {
    function getUserPoints(uint _gameId, address _user) external view returns (uint);
}

contract Leaderboard is Ownable {
    struct PlayerScore {
        address player;
        uint score;
    }

    mapping(uint => PlayerScore[]) public leaderboards;
    mapping(uint => uint) public leaderboardCounts;
    address public gameContract;

    event LeaderboardUpdated(uint gameId, address indexed player, uint score);

    constructor(address _owner, address _gameContract) Ownable(_owner) {
        gameContract = _gameContract;
    }

    function updateLeaderboard(uint _gameId, address _player) external onlyOwner {
        require(gameContract != address(0), "Game contract not set");
        uint playerScore = IGameContract(gameContract).getUserPoints(_gameId, _player);
        require(playerScore > 0, "Player has no recorded score");

        leaderboards[_gameId].push(PlayerScore({player: _player, score: playerScore}));
        leaderboardCounts[_gameId]++;

        emit LeaderboardUpdated(_gameId, _player, playerScore);
    }

    function getLeaderboard(uint _gameId) external view returns (PlayerScore[] memory) {
        uint count = leaderboardCounts[_gameId];
        PlayerScore[] memory scores = new PlayerScore[](count);
        for (uint i = 0; i < count; i++) {
            scores[i] = leaderboards[_gameId][i];
        }
        return scores;
    }

    function setGameContract(address _newGameContract) external onlyOwner {
        gameContract = _newGameContract;
    }
}

interface IGameContract {
    function getUserPoints(uint _gameId, address _user) external view returns (uint);
}