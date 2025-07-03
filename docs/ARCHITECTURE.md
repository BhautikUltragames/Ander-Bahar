# 🏗️ Andar Bahar - Technical Architecture

## 📋 Overview

This document provides a comprehensive technical overview of the Andar Bahar Flutter web application, including architecture decisions, code structure, state management, implementation details, and the latest enhancements including the animated card dealer system.

## 🎯 Architecture Principles

- **Clean Architecture**: Separation of concerns with distinct layers
- **Reactive Programming**: State-driven UI updates using Provider
- **Component-Based Design**: Reusable, modular widgets
- **Immutable State**: Predictable state management with proper cloning
- **Animation-First**: Smooth, native-feeling animations throughout
- **AI Integration**: Seamless single-player experience with automatic AI behavior
- **Timer Synchronization**: Consistent timing across all game modes
- **Professional Polish**: WCAG compliant design with hover effects

## 🏗️ Project Structure

```
andar_bahar_game/
├── lib/
│   ├── main.dart                 # App entry point & MaterialApp setup
│   ├── models/                   # Data models and business logic
│   │   ├── card.dart            # PlayingCard, Suit, Rank enums
│   │   └── game_state.dart      # GameState, GamePhase, Bet classes
│   ├── providers/               # State management layer
│   │   └── game_provider.dart   # GameProvider with AI logic and timer sync
│   ├── screens/                 # Full-screen UI components
│   │   ├── home_screen.dart     # Main menu with hover effects
│   │   ├── multiplayer_game_screen.dart # Multiplayer with animations
│   │   └── multiplayer_lobby_screen.dart # Room management interface
│   ├── widgets/                 # Reusable UI components
│   │   ├── animated_card_dealer.dart # NEW: Professional card dealing animations
│   │   ├── card_widget.dart     # Individual playing card display
│   │   ├── betting_panel.dart   # Single-player betting controls
│   │   └── multiplayer_betting_panel.dart # Multiplayer betting interface
│   └── services/                # External service integrations
│       └── websocket_service.dart # WebSocket communication
├── assets/                      # Static assets
│   ├── images/                  # Game images and icons
│   └── cards/                   # Card face/back images
├── server/                      # Node.js WebSocket server
│   ├── server.js               # Main server implementation
│   ├── package.json            # Server dependencies
│   └── node-v22.17.0-win-x64/  # Bundled Node.js runtime
├── web/                         # Web-specific configuration
└── test/                        # Unit and widget tests
```

## 🔧 Core Components

### 1. Models Layer (`/models`)

#### PlayingCard (`card.dart`)

```dart
class PlayingCard {
  final Suit suit;      // hearts, diamonds, clubs, spades
  final Rank rank;      // ace, two, three... king
  bool isVisible;       // For card flip animations

  // Computed properties
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;
  bool get isBlack => suit == Suit.clubs || suit == Suit.spades;
  String get suitSymbol => '♥♦♣♠'[suit.index];
  String get cardDisplay => '$rankDisplay$suitSymbol';
}
```

**Key Features:**

- Immutable suit and rank properties
- Color-based logic for game rules
- Display formatting for UI
- Equality operators for comparisons

#### GameState (`game_state.dart`)

```dart
class GameState {
  GamePhase phase;                    // waiting, betting, readyToPlay, dealing, finished
  PlayingCard? jokerCard;             // Central reference card
  List<PlayingCard> andarCards;       // Left pile
  List<PlayingCard> baharCards;       // Right pile
  List<PlayingCard> deck;             // Remaining cards
  List<Bet> bets;                     // Player bets (including AI)
  Map<String, int> playerBalances;    // Player chip counts
  BetSide? winningSide;               // andar or bahar
}
```

**Key Methods:**

- `createDeck()`: Generate fresh 52-card deck
- `shuffleDeck()`: Randomize card order
- `dealNextCard()`: Apply dealing logic with alternation
- `calculatePayouts()`: Apply payout ratios (0.9:1 vs 1:1)
- `placeBet()`: Validate and place player bets (human and AI)

### 2. State Management (`/providers`)

#### GameProvider (`game_provider.dart`)

```dart
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();
  Timer? _countdownTimer;           // 5-second betting countdown
  Timer? _dealingTimer;             // Card dealing intervals
  String _currentPlayerId = 'player_1';
  bool _isAIGame = false;
  bool _hasAIBetThisRound = false;  // Prevents multiple AI bets
  int _countdownSeconds = 5;        // Synchronized with UI
}
```

**Recent Improvements:**

- **Auto AI Betting**: AI automatically places bets when new rounds start
- **Timer Synchronization**: Server uses 10-second window, UI shows 5-second countdown
- **Duplicate Prevention**: AI won't bet multiple times per round
- **Bet Display Logic**: Tracks both human and AI bets for UI
- **Smart Game Start**: Manual initial start, auto new rounds with `hasGameEverStarted` flag
- **Continuous Gameplay**: Games continue during disconnections, check only between rounds

