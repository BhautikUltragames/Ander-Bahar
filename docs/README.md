# 🃏 Andar Bahar - Traditional Indian Card Game

**A modern Flutter implementation of the classic Andar Bahar card game with real-time multiplayer support and professional UI**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-22.17-green.svg)](https://nodejs.org/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](https://github.com/BhautikUltragames/Ander-Bahar.git)

---

## 🎮 **Game Overview**

Andar Bahar is a traditional Indian gambling card game that originated in South India. This digital version brings the authentic experience to the web with beautiful animations, interactive hover effects, animated card dealer, and real-time multiplayer support.

### 🌟 **Key Features**

- **🎯 Authentic Gameplay** - Traditional Andar Bahar rules with modern UI
- **🎨 Interactive Design** - Hover animations and smooth transitions
- **🎪 Animated Card Dealer** - Professional card dealing animations with flying cards
- **🌈 Color Psychology** - Blue (ANDAR) for trust, Yellow (BAHAR) for luck
- **🌐 Real-time Multiplayer** - WebSocket-powered live gaming
- **🎭 Clean Interface** - Simplified, distraction-free design
- **💰 Realistic Betting** - Multiple chip denominations with visual feedback
- **🏆 Instant Results** - Live game state updates with celebration effects
- **♿ Accessibility** - WCAG AA compliant design

---

## 🚀 **Quick Start**

### **Single Player Mode (Instant Play)**

```bash
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game
flutter pub get
flutter run -d chrome
```

Click **"PLAY"** button and start gaming immediately with AI opponent!

### **Multiplayer Mode (2 Commands)**

```bash
# Terminal 1: Start WebSocket server
.\start_server.bat    # Windows
# OR
./start_server.sh     # Linux/Mac

# Terminal 2: Start Flutter app (new terminal)
flutter run -d chrome
```

Click **"PLAY"** → **"MULTIPLAYER"** and join the global room!

---

## 🎨 **Enhanced User Experience (2024)**

### **Modern Home Screen**

- **🎯 Simplified Navigation** - Essential buttons only
- **✨ Hover Animations** - Interactive button effects (1.05x scale)
- **🎪 Larger Text** - Enhanced readability (28px main buttons)
- **📱 Responsive Design** - 70% width buttons for better proportions
- **🚀 Clean Layout** - Removed clutter, focused on gameplay

### **Enhanced Game Interface**

- **🔵 ANDAR (Blue)** - Trust, stability, traditional choice
- **🟡 BAHAR (Yellow)** - Luck, prosperity, bright future
- **🎪 Animated Card Dealer** - Professional card dealing with flying card animations
- **⚡ Smooth Transitions** - 200ms hover animations
- **🎯 High Contrast** - Black text on yellow, white on blue
- **💎 Professional Polish** - Consistent visual hierarchy

---

## ✅ **What Works Perfectly**

### **Complete Single Player System**

- ✅ **AI Opponent** - Smart computer player with auto-betting
- ✅ **Instant Play** - No setup required, works offline
- ✅ **Interactive UI** - Hover effects and visual feedback
- ✅ **Animated Card Dealer** - Professional card dealing animations
- ✅ **Color-coded Interface** - Blue ANDAR vs Yellow BAHAR
- ✅ **Balance Management** - Real-time chip tracking

### **Complete Multiplayer System**

- ✅ **Global Room** - Single shared game room for all players
- ✅ **Continuous Rounds** - Automatic 10-second betting cycles
- ✅ **Real-time Updates** - Live player count and game state
- ✅ **Complete Player Removal** - Instant cleanup when players leave
- ✅ **Proper Leave Functionality** - Clean WebSocket disconnection
- ✅ **Cross-browser Support** - Test with multiple browser tabs
- ✅ **Hover Interactions** - Smooth animations on all buttons
- ✅ **Animated Dealing** - Flying card animations in multiplayer

### **Core Game Features**

- ✅ **Traditional Rules** - Authentic Andar Bahar gameplay
- ✅ **Interactive UI** - Hover effects and visual feedback
- ✅ **Betting System** - Multiple chip values (₹25-₹500)
- ✅ **Card Animations** - Smooth dealing animations with animated card dealer
- ✅ **Win Celebrations** - Confetti effects and winner displays
- ✅ **Balance Management** - Real-time chip tracking
- ✅ **Color Accessibility** - WCAG compliant contrast ratios

---

## 🎯 **Game Modes**

### 🎮 **Single Player Mode**

- **One-Click Start** - Streamlined "PLAY" button
- **Smart AI Opponent** - Computer automatically places bets
- **Animated Card Dealer** - Professional card dealing with flying animations
- **Offline Ready** - No internet connection needed
- **Perfect for Learning** - Practice the game mechanics
- **Interactive Feedback** - Hover animations and visual cues

### 🌐 **Multiplayer Mode**

- **Global Room System** - Single shared room for all players
- **Continuous Action** - New round every 10 seconds
- **Live Player Count** - See active players in real-time
- **Animated Dealing** - Flying card animations synchronized for all players
- **Cross-platform** - Works on any modern browser
- **Smooth Interactions** - Hover effects on all betting buttons

---

## 🎲 **How to Play**

### **Basic Rules**

1. **Joker Card** - A card is drawn and placed in the center (yellow background)
2. **Choose Side** - Bet on **ANDAR** (blue, left) or **BAHAR** (yellow, right)
3. **Card Dealing** - Cards are dealt alternately to both sides with animated dealer
4. **Winning** - First side to match the Joker's rank wins
5. **Payout** - Winners receive their bet back plus 95% profit

### **Betting System**

- **Chip Values** - ₹25, ₹50, ₹100, ₹250, ₹500
- **Starting Balance** - ₹5000 for all players
- **Betting Time** - 10 seconds per round
- **Payout Rate** - 95% return (5% house edge)
- **Visual Feedback** - Color-coded betting buttons with hover effects

### **Color Scheme Guide**

- **🔵 ANDAR (Blue)** - Associated with trust, stability, traditional choice
- **🟡 BAHAR (Yellow)** - Associated with luck, wealth, positive energy
- **🟢 PLAY (Green)** - Go/proceed action, start gaming
- **🟠 REBET (Orange)** - Repeat last bet, secondary action

---

## 🛠 **Technical Architecture**

### **Frontend (Flutter Web)**

- **Framework** - Flutter 3.19+ for web
- **State Management** - Provider pattern with reactive UI
- **Interactive Elements** - MouseRegion + AnimatedScale for hover effects
- **Animated Card Dealer** - Custom widget with flying card animations
- **Real-time Communication** - WebSocket integration
- **Responsive Design** - MediaQuery-based sizing (70% width buttons)
- **Smooth Animations** - 60fps card dealing and 200ms hover transitions

### **Backend (Node.js)**

- **WebSocket Server** - Real-time bidirectional communication
- **Global Game Room** - Single room for all players
- **Automatic Round Management** - Continuous 10-second cycles
- **Player Lifecycle** - Complete removal on disconnect
- **Game State Sync** - Server-authoritative game state
- **Bundled Runtime** - No separate Node.js installation required

### **UI/UX Enhancements**

- **Hover Animations** - 1.05x scale on mouse enter/exit
- **Color Psychology** - Blue for trust, yellow for luck
- **Accessibility** - High contrast text on colored backgrounds
- **Simplified Navigation** - Removed unnecessary elements
- **Professional Polish** - Consistent spacing and typography
- **Animated Card Dealer** - Smooth card dealing with flying animations

---

## 🚀 **Deployment**

### **Local Development**

```bash
# Clone and setup
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game
flutter pub get

# For single player (instant play)
flutter run -d chrome

# For multiplayer (2 terminals)
# Terminal 1:
.\start_server.bat    # Windows
./start_server.sh     # Linux/Mac

# Terminal 2:
flutter run -d chrome
```

### **Production Deployment**

- **Frontend** - Build with `flutter build web` and deploy to any web server
- **Backend** - Deploy Node.js server to cloud hosting (Heroku, DigitalOcean, etc.)
- **WebSocket** - Ensure WebSocket support in hosting environment
- **HTTPS** - Required for production WebSocket connections

---

## 🎯 **Current Project Structure**

```
andar_bahar_game/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   ├── card.dart                     # Playing card model
│   │   └── game_state.dart               # Game state management
│   ├── providers/
│   │   └── game_provider.dart            # Single-player state with AI
│   ├── screens/
│   │   ├── home_screen.dart              # Main menu with hover effects
│   │   ├── multiplayer_game_screen.dart  # Multiplayer interface
│   │   └── multiplayer_lobby_screen.dart # Room management
│   ├── services/
│   │   └── websocket_service.dart        # Real-time communication
│   └── widgets/
│       ├── animated_card_dealer.dart     # Card dealing animations
│       ├── betting_panel.dart            # Single-player betting
│       ├── card_widget.dart              # Card display
│       └── multiplayer_betting_panel.dart # Multiplayer betting
├── server/
│   ├── server.js                         # WebSocket server
│   ├── package.json                     # Dependencies
│   └── node-v22.17.0-win-x64/          # Bundled Node.js
├── docs/                                 # Complete documentation
└── assets/                               # Game assets
```

---

## 🏆 **Recent Improvements**

### **Animated Card Dealer System**

- **Flying Card Animations** - Cards fly from dealer to piles
- **Synchronized Multiplayer** - All players see same animations
- **Smooth Transitions** - Professional card dealing experience
- **Performance Optimized** - Efficient animation controllers

### **Enhanced UI/UX**

- **Hover Effects** - 1.05x scale animations on all interactive elements
- **Color Psychology** - Strategic blue/yellow color scheme
- **Accessibility** - WCAG AA compliant contrast ratios
- **Responsive Design** - Optimized for all screen sizes

### **Multiplayer Enhancements**

- **Global Room System** - Single room for all players
- **Real-time Animations** - Synchronized card dealing
- **Player Management** - Instant join/leave functionality
- **Winner Overlays** - Enhanced result displays

---

## 🎯 **Repository**

- **GitHub**: https://github.com/BhautikUltragames/Ander-Bahar.git
- **Includes**: Complete Flutter app + Node.js server with bundled runtime
- **Ready to Run**: Clone and play immediately

---

## 🔮 **Future Enhancements**

- **Sound Effects** - Audio feedback for game events
- **Tournament Mode** - Multi-round competitions
- **Statistics** - Player performance tracking
- **Themes** - Customizable card designs and backgrounds
- **Mobile Responsive** - Enhanced mobile browser support

---

## 🎯 **Performance**

- **Single Player**: Immediate startup, no network dependencies
- **Multiplayer**: Sub-100ms response times on local network
- **Web Optimized**: Smooth 60fps animations
- **Memory Efficient**: Proper cleanup of timers and connections

---

## 🌟 **Features Comparison**

| Feature           | Single Player | Multiplayer         |
| ----------------- | ------------- | ------------------- |
| Setup Required    | None          | Start server        |
| Players           | 1 vs AI       | 2-6 humans          |
| Internet Required | No            | Yes (local network) |
| Real-time Sync    | N/A           | Yes                 |
| Room Management   | N/A           | Yes                 |
| Instant Play      | Yes           | After server start  |
| Card Animations   | Yes           | Yes (synchronized)  |

---

## 📝 **License**

MIT License - Feel free to use and modify for your projects.

---

## 🤝 **Contributing**

1. Fork the repository
2. Create your feature branch
3. Test both single-player and multiplayer modes
4. Submit a pull request

---

## 📞 **Support**

For issues or questions:

1. Check the troubleshooting section in docs/
2. Review server logs for multiplayer issues
3. Check Flutter console for client-side errors
4. Ensure all prerequisites are met

---

**🎮 Ready to play the most authentic digital Andar Bahar experience! 🎮**
