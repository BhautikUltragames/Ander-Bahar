# 🏗️ Andar Bahar - Technical Architecture

## 📋 Overview

This document provides a comprehensive technical overview of the Andar Bahar Flutter web application, including architecture decisions, code structure, state management, and implementation details.

## 🎯 Architecture Principles

- **Clean Architecture**: Separation of concerns with distinct layers
- **Reactive Programming**: State-driven UI updates using Provider
- **Component-Based Design**: Reusable, modular widgets
- **Immutable State**: Predictable state management with proper cloning
- **Animation-First**: Smooth, native-feeling animations throughout

## 🏗️ Project Structure

```
andar_bahar_game/
├── lib/
│   ├── main.dart                 # App entry point & MaterialApp setup
│   ├── models/                   # Data models and business logic
│   │   ├── card.dart            # PlayingCard, Suit, Rank enums
│   │   └── game_state.dart      # GameState, GamePhase, Bet classes
│   ├── providers/               # State management layer
│   │   └── game_provider.dart   # GameProvider with ChangeNotifier
│   ├── screens/                 # Full-screen UI components
│   │   ├── home_screen.dart     # Main menu with game mode selection
│   │   └── game_screen.dart     # Game table and betting interface
│   ├── widgets/                 # Reusable UI components
│   │   ├── card_widget.dart     # Individual playing card display
│   │   └── betting_panel.dart   # Betting controls and chip selection
│   └── services/                # Future: API, WebSocket, Analytics
├── assets/                      # Static assets
│   ├── images/                  # Game images and icons
│   └── cards/                   # Card face/back images
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
  List<Bet> bets;                     // Player bets
  Map<String, int> playerBalances;    // Player chip counts
  BetSide? winningSide;               // andar or bahar
}
```

**Key Methods:**

- `createDeck()`: Generate fresh 52-card deck
- `shuffleDeck()`: Randomize card order
- `dealNextCard()`: Apply dealing logic with alternation
- `calculatePayouts()`: Apply payout ratios (0.9:1 vs 1:1)
- `placeBet()`: Validate and place player bets

### 2. State Management (`/providers`)

#### GameProvider (`game_provider.dart`)

```dart
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();
  Timer? _bettingTimer;  // Not used in current implementation
  Timer? _dealingTimer;  // Used for card dealing intervals
  String _currentPlayerId = 'player_1';
  bool _isAIGame = false;
}
```

**State Management Features:**

- **Reactive Updates**: `notifyListeners()` triggers UI rebuilds
- **Timer Management**: Automatic game progression
- **AI Logic**: Randomized betting with balance awareness
- **Lifecycle Control**: Proper initialization and cleanup

### GameProvider Methods

#### Timer Management

- `_startCountdownTimer()`: 5-second timer that auto-triggers dealing
- `_startDealing()`: Reveals joker, starts card dealing after 0.7s
- `_startDealingCards()`: Periodic timer (400ms) for card dealing

#### Game Actions

- `startNewRound()`: Resets game state, no automatic timers
- `shuffleDeck()`: Randomizes card order
- `placeBet(BetSide, int)`: Places bet using GameState.placeBet(), triggers countdown
- `rebet()`: Repeats last bet amount and side
- `_aiPlaceBet()`: AI places random bet when player bets
- `_startDealing()`: Reveals joker, starts card dealing after 0.7s
- `_dealNextCard()`: Processes individual card deals
- `_checkWinner()`: Evaluates winning conditions
- `_finishRound()`: Handles payouts, result display, round transition

### 3. UI Layer (`/screens` & `/widgets`)

#### HomeScreen (`home_screen.dart`)

```dart
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _button1SlideAnimation;  // Left entry
  late Animation<Offset> _button2SlideAnimation;  // Right entry
  late Animation<Offset> _button3SlideAnimation;  // Bottom entry
}
```

**Animation System:**

- **Staggered Animations**: Sequential button entrances
- **Curve Variations**: `easeOutBack` for bouncy effects
- **Interval-Based**: Precise timing control
- **Proper Disposal**: Memory leak prevention

#### GameScreen (`game_screen.dart`)

