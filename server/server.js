const express = require('express');
const http = require('http');
const path = require('path');
const WebSocket = require('ws');
const { v4: uuidv4 } = require('uuid');

const PORT = process.env.PORT || 8080;

// Serve Flutter web build statically
const app = express();
app.use(express.static(path.join(__dirname, '..', 'build', 'web')));
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'build', 'web', 'index.html'));
});

// Create HTTP server and attach WebSocket to it
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Global game room - single room for all players
let globalRoom = null;
const playerConnections = new Map();

// Game phases
const GAME_PHASES = {
  BETTING: 'betting',
  WAITING_FOR_PLAYERS: 'waitingForPlayers', // New phase when no bets placed
  DEALING: 'dealing',
  MATCH_FOUND: 'matchFound', // New phase for dramatic pause
  FINISHED: 'finished',
  SHOW_RESULT: 'showResult'
};

// Bet sides
const BET_SIDES = {
  ANDAR: 'andar',
  BAHAR: 'bahar'
};

class GlobalGameRoom {
  constructor() {
    this.roomId = 'global';
    this.players = new Map();
    this.gameState = {
      phase: GAME_PHASES.BETTING,
      jokerCard: null,
      andarCards: [],
      baharCards: [],
      deck: [],
      bets: [],
      winningSide: null,
      totalCardsDealt: 0,
      bettingTimer: null,
      dealingTimer: null,
      roundNumber: 0,
      bettingTimeLeft: 10
    };
    
    // Start continuous rounds immediately
    this.startContinuousRounds();
  }

  addPlayer(playerId, playerName, shouldBroadcast = false) {
    console.log(`Adding player ${playerName} (${playerId}) to global room`);
    
    this.players.set(playerId, {
      id: playerId,
      name: playerName,
      balance: 1000,
      isConnected: true,
      roundBets: { andar: 0, bahar: 0 } // Current round bets for display
    });

    if (shouldBroadcast) {
      this.broadcastGameState();
    }
    return true;
  }

  removePlayer(playerId) {
    const player = this.players.get(playerId);
    if (player) {
      console.log(`Removing player ${player.name} (${playerId}) from global room`);
      this.players.delete(playerId);
      this.broadcastGameState();
    }
  }

  startContinuousRounds() {
    console.log('Starting continuous rounds in global room');
    this.startNewRound();
  }

  startNewRound() {
    console.log(`Starting round ${this.gameState.roundNumber + 1}`);
    
    this.gameState.phase = GAME_PHASES.BETTING;
    this.gameState.roundNumber++;
    this.gameState.bets = [];
    this.gameState.winningSide = null;
    this.gameState.jokerCard = null;
    this.gameState.andarCards = [];
    this.gameState.baharCards = [];
    this.gameState.totalCardsDealt = 0;
    this.gameState.bettingTimeLeft = 10;
    
    // Reset player round bets (all players are connected since we remove disconnected ones)
    this.players.forEach(player => {
      player.roundBets = { andar: 0, bahar: 0 };
    });
    
    // Create and shuffle deck
    this.createDeck();
    this.shuffleDeck();
    
    // Start 10-second betting timer with countdown
    this.startBettingTimer();
    this.broadcastGameState();
  }



  createDeck() {
    this.gameState.deck = [];
    const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
    const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    
    for (const suit of suits) {
      for (const rank of ranks) {
        this.gameState.deck.push({
          suit,
          rank,
          isVisible: false,
          isBlack: suit === 'clubs' || suit === 'spades'
        });
      }
    }
  }

