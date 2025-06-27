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

// Game rooms storage
const rooms = new Map();
const playerConnections = new Map();

// Game phases
const GAME_PHASES = {
  WAITING: 'waiting',
  BETTING: 'betting',
  READY_TO_PLAY: 'readyToPlay',
  DEALING: 'dealing',
  FINISHED: 'finished',
  SHOW_RESULT: 'showResult'
};

// Bet sides
const BET_SIDES = {
  ANDAR: 'andar',
  BAHAR: 'bahar'
};

class GameRoom {
  constructor(roomId, hostId, hostName) {
    this.roomId = roomId;
    this.hostId = hostId;
    this.players = new Map();
    this.gameState = {
      phase: GAME_PHASES.WAITING,
      jokerCard: null,
      andarCards: [],
      baharCards: [],
      deck: [],
      bets: [],
      winningSide: null,
      totalCardsDealt: 0,
      bettingTimer: null,
      dealingTimer: null,
      roundNumber: 0
    };
    
    // Add host as first player
    this.addPlayer(hostId, hostName, true);
  }

  addPlayer(playerId, playerName, isHost = false) {
    if (this.players.size >= 6) { // Max 6 players
      return false;
    }

    this.players.set(playerId, {
      id: playerId,
      name: playerName,
      balance: 5000,
      isHost: isHost,
      isReady: false,
      currentBet: null,
      isConnected: true
    });

    return true;
  }

  removePlayer(playerId) {
    const player = this.players.get(playerId);
    if (player) {
      this.players.delete(playerId);
      
      // If host leaves, assign new host
      if (player.isHost && this.players.size > 0) {
        const newHost = this.players.values().next().value;
        newHost.isHost = true;
        this.hostId = newHost.id;
      }
    }
    
    return this.players.size === 0; // Return true if room is empty
  }

  startGame() {
    if (this.players.size < 2) return false;
    
    this.gameState.phase = GAME_PHASES.BETTING;
    this.gameState.roundNumber++;
    this.gameState.bets = [];
    this.gameState.winningSide = null;
    this.gameState.jokerCard = null;
    this.gameState.andarCards = [];
    this.gameState.baharCards = [];
    this.gameState.totalCardsDealt = 0;
    
    // Create and shuffle deck
    this.createDeck();
    this.shuffleDeck();
    
    // Start 5-second betting timer
    this.startBettingTimer();
    
    return true;
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

    this.gameState.bettingTimer = setTimeout(() => {
      this.endBettingPhase();
    }, 10000); // 10 seconds for betting
  }

  endBettingPhase() {
    if (this.gameState.bets.length === 0) {
      // No bets placed, restart game
      this.startGame();
      return;
    }

    this.gameState.phase = GAME_PHASES.READY_TO_PLAY;
    this.broadcastGameState();
    
    // Start dealing after 1 second
    setTimeout(() => {
      this.startDealing();
    }, 1000);
  }

  placeBet(playerId, side, amount) {
    if (this.gameState.phase !== GAME_PHASES.BETTING) return false;
    
    const player = this.players.get(playerId);
    if (!player || player.balance < amount) return false;

    // Remove existing bet from this player
    this.gameState.bets = this.gameState.bets.filter(bet => bet.playerId !== playerId);
    
    // Add new bet
    player.balance -= amount;
    player.currentBet = { side, amount };
    
    this.gameState.bets.push({
      playerId,
      playerName: player.name,
      side,
      amount
    });

    return true;
  }

  startDealing() {
    if (this.gameState.deck.length === 0) return;
    
    // Reveal joker
    this.gameState.jokerCard = this.gameState.deck.shift();
    this.gameState.jokerCard.isVisible = true;
    this.gameState.phase = GAME_PHASES.DEALING;
    
    this.broadcastGameState();
    
    // Start dealing cards
    setTimeout(() => {
      this.dealNextCard();
    }, 700);
  }