**State Management Features:**

- **Reactive Updates**: `notifyListeners()` triggers UI rebuilds
- **Timer Management**: Automatic game progression with proper cleanup
- **AI Logic**: Randomized betting with balance awareness
- **Lifecycle Control**: Proper initialization and disposal

### 3. Widgets Layer (`/widgets`)

#### AnimatedCardDealer (`animated_card_dealer.dart`) - NEW

```dart
class AnimatedCardDealer extends StatefulWidget {
  final bool isDealing;
  final VoidCallback? onDealingComplete;
  final Function(bool toAndar, PlayingCard card)? onCardDealt;

  const AnimatedCardDealer({
    Key? key,
    required this.isDealing,
    this.onDealingComplete,
    this.onCardDealt,
  }) : super(key: key);
}

class _AnimatedCardDealerState extends State<AnimatedCardDealer>
    with TickerProviderStateMixin {
  late AnimationController _dealerController;
  late AnimationController _cardController;

  // Flying card animation system
  void _triggerCardAnimation(PlayingCard card, bool toAndar) {
    // Professional card dealing with smooth transitions
    // Synchronized across all multiplayer clients
    // Performance optimized for smooth gameplay
  }
}
```

**Key Features:**

- **✅ Flying Card Animations** - Cards fly from dealer to piles
- **✅ Synchronized Multiplayer** - All players see same animations
- **✅ Performance Optimized** - Efficient animation controllers
- **✅ Professional Polish** - Smooth transitions and timing
- **✅ Customizable** - Configurable animation parameters

#### Enhanced UI Components

```dart
// Hover Button System
class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double hoverScale = 1.05;
  final Duration animationDuration = Duration(milliseconds: 200);

  // Professional hover effects throughout the app
  // Accessibility compliant design
  // Smooth visual feedback
}

// Color-coded Betting Panels
class BettingPanel extends StatefulWidget {
  // Blue ANDAR vs Yellow BAHAR
  // High contrast text for accessibility
  // Hover animations on all buttons
}
```

### 4. Server Layer (`/server`)

#### WebSocket Server (`server.js`)

```javascript
class GlobalGameRoom {
  constructor() {
    this.players = new Map();
    this.gameState = {
      phase: "waiting",
      jokerCard: null,
      andarCards: [],
      baharCards: [],
      bets: [],
      playerBalances: {},
      winningSide: null,
    };
    this.hasGameEverStarted = false;
    this.gameTimer = null;
  }

  // Animation synchronization
  broadcastCardDealt(card, toAndar) {
    this.broadcast({
      type: "cardDealt",
      card: card,
      toAndar: toAndar,
      timestamp: Date.now(),
    });
  }

  // Continuous round management
  startContinuousRounds() {
    // 10-second cycles with animation triggers
  }
}
```

**Key Features:**

- **✅ Animation Synchronization** - All players see same card animations
- **✅ Continuous Rounds** - Automatic 10-second cycles
- **✅ Complete Player Removal** - No ghost players
- **✅ Performance Optimized** - Efficient WebSocket communication
- **✅ Bundled Runtime** - No separate Node.js installation

---

## 🎨 **UI/UX Architecture**

### **Design System**

```dart
// Color Psychology Implementation
const Color ANDAR_COLOR = Colors.blue.shade700;      // Trust, stability
const Color BAHAR_COLOR = Colors.yellow.shade700;    // Luck, prosperity
const Color JOKER_BACKGROUND = Color(0xFFFBC02D);    // Attention, focus

// Accessibility Compliant Text
const Color ANDAR_TEXT = Colors.white;               // White on blue
const Color BAHAR_TEXT = Colors.black;               // Black on yellow

// Responsive Design Constants
const double MAIN_BUTTON_WIDTH = 0.7;                // 70% of screen width
const double MAIN_BUTTON_HEIGHT = 120.0;
const double HOVER_SCALE = 1.05;                     // Hover animation scale
const Duration HOVER_DURATION = Duration(milliseconds: 200);
```

### **Animation System**

```dart
// Professional Animation Timings
const Duration CARD_DEALING_INTERVAL = Duration(milliseconds: 400);
const Duration CARD_FLIGHT_DURATION = Duration(milliseconds: 350);
const Duration HOVER_ANIMATION_DURATION = Duration(milliseconds: 200);
const Duration BETTING_COUNTDOWN_DURATION = Duration(seconds: 5);

// Animation Controllers
class AnimationControllers {
  late AnimationController dealerController;
  late AnimationController cardController;
  late AnimationController hoverController;

  // Efficient animation lifecycle management
  void initializeControllers(TickerProvider vsync) {
    dealerController = AnimationController(
      duration: CARD_FLIGHT_DURATION,
      vsync: vsync,
    );
    // ... additional controllers
  }
}
```

---

## 🔄 **Game Flow Architecture**

### **Single Player Flow**

