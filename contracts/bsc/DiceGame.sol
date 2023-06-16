// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DiceGame {
    //DATA

    address owner;
    mapping(address => uint256) public playerBalances;
    uint256 FEE = 0.001 * 10 ** 18;

    event GameResult(
        address indexed player,
        uint256 playerNumber,
        uint256 computerNumber,
        bool playerWins,
        uint256 payout
    );

    constructor() {
        owner = payable(msg.sender);
    }

    //checks if the bet is 0.01 eth
    modifier checkBet() {
        require(
            msg.value == FEE,
            "Please send exactly 0.001 ETH to play the game."
        );
        _;
    }

    //checks if the player has balance
    modifier checkBalance() {
        require(
            playerBalances[msg.sender] > 0,
            "No funds available for withdrawal."
        );
        _;
    }

    //only owner can perform
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform");
        _;
    }

    //EXECUTE FUNCTIONS

    //play function
    function play() external payable checkBet {
        uint256 playerNumber = roll(
            block.timestamp,
            block.difficulty,
            msg.sender,
            block.number + 9
        );
        uint256 computerNumber = roll(
            block.timestamp + 1,
            block.difficulty,
            address(this),
            block.number - 1
        );

        bool playerWins = playerNumber > computerNumber;

        if (playerWins) {
            uint256 payout = msg.value * 2;
            playerBalances[msg.sender] += payout;
            emit GameResult(
                msg.sender,
                playerNumber,
                computerNumber,
                true,
                payout
            );
        } else {
            emit GameResult(msg.sender, playerNumber, computerNumber, false, 0);
        }
    }

    //the player can withdraw his balance
    //can give error when the balance is low. This game will be use it's own token
    //Then when the balance is low new token will be minted by owner and will be sent to contract

    function withdraw() external {
        uint256 amount = playerBalances[msg.sender];
        playerBalances[msg.sender] = 0;

        require(amount > 0, "No funds available for withdrawal."); // Add a revert message here

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send funds.");
    }

    //roll function to get random numbers

    function roll(
        uint256 seed1,
        uint256 seed2,
        address user,
        uint256 bNumber
    ) public pure returns (uint256) {
        uint256 rollNumber = (uint256(
            keccak256(abi.encodePacked(seed1, seed2, user, bNumber))
        ) % 6) + 1;
        return rollNumber;
    }

    //QUERY FUNCTIONS

    function checkGameBalance() external view returns (uint256) {
        return playerBalances[msg.sender];
    }

    function get_owner() external view returns (address) {
        return owner;
    }
}