  dealNextCard() {
    if (this.gameState.deck.length === 0 || !this.gameState.jokerCard) return;
    
    const nextCard = this.gameState.deck.shift();
    nextCard.isVisible = true;
    
    // Determine which side to deal to
    let dealToSide;
    if (this.gameState.totalCardsDealt === 0) {
      // First card goes to side based on joker color
      dealToSide = this.gameState.jokerCard.isBlack ? BET_SIDES.ANDAR : BET_SIDES.BAHAR;
    } else {
      // Alternate sides
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
    
    // Check for winning condition
    if (nextCard.rank === this.gameState.jokerCard.rank) {
      this.gameState.winningSide = dealToSide;
      this.gameState.phase = GAME_PHASES.FINISHED;
      this.finishRound();
    } else {
      this.broadcastGameState();
      // Continue dealing
      setTimeout(() => {
        this.dealNextCard();
      }, 400);
    }
  }

  finishRound() {
    this.gameState.phase = GAME_PHASES.SHOW_RESULT;
    
    // Calculate and apply payouts
    this.calculatePayouts();
    
    this.broadcastGameState();
    
    // Start new round after 5 seconds
    setTimeout(() => {
      // Initialize next round and notify clients
      this.startGame();
      this.broadcastGameState();
    }, 5000);
  }

  calculatePayouts() {
    if (!this.gameState.winningSide) return;
    
    for (const bet of this.gameState.bets) {
      if (bet.side === this.gameState.winningSide) {
        const player = this.players.get(bet.playerId);
        if (player) {
          // Andar: 0.9:1, Bahar: 1:1
          const multiplier = bet.side === BET_SIDES.ANDAR ? 1.9 : 2.0;
          const payout = Math.round(bet.amount * multiplier);
          player.balance += payout;
        }
      }
    }
    
    // Clear current bets
    this.players.forEach(player => {
      player.currentBet = null;
    });
  }

  broadcastGameState() {
    // Create a clean copy of game state without timer references
    const cleanGameState = {
      phase: this.gameState.phase,
      jokerCard: this.gameState.jokerCard,
      andarCards: this.gameState.andarCards,
      baharCards: this.gameState.baharCards,
      deck: this.gameState.deck,
      bets: this.gameState.bets,
      winningSide: this.gameState.winningSide,
      totalCardsDealt: this.gameState.totalCardsDealt,
      roundNumber: this.gameState.roundNumber
      // Exclude bettingTimer and dealingTimer as they contain circular references
    };

    const gameData = {
      type: 'gameState',
      roomId: this.roomId,
      gameState: cleanGameState,
      players: Array.from(this.players.values())
    };

    this.players.forEach(player => {
      const connection = playerConnections.get(player.id);
      if (connection && connection.readyState === WebSocket.OPEN) {
        connection.send(JSON.stringify(gameData));
      }
    });
  }

  getRoomInfo() {
    return {
      roomId: this.roomId,
      hostId: this.hostId,
      playerCount: this.players.size,
      maxPlayers: 6,
      gamePhase: this.gameState.phase,
      players: Array.from(this.players.values())
    };
  }
}

// WebSocket connection handler
wss.on('connection', (ws) => {
  console.log('New client connected');
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      handleMessage(ws, data);
    } catch (error) {
      console.error('Error parsing message:', error);
      ws.send(JSON.stringify({ type: 'error', message: 'Invalid message format' }));
    }
  });
  
  ws.on('close', () => {
    console.log('Client disconnected');
    handleDisconnection(ws);
  });
});

function handleMessage(ws, data) {
  switch (data.type) {
    case 'createRoom':
      handleCreateRoom(ws, data);
      break;
    case 'joinRoom':
      handleJoinRoom(ws, data);
      break;
    case 'leaveRoom':
      handleLeaveRoom(ws, data);
      break;
    case 'startGame':
      handleStartGame(ws, data);
      break;
    case 'placeBet':
      handlePlaceBet(ws, data);
      break;
    case 'getRooms':
      handleGetRooms(ws);
      break;
    default:
      ws.send(JSON.stringify({ type: 'error', message: 'Unknown message type' }));
  }
}

