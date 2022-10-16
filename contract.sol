// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * Contract is deployed at 0x18089291a6484850153e6EC7637D2EcC9AAe803c on 
 * Ethereum Goerli Test Network
 *
 * Authors:
 *     Utkarsh Patel (18EC35034)
 *     Saransh Patel (18CS30039)
 *
 * Part of Assignment #3 for course CS61065 (Autumn 2022)
 */


/**
 * Solidity contract for Morra game for two players. See README.pdf for 
 * instructions on how to play this game.
 */
contract MorraGame {
    address payable[2] private playerAddress;      /* address of two players       */
    bytes32[2]         private playerHashMove;     /* hashed move of the players   */
    bool[2]            private hasPlayerCommited;  /* Check if committed           */
    string[2]          private playerRevealMove;   /* unhashed move of the players */
    bool[2]            private hasPlayerRevealed;  /* Check if move is revealed    */

    uint               private betThreshold;       /* threshold on bet to register */
    uint               private totalBet;           /* total bet on the game        */
    uint               private playerCount;        /* number of players registered */


    /**
     * Reset state of this contract at the initialization or after a game ends
     */
    function reset() private {
        betThreshold         = (uint) (1e15 + 1);
        totalBet             = 0;
        playerCount          = 0;
        hasPlayerCommited[0] = false;
        hasPlayerCommited[1] = false;
        hasPlayerRevealed[0] = false;
        hasPlayerRevealed[1] = false;
    }

    constructor() {
        reset();
    }


    /**
     * Routine to be used by players to register in the game
     */
    function initialize() public payable returns (uint) {
        if (playerCount >= 2) {
            /* Two players already registed */
            return 0;
        }

        if (msg.value < betThreshold) {
            /* Insufficient funds received for registration */
            return 0;
        }

        if (playerCount == 0) {
            playerAddress[0] =  payable(msg.sender);
            betThreshold     =  msg.value;
            totalBet         += msg.value;
            playerCount++;
        } 

        else {
            if (msg.sender == playerAddress[0]) {
                /* This user is already registered as player1 */
                return 0;
            }

            playerAddress[1] =  payable(msg.sender);
            betThreshold     =  msg.value;
            totalBet         += msg.value;
            playerCount++;
        }

        return playerCount;
    }


    /**
     * Routine to commit player's move in the contract
     */
    function commitmove(bytes32 hashMove) public returns (bool) {
        if (playerCount != 2) {
            return false;
        }

        uint playerID = getPlayerId();
        if (playerID == 0) {
            return false;
        }

        playerID--;
        if (hasPlayerCommited[playerID]) {
            /* Player already committed */
            return false;
        }

        hasPlayerCommited[playerID] = true;
        playerHashMove[playerID] = hashMove;
        return true;
    }


    /**
     * Routine to reveal player's move
     */
    function revealmove(string memory revealedMove) public returns (int) {
        uint playerID = getPlayerId();
        if (playerID == 0) {
            /* Unregistred player */
            return -1;
        }

        playerID--;
        if (!hasPlayerCommited[0] || !hasPlayerCommited[1]) {
            /* Both players have not committed */
            return -1;
        }

        bytes32 hashMove = sha256(abi.encodePacked(revealedMove));
        if (hashMove != playerHashMove[playerID]) {
            /* Hash doesn't match */
            return -1;
        }

        playerRevealMove[playerID] = revealedMove;
        hasPlayerRevealed[playerID] = true;

        /* Check if both player revealed their moves */
        if (hasPlayerRevealed[0] && hasPlayerRevealed[1]) {
            int player1Move = getFirstChar(playerRevealMove[0]);
            int player2Move = getFirstChar(playerRevealMove[1]);

            if (player1Move == player2Move) {
                /* Player 2 wins */
                playerAddress[1].transfer(address(this).balance);

            } else {
                /* Player 1 wins */
                playerAddress[0].transfer(address(this).balance);
            }

            reset();

            if (playerID == 0) {
                return player1Move;
            } else {
                return player2Move;
            }
        }

        return -1;
    }


    /**
     * Routine to extract #fingers from player's response
     */
    function getFirstChar(string memory str) private pure returns (int) {
        if (bytes(str)[0] == 0x30) {
            return 0;
        } else if (bytes(str)[0] == 0x31) {
            return 1;
        } else if (bytes(str)[0] == 0x32) {
            return 2;
        } else if (bytes(str)[0] == 0x33) {
            return 3;
        } else if (bytes(str)[0] == 0x34) {
            return 4;
        } else if (bytes(str)[0] == 0x35) {
            return 5;
        } else {
            return -1;
        }
    }


    /******************************* DEBUGGER *********************************/


    /**
     * Return the balance of the smart contract
     */
    function getBalance() public view returns (uint) {
        return totalBet;
    }

    
    /**
     * If executing a/c is 
     * - player1, return 1
     * - player2, return 2
     * else,      return 0
     */
    function getPlayerId() public view returns (uint) {
        if (msg.sender == playerAddress[0]) return 1;
        else if (msg.sender == playerAddress[1]) return 2;
        return 0;
    }


    function getPlayerCount() public view returns (uint) {
        return playerCount;
    }


    function getBetThreshold() public view returns (uint) {
        return betThreshold;
    }


    function getPlayer1Address() public view returns (address payable) {
        return playerAddress[0];
    }
    

    function getPlayer2Address() public view returns (address payable) {
        return playerAddress[1];
    }


    function getPlayer1HashMove() public view returns (bytes32) {
        return playerHashMove[0];
    }


    function getPlayer2HashMove() public view returns (bytes32) {
        return playerHashMove[1];
    }


    function getPlayer1Move() public view returns (string memory) {
        return playerRevealMove[0];
    }


    function getPlayer2Move() public view returns (string memory) {
        return playerRevealMove[1];
    }
}