  shuffleDeck() {
    for (let i = this.gameState.deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.gameState.deck[i], this.gameState.deck[j]] = [this.gameState.deck[j], this.gameState.deck[i]];
    }
  }

  startBettingTimer() {
    if (this.gameState.bettingTimer) {
      clearTimeout(this.gameState.bettingTimer);
    }

    // Countdown timer
    const countdown = () => {
      if (this.gameState.bettingTimeLeft > 0) {
        this.gameState.bettingTimeLeft--;
        this.broadcastGameState();
        this.gameState.bettingTimer = setTimeout(countdown, 1000);
      } else {
        this.endBettingPhase();
      }
    };
    
    this.gameState.bettingTimer = setTimeout(countdown, 1000);
  }

  endBettingPhase() {
    // CLEAR betting timer immediately
    if (this.gameState.bettingTimer) {
      clearTimeout(this.gameState.bettingTimer);
      this.gameState.bettingTimer = null;
    }
    
    console.log(`Round ${this.gameState.roundNumber}: Betting ended. ${this.gameState.bets.length} bets placed`);
    
    // Calculate and display total bets amount
    if (this.gameState.bets.length > 0) {
      const totalBetsAmount = this.gameState.bets.reduce((sum, bet) => sum + bet.amount, 0);
      console.log(`Total Player's Bet:- ₹${totalBetsAmount}`);
    }
    
    if (this.gameState.bets.length === 0) {
      // No bets placed, wait longer before starting new round (proper multiplayer behavior)
      console.log('No bets placed this round. Waiting 15 seconds before next round...');
      this.gameState.phase = GAME_PHASES.WAITING_FOR_PLAYERS;
      this.gameState.bettingTimeLeft = 15;
      this.broadcastGameState();
      
      // Start countdown for next round - store the timer ID
      const waitCountdown = () => {
        if (this.gameState.phase === GAME_PHASES.WAITING_FOR_PLAYERS && this.gameState.bettingTimeLeft > 0) {
          this.gameState.bettingTimeLeft--;
          this.broadcastGameState();
          this.gameState.bettingTimer = setTimeout(waitCountdown, 1000);
        } else if (this.gameState.bettingTimeLeft <= 0) {
          this.startNewRound();
        }
      };
      this.gameState.bettingTimer = setTimeout(waitCountdown, 1000);
      return;
    }

    // Start dealing immediately if we have bets
    console.log('🎲 Starting card dealing phase...');
    this.gameState.bettingTimeLeft = 0; // Clear timer display
    setTimeout(() => {
      this.startDealing();
    }, 500);
  }

  placeBet(playerId, side, amount) {
    // Allow betting during both betting phase and waiting for players phase
    if (this.gameState.phase !== GAME_PHASES.BETTING && 
        this.gameState.phase !== GAME_PHASES.WAITING_FOR_PLAYERS) return false;
    
    const player = this.players.get(playerId);
    if (!player || player.balance < amount) return false;

    // If we were waiting for players, restart betting phase with shorter timer
    if (this.gameState.phase === GAME_PHASES.WAITING_FOR_PLAYERS) {
      console.log('Player placed bet during waiting phase. Starting short betting phase...');
      // Clear any waiting timer first
      if (this.gameState.bettingTimer) {
        clearTimeout(this.gameState.bettingTimer);
        this.gameState.bettingTimer = null;
      }
      this.gameState.phase = GAME_PHASES.BETTING;
      this.gameState.bettingTimeLeft = 3; // Shorter 3-second timer to allow for additional bets
      this.startBettingTimer();
    }

    // Deduct balance and add bet
    player.balance -= amount;
    player.roundBets[side] += amount;
    
    this.gameState.bets.push({
      playerId,
      playerName: player.name,
      side,
      amount
    });

    console.log(`Player ${player.name} bet ₹${amount} on ${side}`);
    this.broadcastGameState();
    return true;
  }

  startDealing() {
    if (this.gameState.deck.length === 0) return;
    
    // CLEAR ALL TIMERS when starting to deal
    if (this.gameState.bettingTimer) {
      clearTimeout(this.gameState.bettingTimer);
      this.gameState.bettingTimer = null;
    }
    
    // Reveal joker
    this.gameState.jokerCard = this.gameState.deck.shift();
    this.gameState.jokerCard.isVisible = true;
    this.gameState.phase = GAME_PHASES.DEALING;
    this.gameState.bettingTimeLeft = 0; // Reset timer display
    
    console.log(`Dealing started. Joker: ${this.gameState.jokerCard.rank} of ${this.gameState.jokerCard.suit}`);
    this.broadcastGameState();
    
    // Start dealing cards after brief delay for joker reveal
    setTimeout(() => {
      this.dealNextCard();
    }, 300);
  }

  dealNextCard() {
    if (this.gameState.deck.length === 0 || !this.gameState.jokerCard) return;
    
    const nextCard = this.gameState.deck.shift();
    nextCard.isVisible = true;
    
    // Determine which side to deal to (alternating, starting with joker color side)
    let dealToSide;
    if (this.gameState.totalCardsDealt === 0) {
      dealToSide = this.gameState.jokerCard.isBlack ? BET_SIDES.ANDAR : BET_SIDES.BAHAR;
    } else {
      dealToSide = (this.gameState.andarCards.length <= this.gameState.baharCards.length) 
        ? BET_SIDES.ANDAR : BET_SIDES.BAHAR;
    }
    
    // Add card to appropriate side
    if (dealToSide === BET_SIDES.ANDAR) {
      this.gameState.andarCards.push(nextCard);
    } else {
      this.gameState.baharCards.push(nextCard);
    }
    
    this.gameState.totalCardsDealt++;
    
    // Check for match
    if (nextCard.rank === this.gameState.jokerCard.rank) {
      this.gameState.winningSide = dealToSide;
      this.gameState.phase = GAME_PHASES.MATCH_FOUND; // Set special phase for highlighting
      
      console.log(`🎯 MATCH FOUND! ${nextCard.rank} matches joker ${this.gameState.jokerCard.rank}. Winner: ${dealToSide.toUpperCase()}`);
      console.log(`🎨 Setting phase to 'matchFound' and broadcasting for green highlighting...`);
      
      // Broadcast state to show the matching card highlighted
      this.broadcastGameState();
      
      console.log(`⏰ Brief pause to show winning card...`);
      // Extended pause to show the winning card before declaring winner
      setTimeout(() => {
        this.finishRound();
      }, 3000);
    } else {
      this.broadcastGameState();
      // Continue dealing after short delay for animation
      setTimeout(() => {
        this.dealNextCard();
      }, 400);
    }
  }

  finishRound() {
    // CLEAR ALL TIMERS when finishing round
    if (this.gameState.bettingTimer) {
      clearTimeout(this.gameState.bettingTimer);
      this.gameState.bettingTimer = null;
    }
    
    this.gameState.phase = GAME_PHASES.FINISHED;
    this.gameState.bettingTimeLeft = 0; // Clear timer display
    console.log(`Round ${this.gameState.roundNumber} finished. Winner: ${this.gameState.winningSide}`);
    
    // Calculate and distribute payouts
    this.calculatePayouts();
    
    this.broadcastGameState();
    
    console.log(`🏆 Starting next round after brief delay...`);
    
    // Start next round after brief delay for result display
    setTimeout(() => {
      this.startNewRound();
    }, 4000);  // Extended delay for longer winner screen
  }

  calculatePayouts() {
    if (!this.gameState.winningSide) return;
    
    const winningSide = this.gameState.winningSide;
    let totalPayout = 0;
    
    this.gameState.bets.forEach(bet => {
      if (bet.side === winningSide) {
        // Simple 2x payout: bet ₹250 → get ₹500
        const winningAmount = bet.amount * 2;
        
        const player = this.players.get(bet.playerId);
        if (player) {
          player.balance += winningAmount; // Give them double their bet
          totalPayout += winningAmount;
          console.log(`Player ${player.name} won: ₹${bet.amount} bet → ₹${winningAmount} payout`);
        }
      }
    });
    
    console.log(`Total payout distributed: ₹${totalPayout}`);
  }

  broadcastGameState() {
    // All players in the room are connected (since we remove disconnected ones)
    const playersArray = Array.from(this.players.values()).map(player => ({
      id: player.id,
      name: player.name,
      balance: player.balance,
      isConnected: player.isConnected,
      roundBets: player.roundBets
    }));

    // Create a clean game state without timer objects and deck for JSON serialization
    const cleanGameState = {
      phase: this.gameState.phase,
      roundNumber: this.gameState.roundNumber,
      jokerCard: this.gameState.jokerCard,
      andarCards: this.gameState.andarCards,
      baharCards: this.gameState.baharCards,
      totalCardsDealt: this.gameState.totalCardsDealt,
      winningSide: this.gameState.winningSide,
      bets: this.gameState.bets,
      // Only include timer for betting and waiting phases
      ...(this.gameState.phase === GAME_PHASES.BETTING || this.gameState.phase === GAME_PHASES.WAITING_FOR_PLAYERS ? 
          { bettingTimeLeft: this.gameState.bettingTimeLeft } : {}),
      // Exclude deck array as it's large and not needed by clients
    };

    const message = {
      type: 'gameState',
      gameState: cleanGameState,
      players: playersArray
    };

    // Broadcast to all connected players
    this.players.forEach(player => {
      const ws = playerConnections.get(player.id);
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(message));
      }
    });
  }
}

