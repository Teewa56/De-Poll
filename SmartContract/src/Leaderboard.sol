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
    IGameContract public gameContract;

    event LeaderboardUpdated(uint gameId, address indexed player, uint score);

    constructor(address _owner, address _gameContract) Ownable(_owner) {
        gameContract = IGameContract(_gameContract);
    }

    function updateLeaderboard(uint _gameId, address _player) external onlyOwner {
        uint playerScore = gameContract.getUserPoints(_gameId, _player);
        require(playerScore > 0, "Player has no recorded score");

        leaderboards[_gameId].push(PlayerScore({player: _player, score: playerScore}));

        emit LeaderboardUpdated(_gameId, _player, playerScore);
    }

    function getLeaderboard(uint _gameId) external view returns (PlayerScore[] memory) {
        return leaderboards[_gameId];
    }

    function setGameContract(address _newGameContract) external onlyOwner {
        gameContract = IGameContract(_newGameContract);
    }
}