```dart
class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnimationController;

  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(/* Reactive UI based on gameProvider.gameState */);
      }
    );
  }
}
```

**UI Components:**

- **Reactive Rendering**: Consumer widget for state updates
- **Celebration Effects**: Confetti for wins
- **Responsive Layout**: Flexible design for web browsers
- **Game Table**: Visual card piles with animations

## 🔄 Data Flow

### 1. Game Initialization

```
User clicks "Human vs AI"
  → Navigator.push(GameScreen)
  → gameProvider.startAIGame()
  → Initialize balances & state
  → startNewRound()
  → Begin betting timer
```

### 2. Betting Phase

```
User selects bet amount
  → gameProvider.placeBet(side, amount)
  → Validate balance & phase
  → Update gameState.bets
  → notifyListeners()
  → UI updates with Consumer
  → AI makes counter-bet
  → Timer expires → transition to readyToPlay phase
```

### 3. Ready to Play Phase

```
Betting timer expires
  → gameState.phase = readyToPlay
  → Play button appears in UI
  → User clicks Play button
  → gameProvider.startPlaying()
  → _startDealing() called
```

### 4. Dealing Phase

```
startPlaying() triggered
  → _startDealing()
  → Reveal joker card
  → _startDealingCards()
  → Periodic timer (400ms)
  → dealNextCard() with alternation logic
  → Check winning condition
  → _finishRound() if match found
```

### 5. Result Phase

```
Match found
  → gameState.phase = finished
  → calculatePayouts()
  → applyPayouts() to balances
  → Show confetti celebration
  → Delay 1.5s → startNewRound()
```

## 🎨 Animation System

### Button Entrance Animations

```dart
// Staggered slide animations
_button1SlideAnimation = Tween<Offset>(
  begin: const Offset(-1.5, 0),  // From left
  end: Offset.zero,
).animate(CurvedAnimation(
  parent: _animationController,
  curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
));
```

### Card Dealing Animations

```dart
// Card appearance with slide effect
_cardSlideAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(CurvedAnimation(
  parent: _cardAnimationController,
  curve: Curves.easeOutBack,
));
```

### Celebration Effects

```dart
// Confetti burst on wins
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
)
```

## 🧪 Testing Strategy

### Unit Tests

- **Model Logic**: Card comparisons, deck generation
- **Game Rules**: Payout calculations, betting validation
- **State Management**: GameProvider methods and state transitions

### Widget Tests

- **UI Components**: Card rendering, button interactions
- **Animation Testing**: Animation controller behavior
- **State Integration**: Provider and Consumer interactions

### Integration Tests

- **Game Flow**: Complete game rounds from start to finish
- **AI Behavior**: Verify AI betting logic and responses
- **Timer Integration**: Betting and dealing timer accuracy

## 🔧 Configuration & Customization

### Game Parameters (`game_provider.dart`)

```dart
const Duration BETTING_TIME = Duration(seconds: 8);
const Duration DEALING_INTERVAL = Duration(milliseconds: 400);
const Duration RESULT_DISPLAY = Duration(milliseconds: 1500);
const int STARTING_BALANCE = 5000;
const List<int> BET_AMOUNTS = [25, 50, 100, 250];
```

### Animation Timings (`home_screen.dart`)

```dart
const Duration ANIMATION_DURATION = Duration(milliseconds: 2000);
const Interval BUTTON1_INTERVAL = Interval(0.3, 0.7);
const Interval BUTTON2_INTERVAL = Interval(0.5, 0.9);
const Interval BUTTON3_INTERVAL = Interval(0.7, 1.0);
```

### UI Theming

```dart
// Gradient backgrounds
RadialGradient(
  colors: [Colors.green.shade700, Colors.green.shade900],
)

// Card table colors
const Color ANDAR_COLOR = Colors.blue;
const Color BAHAR_COLOR = Colors.red;
const Color JOKER_BACKGROUND = Colors.yellow;
```

## 🚀 Performance Optimizations

### State Management

- **Selective Rebuilds**: Consumer widgets only rebuild when needed
- **Immutable State**: Prevents accidental mutations
- **Efficient Comparisons**: Proper equality operators

