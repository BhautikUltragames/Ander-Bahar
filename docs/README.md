# 🎴 Andar Bahar Game - Flutter Web with Multiplayer

A modern implementation of the traditional Indian card game **Andar Bahar** built with Flutter for web browsers, featuring both AI and real-time multiplayer modes.

## 🌟 Current Status

### ✅ **Working Features**

- **Single Player Mode**: Fully functional with AI opponent that auto-bets at round start
- **Beautiful UI**: Animated home screen with gradient backgrounds and bet summaries
- **Complete Game Logic**: Traditional Andar Bahar rules implementation
- **Betting System**: Multiple chip values (25, 50, 100, 250, 500)
- **Celebrations**: Confetti animations for wins
- **Multiplayer Mode**: Real-time WebSocket multiplayer with room system
- **Auto AI Betting**: AI automatically places bets when new rounds start in single-player mode
- **Bet Display**: Shows both human and AI bets with chosen sides and amounts
- **Enhanced Winner Overlays**: Detailed multiplayer results with personalized "You Win!"/"You Lose" messages

### 🎮 Multiplayer Features

- 🏠 **Room System**: Create rooms with unique IDs or join existing ones
- 👥 **Multi-player Support**: 2-6 players per room
- 🎯 **Real-time Betting**: 10-second server-side betting timer with 5-second UI countdown
- 👑 **Host Controls**: Room creator must manually start initial game, then auto-starts new rounds
- 🎮 **Smart Game Start**: Initial game requires host to click "START GAME", new rounds auto-start
- 🔄 **Auto-reconnection**: 10-second grace period for disconnected players
- 🛡️ **Continuous Gameplay**: Games continue even if players disconnect during active rounds
- 💬 **Live Updates**: Real-time game state synchronization
- 🏆 **Winner Display**: Shows detailed winner information with results overlay

### 🎨 UI/UX Features

- 🎨 Beautiful gradient backgrounds and animations
- 🎯 Smooth button slide animations (left, right, bottom entry)
- 🎊 Confetti celebrations for wins
- 📱 Responsive design for web browsers
- 🌈 Modern Material Design components
- 🆕 Multiplayer lobby with room browser
- 📊 **Bet Summary Display**: Shows human and AI bets with chosen sides
- 🏆 **Enhanced Winner Overlay**: "You Win!" / "You Lose" text in multiplayer

### 🎲 Game Features

- ♠️ Complete 52-card deck simulation
- 🎰 Traditional Andar Bahar rules implementation
- 💰 Betting system with multiple chip values (25, 50, 100, 250, 500)
- ⏱️ 10-second betting window - players can place multiple bets during this time
- 🎯 **Multiple Betting**: Users can bet multiple times on ANDAR and BAHAR within the betting window
- 💸 **Balance Deduction**: Money is deducted from balance for each bet placed
- 🚫 **Betting Timeout**: Betting buttons hide after 10 seconds automatically
- 🎲 Authentic card dealing logic based on joker color
- 💎 Different payout ratios (Andar: 0.9:1, Bahar: 1:1)
- 🤖 **Smart AI**: Automatically places counter-bets in single-player mode

## 🚀 Quick Start

### **Option 1: Single Player (Ready to Play!)**

1. **Clone and run immediately**

   ```bash
   git clone https://github.com/BhautikUltragames/Ander-Bahar.git
   cd andar_bahar_game
   flutter pub get
   flutter run -d chrome
   ```

2. **Play the game**
   - Click **"HUMAN vs AI"** on the home screen
   - You have 10 seconds to place multiple bets on ANDAR/BAHAR
   - Choose different bet amounts and place multiple bets if desired
   - AI will automatically place a counter-bet
   - Betting buttons will hide after 10 seconds
   - Watch the card dealing and results
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
│   └── game_provider.dart            # Single-player state management with AI logic
├── services/
│   └── websocket_service.dart        # Multiplayer WebSocket service
├── screens/
│   ├── home_screen.dart              # Main menu with game mode selection
│   ├── game_screen.dart              # Single-player game interface with bet display
│   ├── multiplayer_lobby_screen.dart # Room creation/joining
│   └── multiplayer_game_screen.dart  # Multiplayer game interface with winner overlay
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
- **Multiple Betting**: Place multiple bets on ANDAR/BAHAR within 10-second window
- **Auto AI Betting**: AI automatically places bets when you start a new round
- **Real-time Balance**: Money deducted immediately for each bet placed
- **Smart AI Opponent**: AI places counter-bets for dynamic gameplay
- **Betting Timer**: 10-second window with countdown display, buttons hide automatically
- **Smooth Progression**: Automatic game flow from betting to dealing to results
- **Bet Summary**: See all your bets and AI's bet with chosen sides and total amounts