function handleCreateRoom(ws, data) {
  const roomId = uuidv4().substring(0, 8).toUpperCase();
  const playerId = uuidv4();
  const playerName = data.playerName || 'Player';
  
  const room = new GameRoom(roomId, playerId, playerName);
  rooms.set(roomId, room);
  playerConnections.set(playerId, ws);
  ws.playerId = playerId;
  ws.roomId = roomId;
  
  ws.send(JSON.stringify({
    type: 'roomCreated',
    roomId: roomId,
    playerId: playerId,
    roomInfo: room.getRoomInfo()
  }));
  
  console.log(`Room ${roomId} created by ${playerName}`);
}

function handleJoinRoom(ws, data) {
  const room = rooms.get(data.roomId);
  if (!room) {
    ws.send(JSON.stringify({ type: 'error', message: 'Room not found' }));
    return;
  }
  
  const playerId = uuidv4();
  const playerName = data.playerName || 'Player';
  
  if (room.addPlayer(playerId, playerName)) {
    playerConnections.set(playerId, ws);
    ws.playerId = playerId;
    ws.roomId = data.roomId;
    
    ws.send(JSON.stringify({
      type: 'roomJoined',
      roomId: data.roomId,
      playerId: playerId,
      roomInfo: room.getRoomInfo()
    }));
    
    // Broadcast to all players in room
    room.broadcastGameState();
    
    console.log(`${playerName} joined room ${data.roomId}`);
  } else {
    ws.send(JSON.stringify({ type: 'error', message: 'Room is full' }));
  }
}

function handleLeaveRoom(ws, data) {
  const room = rooms.get(data.roomId);
  if (room && ws.playerId) {
    const isEmpty = room.removePlayer(ws.playerId);
    playerConnections.delete(ws.playerId);
    
    if (isEmpty) {
      rooms.delete(data.roomId);
      console.log(`Room ${data.roomId} deleted (empty)`);
    } else {
      room.broadcastGameState();
    }
    
    ws.send(JSON.stringify({ type: 'leftRoom' }));
  }
}

function handleStartGame(ws, data) {
  const room = rooms.get(data.roomId);
  if (room && ws.playerId) {
    const player = room.players.get(ws.playerId);
    if (player && player.isHost) {
      if (room.startGame()) {
        room.broadcastGameState();
        console.log(`Game started in room ${data.roomId}`);
      } else {
        ws.send(JSON.stringify({ type: 'error', message: 'Need at least 2 players to start' }));
      }
    } else {
      ws.send(JSON.stringify({ type: 'error', message: 'Only host can start the game' }));
    }
  }
}

function handlePlaceBet(ws, data) {
  const room = rooms.get(data.roomId);
  if (room && ws.playerId) {
    if (room.placeBet(ws.playerId, data.side, data.amount)) {
      room.broadcastGameState();
    } else {
      ws.send(JSON.stringify({ type: 'error', message: 'Cannot place bet' }));
    }
  }
}

function handleGetRooms(ws) {
  const roomList = Array.from(rooms.values()).map(room => ({
    roomId: room.roomId,
    playerCount: room.players.size,
    maxPlayers: 6,
    gamePhase: room.gameState.phase
  }));
  
  ws.send(JSON.stringify({
    type: 'roomList',
    rooms: roomList
  }));
}

function handleDisconnection(ws) {
  if (ws.playerId && ws.roomId) {
    const room = rooms.get(ws.roomId);
    if (room) {
      const player = room.players.get(ws.playerId);
      if (player) {
        player.isConnected = false;
        // Keep player in room for potential reconnection
        // Remove after 30 seconds of disconnection
        setTimeout(() => {
          if (room.players.has(ws.playerId) && !room.players.get(ws.playerId).isConnected) {
            const isEmpty = room.removePlayer(ws.playerId);
            if (isEmpty) {
              rooms.delete(ws.roomId);
            } else {
              room.broadcastGameState();
            }
          }
        }, 30000);
      }
    }
    playerConnections.delete(ws.playerId);
  }
}

// Start HTTP + WebSocket server
server.listen(PORT, () => {
  console.log(`Andar Bahar server running on port ${PORT}`);
}); 