### Animation Performance

- **Hardware Acceleration**: Transform-based animations
- **Proper Disposal**: AnimationController cleanup
- **Optimized Curves**: Efficient easing functions

### Memory Management

- **Timer Cleanup**: Cancel timers in dispose()
- **Widget Disposal**: Proper StatefulWidget cleanup
- **Asset Optimization**: Efficient image loading

## 🔮 Extension Points

### Multiplayer Integration

```dart
// Future WebSocket integration
abstract class MultiplayerService {
  Stream<GameEvent> get gameEvents;
  Future<void> sendBet(BetSide side, int amount);
  Future<void> joinRoom(String roomId);
}
```

### Analytics Integration

```dart
// Future analytics tracking
abstract class AnalyticsService {
  void trackGameStart(bool isAIGame);
  void trackBetPlaced(BetSide side, int amount);
  void trackGameEnd(bool playerWon, int finalBalance);
}
```

### Sound System

```dart
// Future audio integration
abstract class AudioService {
  Future<void> playCardDealing();
  Future<void> playWinSound();
  Future<void> playBackgroundMusic();
}
```

## 🐛 Error Handling

### Graceful Degradation

- **Timer Failures**: Fallback to manual progression
- **Animation Errors**: Skip animations, maintain functionality
- **State Corruption**: Reset to safe state

### Logging Strategy

```dart
// Debug logging for development
if (kDebugMode) {
  print('GameProvider: ${gameState.phase} -> ${newPhase}');
}
```

## 📚 Dependencies

### Core Dependencies

```yaml
flutter: sdk: flutter
provider: ^6.1.1          # State management
confetti: ^0.7.0          # Win celebrations
```

### Future Dependencies

```yaml
socket_io_client: ^2.0.3+1 # Real-time multiplayer
http: ^1.1.0 # REST API communication
shared_preferences: ^2.2.2 # Local storage
```

## 🔐 Security Considerations

### Client-Side Security

- **No Sensitive Data**: All game logic is client-side
- **Virtual Currency**: No real money transactions
- **State Validation**: Prevent invalid game states

### Future Security (Multiplayer)

- **Authentication**: Secure user login
- **Anti-Cheat**: Server-side game state validation
- **Rate Limiting**: Prevent abuse of game actions

---

This architecture provides a solid foundation for the current single-player/AI implementation while being extensible for future multiplayer, analytics, and enhanced features.

🏗️ **Architecture designed for scalability and maintainability** 🏗️

### Game State Management

```dart
enum GamePhase {
  waiting,     // Waiting for players
  betting,     // Betting phase (no timer)
  readyToPlay, // 5-second automatic countdown
  dealing,     // Cards being dealt
  finished,    // Round complete
  showResult   // Displaying results
}
```

### State Flow

1. **betting** → **readyToPlay**: User clicks ANDAR/BAHAR, countdown begins immediately
2. **readyToPlay** → **dealing**: 5-second countdown reaches 0, cards start dealing
3. **dealing** → **finished**: Matching card found
4. **finished** → **showResult**: Brief result display (1.5s)
5. **showResult** → **betting**: New round begins after 2s (no timer)

### Current Implementation Details

#### GameProvider Structure

```dart
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();
  Timer? _bettingTimer;  // Not used in current implementation
  Timer? _dealingTimer;  // Used for card dealing intervals
  String _currentPlayerId = 'player_1';
  bool _isAIGame = false;
}
```

#### Key Methods

- `startAIGame()`: Initializes Human vs AI game with 5000 starting balance
- `startNewRound()`: Resets game state, no automatic timers
- `placeBet(BetSide, int)`: Places bet using GameState.placeBet(), triggers countdown
- `_aiPlaceBet()`: AI places random bet when player bets
- `_startCountdownTimer()`: 5-second timer that auto-triggers dealing
- `_startDealing()`: Reveals joker, starts card dealing after 0.7s
- `_startDealingCards()`: Periodic timer (400ms) for card dealing
- `_finishRound()`: Handles payouts, result display, round transition