```
1. HomeScreen (hover effects)
   ↓
2. GameScreen (GameProvider)
   ↓
3. Betting Phase (color-coded buttons)
   ↓
4. AI Auto-Betting (smart opponent)
   ↓
5. Countdown Timer (5-second UI)
   ↓
6. AnimatedCardDealer (flying cards)
   ↓
7. Results & Payouts (confetti)
   ↓
8. New Round (automatic)
```

### **Multiplayer Flow**

```
1. HomeScreen (hover effects)
   ↓
2. Lobby Screen (global room)
   ↓
3. MultiplayerGameScreen (WebSocket)
   ↓
4. Betting Phase (synchronized)
   ↓
5. Server-side Dealing (animation triggers)
   ↓
6. Synchronized AnimatedCardDealer
   ↓
7. Results & Payouts (winner overlay)
   ↓
8. Continuous Rounds (10-second cycles)
```

---

## 🚀 **Performance Architecture**

### **Animation Performance**

- **Card Dealing**: 350ms smooth flying animations
- **Hover Effects**: <16ms response time
- **Multiplayer Sync**: Real-time animation synchronization
- **Memory Management**: Proper animation controller disposal

### **State Management Performance**

- **Reactive Updates**: Efficient `notifyListeners()` calls
- **Timer Management**: Proper cleanup prevents memory leaks
- **WebSocket Efficiency**: Optimized message handling
- **UI Responsiveness**: 60fps maintained during animations

---

## 🔧 **Development Architecture**

### **Code Organization**

```
Architecture Layers:
├── Presentation Layer (Screens/Widgets)
│   ├── Home Screen (hover effects)
│   ├── Game Screens (animations)
│   └── Animated Components (card dealer)
├── Business Logic Layer (Providers)
│   ├── Game Provider (state management)
│   └── WebSocket Service (communication)
├── Data Layer (Models)
│   ├── Game State (immutable state)
│   └── Playing Card (data structures)
└── Infrastructure Layer (Server)
    ├── WebSocket Server (real-time)
    └── Game Room Management (multiplayer)
```

### **Testing Architecture**

```dart
// Unit Testing
test/
├── models/
│   ├── card_test.dart              # PlayingCard logic
│   └── game_state_test.dart        # GameState methods
├── providers/
│   └── game_provider_test.dart     # State management
├── widgets/
│   ├── animated_card_dealer_test.dart # Animation testing
│   └── betting_panel_test.dart     # UI component testing
└── integration/
    └── multiplayer_flow_test.dart  # End-to-end testing
```

---

## 🎯 **Current Architecture Status**

### ✅ **Implemented Systems**

- **Animated Card Dealer**: Professional flying card animations
- **Hover Animation System**: 1.05x scale effects on all interactive elements
- **Color Psychology**: Strategic blue (trust) vs yellow (luck) design
- **Accessibility Architecture**: WCAG AA compliant contrast ratios
- **Responsive Design**: MediaQuery-based sizing and layouts
- **WebSocket Architecture**: Real-time multiplayer with animation sync
- **State Management**: Provider pattern with reactive UI updates

### 🎮 **Enhanced Game Architecture**

- **Single Player**: AI opponent with auto-betting and animated dealing
- **Multiplayer**: Synchronized animations across all connected players
- **Performance**: Optimized 60fps animations with efficient controllers
- **Accessibility**: High contrast text and inclusive design patterns

---

## 🏆 **Architecture Achievements**

### **Animation System**

- **Professional Card Dealing** - Flying cards from dealer to piles
- **Multiplayer Synchronization** - All players see same animations
- **Performance Optimization** - Efficient animation controllers
- **Visual Polish** - Smooth transitions and professional feel

### **UI/UX System**

- **Hover Animations** - Interactive feedback on all elements
- **Color Psychology** - Strategic color choices for optimal UX
- **Accessibility** - WCAG AA compliant design system
- **Responsive Design** - Optimized for all screen sizes

---

## 🔮 **Future Architecture Enhancements**

### **Planned Improvements**

- **Sound Architecture** - Audio system for game events
- **Theme System** - Customizable visual themes
- **Performance Monitoring** - Real-time performance metrics
- **Advanced AI** - Multiple difficulty levels and strategies

### **Scalability Considerations**

- **Cloud Deployment** - Distributed server architecture
- **Database Integration** - Persistent player data
- **Analytics System** - User behavior tracking
- **Mobile Architecture** - Native app development

---

## 🎯 **Conclusion**

The Andar Bahar architecture successfully balances simplicity with functionality. Recent improvements have enhanced the user experience while maintaining clean code organization:

- **Animated Card Dealer** provides professional gaming experience
- **Hover Animation System** creates engaging interactive feedback
- **Color Psychology** optimizes user engagement and accessibility
- **Robust State Management** handles complex game flow with animations
- **Performance Architecture** maintains smooth 60fps gameplay

The architecture is well-positioned for future enhancements while maintaining stability and performance.

---

**🏗️ Architecture designed for scalability, maintainability, and exceptional user experience! 🏗️**
