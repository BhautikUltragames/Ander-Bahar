# 🎴 Andar Bahar Game - Flutter Web with Multiplayer

A modern implementation of the traditional Indian card game **Andar Bahar** built with Flutter for web browsers, featuring both AI and real-time multiplayer modes.

## 🌟 Current Status

### ✅ **Working Features**

- **Single Player Mode**: Fully functional with AI opponent
- **Beautiful UI**: Animated home screen with gradient backgrounds
- **Complete Game Logic**: Traditional Andar Bahar rules implementation
- **Betting System**: Multiple chip values (25, 50, 100, 250, 500)
- **Celebrations**: Confetti animations for wins
- **Multiplayer Mode**: Real-time WebSocket multiplayer with room system

### 🎮 Multiplayer Features

- 🏠 **Room System**: Create rooms with unique IDs or join existing ones
- 👥 **Multi-player Support**: 2-6 players per room
- 🎯 **Real-time Betting**: 5-second synchronized betting timer
- 👑 **Host Controls**: Room creator can start games
- 🔄 **Auto-reconnection**: 30-second grace period for disconnected players
- 💬 **Live Updates**: Real-time game state synchronization

### 🎨 UI/UX Features

- 🎨 Beautiful gradient backgrounds and animations
- 🎯 Smooth button slide animations (left, right, bottom entry)
- 🎊 Confetti celebrations for wins
- 📱 Responsive design for web browsers
- 🌈 Modern Material Design components
- 🆕 Multiplayer lobby with room browser

### 🎲 Game Features

- ♠️ Complete 52-card deck simulation
- 🎰 Traditional Andar Bahar rules implementation
- 💰 Betting system with multiple chip values (25, 50, 100, 250, 500)
- ⏱️ 5-second synchronized betting timer for multiplayer
- 🎲 Authentic card dealing logic based on joker color
- 💎 Different payout ratios (Andar: 0.9:1, Bahar: 1:1)

## 🚀 Quick Start

### **Option 1: Single Player (Ready to Play!)**

1. **Clone and run immediately**

   ```bash
   git clone <repository-url>
   cd andar_bahar_game
   flutter pub get
   flutter run -d chrome
   ```

2. **Play the game**
   - Click **"HUMAN vs AI"** on the home screen
   - Choose your bet amount and side (ANDAR/BAHAR)
   - Enjoy the 5-second countdown and card dealing
   - Win chips and see confetti celebrations!

### **Option 2: Multiplayer Setup**

#### **Prerequisites for Multiplayer**

- Flutter SDK (latest stable version)
- Chrome browser
- **Note**: Node.js is bundled with the project - no separate installation needed!

### 🌐 Multiplayer Mode Setup

#### **Windows (PowerShell)**

1. **Start the WebSocket server**

   ```powershell
   # In project root directory
   .\start_server.bat
   ```

2. **Run the Flutter app** (in a new terminal)
   ```powershell
   flutter pub get
   flutter run -d chrome
   ```

#### **Linux/Mac**

1. **Start the WebSocket server**

   ```bash
   chmod +x start_server.sh
   ./start_server.sh
   ```

2. **Run the Flutter app** (in a new terminal)
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

#### **Manual Server Start (if batch files don't work)**

```bash
# Use bundled Node.js
cd server
../server/node-v22.17.0-win-x64/npm.cmd install
../server/node-v22.17.0-win-x64/node.exe server.js
```

3. **Play multiplayer**
   - Click "MULTIPLAYER" on home screen
   - Create a room or join existing one
   - Share room ID with friends
   - Host starts the game when ready

### 🏗️ Build for Deployment