// Initialize global room
globalRoom = new GlobalGameRoom();

// WebSocket connection handling
wss.on('connection', (ws) => {
  console.log('New WebSocket connection');
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      handleMessage(ws, data);
    } catch (e) {
      console.error('Error parsing message:', e);
    }
  });

  ws.on('close', () => {
    handleDisconnection(ws);
  });

  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
});

function handleMessage(ws, data) {
  console.log(`Received message: ${data.type}`);
  
  switch (data.type) {
    case 'joinGlobal':
      handleJoinGlobal(ws, data);
      break;
    case 'placeBet':
      handlePlaceBet(ws, data);
      break;
    case 'pong':
      // Handle pong responses if needed
      break;
    default:
      console.log(`Unknown message type: ${data.type}`);
  }
}

function handleJoinGlobal(ws, data) {
  const playerName = data.playerName || `Player${Date.now() % 1000}`;
  const playerId = uuidv4();
  
  // Create new player (always fresh since we remove players when they leave)
  globalRoom.addPlayer(playerId, playerName, true);
  console.log(`Player ${playerName} joined global room`);
  
  // Store connection
  playerConnections.set(playerId, ws);
  ws.playerId = playerId;
  
  // Send join confirmation
  ws.send(JSON.stringify({
    type: 'joinedGlobal',
    playerId: playerId,
    roomId: 'global'
  }));
}

function handlePlaceBet(ws, data) {
  if (!ws.playerId) return;
  
  const success = globalRoom.placeBet(ws.playerId, data.side, data.amount);
  
  if (!success) {
    ws.send(JSON.stringify({
      type: 'error',
      message: 'Failed to place bet'
    }));
  }
}

function handleDisconnection(ws) {
  if (ws.playerId) {
    const player = globalRoom.players.get(ws.playerId);
    if (player) {
      console.log(`Player ${player.name} left the game - removing from room`);
      // Completely remove player from the room
      globalRoom.players.delete(ws.playerId);
      globalRoom.broadcastGameState();
    }
    playerConnections.delete(ws.playerId);
  }
}

// Start server
server.listen(PORT, () => {
  console.log(`Andar Bahar WebSocket Server running on port ${PORT}`);
  console.log(`Global room initialized with continuous 10-second rounds`);
}); 