### 🌐 **Multiplayer Mode**

- **Easy Server Setup**: Bundled Node.js - no separate installation needed
- **Room Management**: Create rooms with unique 8-character IDs
- **Real-time Synchronization**: All players see the same game state
- **Multiple Betting**: All players can place multiple bets within 10-second window
- **Synchronized Timer**: 10-second betting window for all players simultaneously
- **Host Controls**: Room creator manually starts initial game, then auto-starts new rounds
- **Continuous Gameplay**: Games continue even if players disconnect during active rounds
- **Live Player List**: See all connected players and their multiple bets
- **Automatic Payouts**: Real-time balance updates for all players
- **Winner Display**: Detailed results showing who won, their choices, bet amounts, and earnings

### 🎯 **Game Flow (Multiplayer)**

1. **Start Server**: Run `.\start_server.bat` (Windows) or `./start_server.sh` (Linux/Mac)
2. **Launch Game**: Run `flutter run -d chrome`
3. **Join/Create Room**: Enter multiplayer lobby and create or join a room
4. **Wait for Players**: Minimum 2 players required, maximum 6 players
5. **Host Starts Game**: Room creator manually clicks "START GAME" for initial round
6. **Multiple Betting**: All players have 10 seconds to place multiple bets on ANDAR/BAHAR
7. **Automatic Dealing**: Cards dealt with real-time updates (continues even if players disconnect)
8. **Results & Payouts**: Winners determined and balances updated
9. **Show Results**: Display winner overlay with "You Win!" / "You Lose" text for 5 seconds
10. **Auto New Rounds**: Subsequent rounds start automatically when 2+ players present

## 🎯 Game Rules

- **Deck**: Standard 52-card deck
- **Betting Time**: 10 seconds per round for placing multiple bets
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
- **Auto AI Logic**: AI automatically bets when new rounds start
- **Timer Synchronization**: 5-second countdown matches UI display
- **Bet Display**: Shows both human and AI bets with chosen sides

### Multiplayer

- **WebSocket Communication**: Real-time bidirectional messaging
- **Server-Authoritative**: Fair game state managed by Node.js server
- **Room Management**: Create/join rooms with unique IDs
- **Synchronized Timers**: All players see the same countdown
- **Winner Overlay**: Enhanced results display with personalized messages

## 🔧 Recent Improvements

### **AI Betting System**

- AI now automatically places bets when new rounds start in single-player mode
- Prevents multiple AI bets per round
- Creates dynamic gameplay without manual intervention

### **Timer Synchronization**

- Server uses 10-second betting timer while UI shows 5-second countdown for better UX
- Improved consistency between display and actual timing

### **UI Enhancements**

- Added bet summary display showing both human and AI bets
- Enhanced multiplayer winner overlay with "You Win!" / "You Lose" text
- Better visual feedback for game state and results

### **Server Configuration**

- Fixed `start_server.bat` to use bundled Node.js executables
- Improved reliability of server startup on Windows systems

## 🎯 Repository

- **GitHub**: https://github.com/BhautikUltragames/Ander-Bahar.git
- **Includes**: Complete Flutter app + Node.js server with bundled runtime
- **Ready to Run**: Clone and play immediately

## 🔮 Future Enhancements

- **Tournament Mode**: Multi-round competitions
- **Statistics**: Player performance tracking
- **Themes**: Customizable card designs and backgrounds
- **Sound Effects**: Audio feedback for game events
- **Mobile Responsive**: Enhanced mobile browser support

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