```bash
flutter build web
```

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with providers
├── models/
│   ├── card.dart                     # Playing card model
│   └── game_state.dart               # Game state management
├── providers/
│   └── game_provider.dart            # Single-player state management
├── services/
│   └── websocket_service.dart        # Multiplayer WebSocket service
├── screens/
│   ├── home_screen.dart              # Main menu with game mode selection
│   ├── game_screen.dart              # Single-player game interface
│   ├── multiplayer_lobby_screen.dart # Room creation/joining
│   └── multiplayer_game_screen.dart  # Multiplayer game interface
├── widgets/
│   ├── betting_panel.dart            # Single-player betting interface
│   ├── multiplayer_betting_panel.dart # Multiplayer betting interface
│   └── card_widget.dart              # Playing card UI widget
server/                               # Node.js WebSocket server
├── server.js                        # Main server file
├── package.json                     # Server dependencies
├── README.md                        # Server documentation
├── node-v22.17.0-win-x64/          # Bundled Node.js (Windows)
└── node-portable.zip               # Portable Node.js archive
```

## 🎮 Game Features

### ⚡ **Single Player Mode**

- **No Setup Required**: Just run Flutter and play instantly
- **Instant Response**: 5-second countdown starts immediately when you place a bet
- **Smart AI Opponent**: AI automatically places counter-bets for dynamic gameplay
- **Smooth Progression**: Automatic game flow from betting to dealing to results

### 🌐 **Multiplayer Mode**

- **Easy Server Setup**: Bundled Node.js - no separate installation needed
- **Room Management**: Create rooms with unique 8-character IDs
- **Real-time Synchronization**: All players see the same game state
- **Synchronized Betting**: 5-second timer for all players to place bets
- **Host Controls**: Room creator manages game start
- **Live Player List**: See all connected players and their bets
- **Automatic Payouts**: Real-time balance updates for all players

### 🎯 **Game Flow (Multiplayer)**

1. **Start Server**: Run `.\start_server.bat` (Windows) or `./start_server.sh` (Linux/Mac)
2. **Launch Game**: Run `flutter run -d chrome`
3. **Join/Create Room**: Enter multiplayer lobby and create or join a room
4. **Wait for Players**: Minimum 2 players required, maximum 6 players
5. **Host Starts Game**: Room creator initiates the game
6. **Synchronized Betting**: All players have 5 seconds to place bets
7. **Automatic Dealing**: Cards dealt with real-time updates
8. **Results & Payouts**: Winners determined and balances updated
9. **Show Results**: Display winner overlay details (name, choice, bet, result, earnings) for 5 seconds
10. **Next Round**: New round begins with 10-second betting timer

## 🎯 Game Rules

- **Deck**: Standard 52-card deck
- **Betting Time**: 5 seconds per round (multiplayer)
- **Starting Rule**:
  - If joker is BLACK (♣♠): First card goes to Andar
  - If joker is RED (♥♦): First card goes to Bahar
- **Payouts**:
  - Andar wins: 0.9:1 payout
  - Bahar wins: 1:1 payout
- **Starting Balance**: 5000 chips per player

## 🛠️ Technical Architecture

### Single Player

- **Provider Pattern**: Used for game state management
- **GameProvider**: Handles all game logic, timers, and AI behavior

### Multiplayer

- **WebSocket Communication**: Real-time bidirectional communication
- **Node.js Server**: Handles room management and game logic
- **WebSocketService**: Flutter service for server communication
- **Synchronized State**: Server-authoritative game state
- **Bundled Runtime**: No separate Node.js installation required

### Key Dependencies

```yaml
# Flutter Dependencies
provider: ^6.1.1 # State management
web_socket_channel: ^2.4.0 # WebSocket communication
confetti: ^0.7.0 # Win celebrations
```

```json
// Server Dependencies
{
  "ws": "^8.14.2", // WebSocket server
  "uuid": "^9.0.1", // Room ID generation
  "cors": "^2.8.5" // Cross-origin support
}
```

## 🔧 Troubleshooting

### Common Issues

#### **"start_server.bat not recognized" (Windows)**

```powershell
# Use .\ prefix in PowerShell
.\start_server.bat
```

#### **"npm not recognized"**

- The project includes bundled Node.js, no separate installation needed
- Batch files handle the bundled Node.js automatically

#### **WebSocket connection failed**

- Ensure server is running (you should see "Andar Bahar WebSocket server running on port 8080")
- Check that port 8080 is not blocked by firewall
- Try restarting both server and Flutter app

#### **Multiplayer room creation not working**

- Verify server is running and shows connection messages
- Check browser console for WebSocket errors
- Ensure Flutter app shows "Connected to WebSocket server" message

### Debug Information

The app includes debug logging for multiplayer:

```
Connected to WebSocket server
DEBUG: Received message: roomCreated
DEBUG: Received message: gameState
```

## 🎯 Performance

- **Single Player**: Immediate startup, no network dependencies
- **Multiplayer**: Sub-100ms response times on local network
- **Web Optimized**: Smooth 60fps animations
- **Memory Efficient**: Proper cleanup of timers and connections

## 🌟 Features Comparison

| Feature           | Single Player | Multiplayer         |
| ----------------- | ------------- | ------------------- |
| Setup Required    | None          | Start server        |
| Players           | 1 vs AI       | 2-6 humans          |
| Internet Required | No            | Yes (local network) |
| Real-time Sync    | N/A           | Yes                 |
| Room Management   | N/A           | Yes                 |
| Instant Play      | Yes           | After server start  |

## 📝 License

MIT License - Feel free to use and modify for your projects.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test both single-player and multiplayer modes
4. Submit a pull request

## 📞 Support

For issues or questions:

1. Check the troubleshooting section above
2. Review server logs for multiplayer issues
3. Check Flutter console for client-side errors
4. Ensure all prerequisites are met
