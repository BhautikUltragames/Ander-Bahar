# Development Guide - Andar Bahar Game

## 🚀 Current Project Status

### ✅ **Completed Features**

- **Single Player Mode**: Fully functional with AI opponent that auto-bets at round start
- **Multiplayer Mode**: Complete WebSocket-based real-time multiplayer
- **Flutter Web Implementation**: Responsive design for browsers
- **Game Logic**: Complete Andar Bahar rules implementation
- **UI/UX**: Animated home screen with gradient backgrounds and bet summaries
- **Betting System**: Multiple chip values and balance tracking
- **Celebrations**: Confetti animations for wins
- **Server Infrastructure**: Node.js WebSocket server with bundled runtime
- **Auto AI Betting**: AI automatically places bets when new rounds start
- **Timer Synchronization**: 5-second countdown matches UI display
- **Enhanced Winner Display**: "You Win!" / "You Lose" text in multiplayer

### ✅ **Resolved Issues**

- **Multiplayer Setup**: Simplified with bundled Node.js (no separate installation)
- **WebSocket Connection**: Stable real-time communication
- **Room Management**: Create/join rooms functionality working perfectly
- **PowerShell Support**: Proper batch file execution on Windows
- **Cross-Platform**: Works on Windows, Linux, and Mac
- **AI Betting Logic**: Fixed to prevent multiple bets per round
- **Timer Architecture**: Server uses 10-second betting window with 5-second UI countdown
- **UI Feedback**: Added bet summaries and enhanced winner overlays

### 🎯 **Current Status: Production Ready**

Both single-player and multiplayer modes are fully functional and ready for immediate use. Recent improvements have enhanced the gameplay experience significantly.

## 🛠️ Development Environment Setup

### **Prerequisites**

- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Chrome browser for web development
- Git for version control
- **Note**: Node.js is bundled with the project - no separate installation needed!

### **Quick Setup**

#### **Windows (PowerShell)**

```powershell
# Clone repository
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game

# Install Flutter dependencies
flutter pub get

# For single-player only
flutter run -d chrome

# For multiplayer (requires 2 terminals)
# Terminal 1: Start server
.\start_server.bat

# Terminal 2: Start Flutter app
flutter run -d chrome
```

#### **Linux/Mac**

```bash
# Clone repository
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game

# Install Flutter dependencies
flutter pub get

# For single-player only
flutter run -d chrome

# For multiplayer (requires 2 terminals)
# Terminal 1: Start server
chmod +x start_server.sh
./start_server.sh

# Terminal 2: Start Flutter app
flutter run -d chrome
```

## 📁 Architecture Overview

### **Client Architecture (Flutter)**

```
lib/
├── main.dart                    # App entry point with providers
├── models/
│   ├── card.dart               # PlayingCard, Suit, Rank models
│   └── game_state.dart         # GamePhase, GameState enums
├── providers/
│   └── game_provider.dart      # Single-player state management with AI logic
├── services/
│   └── websocket_service.dart  # Multiplayer WebSocket communication
├── screens/
│   ├── home_screen.dart        # Main menu with mode selection
│   ├── game_screen.dart        # Single-player game interface with bet display
│   ├── multiplayer_lobby_screen.dart  # Room management
│   └── multiplayer_game_screen.dart   # Multiplayer game interface with winner overlay
└── widgets/
    ├── betting_panel.dart      # Single-player betting UI
    ├── multiplayer_betting_panel.dart  # Multiplayer betting UI
    └── card_widget.dart        # Card display component
```

### **Server Architecture (Node.js)**

```
server/
├── server.js                   # Main WebSocket server
├── package.json               # Dependencies and scripts
├── README.md                  # Server-specific documentation
├── node-v22.17.0-win-x64/    # Bundled Node.js runtime (Windows)
└── node-portable.zip         # Portable Node.js archive
```

## 🎮 Game Flow Implementation

### **Single Player Flow**

1. **HomeScreen** → User clicks "HUMAN vs AI"
2. **GameScreen** → GameProvider manages state
3. **Betting Phase** → User selects amount and side
4. **Auto AI Bet** → AI automatically places counter-bet
5. **Countdown** → 5-second timer (synchronized with UI)
6. **Dealing** → Cards dealt with 400ms intervals
7. **Results** → Winner determined, balances updated
8. **Bet Summary** → Display both human and AI bets with chosen sides
9. **Repeat** → New round starts automatically

### **Multiplayer Flow** (Server Running)

1. **HomeScreen** → User clicks "MULTIPLAYER"
2. **MultiplayerLobbyScreen** → WebSocketService connects to server
3. **Room Management** → Create/join rooms with unique IDs
4. **MultiplayerGameScreen** → Synchronized gameplay
5. **Betting Phase** → All players bet within 5 seconds
6. **Dealing** → Server-authoritative card dealing
7. **Results** → Synchronized results and payouts
8. **Winner Overlay** → Display "You Win!" / "You Lose" with detailed results for 5 seconds
9. **Next Round** → Automatic progression

## 🔧 Key Components

### **GameProvider (Single Player)**

```dart
class GameProvider extends ChangeNotifier {
  // Manages single-player game state
  // Handles AI opponent logic with auto-betting
  // Controls timing and animations
  // Updates balances and statistics
  // Prevents multiple AI bets per round
}
```

**Key Methods:**

- `startNewRound()`: Initialize new game round with AI auto-bet
- `placeBet(BetSide, int)`: Place player bet and trigger AI counter-bet
- `_aiPlaceBet()`: AI automatically places bet at round start
- `_startCountdownTimer()`: 5-second timer synchronized with UI
- `_startDealing()`: Begin card dealing sequence
- `_checkWinner()`: Determine winning side
- `_finishRound()`: Handle payouts and cleanup

**Recent Improvements:**

- **Auto AI Betting**: AI now bets automatically when new rounds start
- **Duplicate Prevention**: AI won't place multiple bets per round
- **Timer Sync**: Fixed countdown from 10 to 5 seconds to match UI
- **Bet Display**: Shows both human and AI bets with chosen sides

### **WebSocketService (Multiplayer)**

```dart
class WebSocketService extends ChangeNotifier {
  // Manages WebSocket connection to server
  // Handles room creation/joining
  // Synchronizes game state across clients
  // Manages player data and balances
}
```

**Key Methods:**

- `connect()`: Establish WebSocket connection
- `createRoom(String)`: Create new game room
- `joinRoom(String, String)`: Join existing room
- `placeBet(String, int)`: Place synchronized bet
- `startGame()`: Host-only game initiation

### **Game State Management**

- **Single Player**: Provider pattern with ChangeNotifier and AI logic
- **Multiplayer**: Server-authoritative with WebSocket sync
- **UI Updates**: Reactive updates through Provider/Consumer
- **Timer Consistency**: Synchronized 5-second countdown across all modes

## 🎨 UI Implementation

### **Animation System**

- **Home Screen**: Staggered button slide animations (left, right, bottom entry)
- **Card Dealing**: Smooth card appearance with 400ms intervals
- **Celebrations**: Confetti effects on wins using confetti package
- **Transitions**: Smooth page transitions and state changes

### **Responsive Design**

- **Web-Optimized**: Designed primarily for browser gameplay
- **Flexible Layout**: Adapts to different screen sizes
- **Material Design**: Consistent with Flutter design principles

### **Enhanced UI Elements**

- **Bet Summary Display**: Shows both human and AI bets with chosen sides
- **Winner Overlay**: Enhanced multiplayer results with personalized messages
- **Timer Display**: Consistent 5-second countdown visualization
- **Game State Feedback**: Clear visual indicators for current game phase

## 🔧 Recent Development Changes

### **AI Betting System Enhancement**

```dart
// In GameProvider.startNewRound()
void startNewRound() {
  // ... existing code ...

  // Auto-place AI bet if this is a single-player game
  if (_isAIGame && !_hasAIBetThisRound) {
    Future.microtask(() => _aiPlaceBet());
  }

  notifyListeners();
}

void _aiPlaceBet() {
  if (_hasAIBetThisRound) return; // Prevent multiple bets

  // AI betting logic
  final random = Random();
  final betAmount = [25, 50, 100, 250, 500][random.nextInt(5)];
  final betSide = random.nextBool() ? BetSide.andar : BetSide.bahar;

  _gameState.placeBet('ai_player', betSide, betAmount);
  _hasAIBetThisRound = true;

  notifyListeners();
}
```

### **Timer Synchronization Fix**

```dart
// Fixed countdown timer duration
void _startCountdownTimer() {
  _countdownSeconds = 5; // Changed from 10 to 5
  _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    _countdownSeconds--;
    if (_countdownSeconds <= 0) {
      _countdownTimer?.cancel();
      _startDealing();
    }
    notifyListeners();
  });
}
```

### **UI Enhancement - Bet Summary Display**

```dart
// In game_screen.dart
Widget _buildBetSummary() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Text('Current Bets', style: TextStyle(color: Colors.white, fontSize: 18)),
        // Display human and AI bets with chosen sides
        _buildBetInfo('You', humanBet),
        _buildBetInfo('AI', aiBet),
      ],
    ),
  );
}
```

### **Multiplayer Winner Overlay Enhancement**

```dart
// In multiplayer_game_screen.dart
Widget _buildWinnerOverlay() {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isWinner ? 'You Win!' : 'You Lose!',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.green : Colors.red,
          ),
        ),
        // Additional winner details
        _buildWinnerDetails(),
      ],
    ),
  );
}
```

## 🧪 Testing & Debugging

### **Single Player Testing**

```bash
# Test AI auto-betting
1. Run flutter run -d chrome
2. Click "HUMAN vs AI"
3. Place a bet
4. Verify AI automatically places counter-bet
5. Check bet summary display shows both bets
6. Verify 5-second countdown matches UI
```

### **Multiplayer Testing**

```bash
# Test enhanced winner display
1. Start server with .\start_server.bat
2. Run flutter run -d chrome
3. Create/join multiplayer room
4. Play game with multiple players
5. Verify winner overlay shows "You Win!" / "You Lose!"
6. Check detailed winner information display
```

### **Common Debug Commands**

```bash
# Flutter debugging
flutter analyze                 # Check for code issues
flutter doctor                  # Verify Flutter setup
flutter clean && flutter pub get  # Clean rebuild

# Server debugging
# Check server logs for WebSocket connections
# Verify port 8080 is available
# Test with multiple browser tabs
```

## 🚀 Build & Deployment

### **Development Build**

```bash
# Hot reload development
flutter run -d chrome --web-port 8000

# Debug build with verbose output
flutter run -d chrome --verbose
```

### **Production Build**

```bash
# Build optimized web version
flutter build web --release

# Build output location: build/web/
# Deploy build/web/ folder to web server
```

### **Server Deployment**

```bash
# For local network deployment
# Copy entire server/ folder including bundled Node.js
# Run start_server.bat (Windows) or start_server.sh (Linux/Mac)

# For cloud deployment
# Use server/server.js with cloud Node.js runtime
# Configure WebSocket port and CORS settings
```

## 📊 Code Quality & Maintenance

### **Code Structure**

- **Clean Architecture**: Separation of concerns with distinct layers
- **Provider Pattern**: Reactive state management
- **Component Reusability**: Modular widget design
- **Error Handling**: Comprehensive error management
- **Memory Management**: Proper disposal of timers and controllers

### **Performance Optimization**

- **Efficient Rendering**: Consumer widgets for targeted updates
- **Timer Management**: Proper cleanup of periodic timers
- **Memory Leaks**: Disposal of animation controllers and WebSocket connections
- **Bundle Size**: Optimized for web deployment

### **Future Development Guidelines**

1. **Maintain AI Logic**: Keep auto-betting system simple and fair
2. **Timer Consistency**: Ensure all timers match UI displays
3. **UI Feedback**: Always provide clear visual feedback for user actions
4. **Error Handling**: Gracefully handle network and game state errors
5. **Cross-Platform**: Test on multiple browsers and operating systems

## 🔮 Development Roadmap

### **Short Term Enhancements**

- [ ] Add sound effects for game events
- [ ] Implement game statistics tracking
- [ ] Add player customization options
- [ ] Improve mobile browser responsiveness

### **Medium Term Features**

- [ ] Tournament mode with multiple rounds
- [ ] Spectator mode for multiplayer games
- [ ] Chat functionality in multiplayer rooms
- [ ] Advanced AI strategies and difficulty levels

### **Long Term Vision**

- [ ] Cloud-hosted multiplayer servers
- [ ] User authentication and persistent profiles
- [ ] Mobile app versions (iOS/Android)
- [ ] Integration with analytics and crash reporting

## 🎯 Conclusion

The Andar Bahar game development is complete with all major features implemented and working correctly. The recent improvements have significantly enhanced the user experience:

- **Automatic AI betting** creates engaging single-player gameplay
- **Synchronized timers** ensure consistent game flow
- **Enhanced UI elements** provide better visual feedback
- **Reliable server setup** with bundled Node.js

The codebase is well-structured, maintainable, and ready for future enhancements. Both single-player and multiplayer modes provide excellent user experiences and are ready for production deployment.

## 📝 Development Notes

### **Current Architecture Decisions**

- **Flutter Web**: Chosen for cross-platform compatibility
- **Provider Pattern**: Simple state management for single-player
- **WebSocket**: Real-time communication for multiplayer
- **Node.js Server**: Lightweight server for room management

### **Technical Debt**

- WebSocket error handling needs improvement
- Better separation of concerns in UI components
- More comprehensive testing coverage
- Documentation could be more detailed

### **Lessons Learned**

- Flutter web is excellent for game development
- WebSocket setup requires careful error handling
- User experience is crucial - single-player mode should work immediately
- Documentation is essential for multiplayer setup

This development guide reflects the current state of the project and provides a roadmap for future improvements.

## 🚀 Quick Start for Developers

### Prerequisites

- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: Included with Flutter
- **Chrome Browser**: For web debugging
- **VS Code** (recommended) or **Android Studio**
- **Git**: For version control

### Development Setup

1. **Clone and Setup**

   ```bash
   git clone <repository-url>
   cd andar_bahar_game
   flutter pub get
   ```

2. **Verify Installation**

   ```bash
   flutter doctor        # Check Flutter installation
   flutter devices       # Verify web support
   ```

3. **Run Development Server**

   ```bash
   flutter run -d chrome --hot-reload
   ```

4. **Run Tests**
   ```bash
   flutter test                    # Unit tests
   flutter test --coverage       # With coverage report
   ```

## 📁 Codebase Navigation

### Key Files to Understand First

1. **`lib/main.dart`** - App entry point and routing
2. **`lib/providers/game_provider.dart`** - Core game logic and state
3. **`lib/models/game_state.dart`** - Game data structures
4. **`lib/screens/home_screen.dart`** - Main menu with animations
5. **`lib/screens/game_screen.dart`** - Game playing interface

### Development Workflow

```
Feature Development Flow:
1. Create feature branch from main
2. Implement changes with tests
3. Run flutter analyze & tests
4. Test in browser thoroughly
5. Create pull request
6. Code review and merge
```

## 🧪 Testing Guidelines

### Test Structure

```
test/
├── unit/
│   ├── models/
│   │   ├── card_test.dart          # PlayingCard logic tests
│   │   └── game_state_test.dart    # GameState method tests
│   └── providers/
│       └── game_provider_test.dart # Game logic tests
├── widget/
│   ├── screens/
│   │   ├── home_screen_test.dart   # UI component tests
│   │   └── game_screen_test.dart   # Game interface tests
│   └── widgets/
│       ├── card_widget_test.dart   # Card display tests
│       └── betting_panel_test.dart # Betting UI tests
└── integration/
    └── game_flow_test.dart         # End-to-end tests
```

### Writing Tests

#### Unit Test Example

```dart
// test/unit/models/card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:andar_bahar_game/models/card.dart';

void main() {
  group('PlayingCard', () {
    test('should identify red cards correctly', () {
      final heartCard = PlayingCard(suit: Suit.hearts, rank: Rank.ace);
      final spadeCard = PlayingCard(suit: Suit.spades, rank: Rank.ace);

      expect(heartCard.isRed, true);
      expect(spadeCard.isRed, false);
    });

    test('should compare ranks correctly', () {
      final card1 = PlayingCard(suit: Suit.hearts, rank: Rank.seven);
      final card2 = PlayingCard(suit: Suit.clubs, rank: Rank.seven);

      expect(card1.hasSameRank(card2), true);
    });
  });
}
```

#### Widget Test Example

```dart
// test/widget/widgets/card_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:andar_bahar_game/widgets/card_widget.dart';
import 'package:andar_bahar_game/models/card.dart';

void main() {
  testWidgets('CardWidget displays card information', (tester) async {
    final card = PlayingCard(suit: Suit.hearts, rank: Rank.ace, isVisible: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardWidget(card: card),
        ),
      ),
    );

    expect(find.text('A♥'), findsOneWidget);
  });
}
```

### Test Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/card_test.dart

# Run with coverage
flutter test --coverage

# Run tests in watch mode during development
flutter test --watch
```

## 🎨 UI Development Guidelines

### Animation Best Practices

1. **Use SingleTickerProviderStateMixin** for single animations
2. **Use TickerProviderStateMixin** for multiple animations
3. **Always dispose AnimationControllers** in dispose()
4. **Use Intervals** for staggered animations

```dart
// Good animation implementation
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Important!
    super.dispose();
  }
}
```

### Responsive Design

```dart
// Use MediaQuery for responsive layouts
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;

  return Container(
    padding: EdgeInsets.all(isMobile ? 16 : 32),
    child: // Your widget
  );
}
```

### Color Scheme

```dart
// Consistent color usage
class AppColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color andarBlue = Color(0xFF1976D2);
  static const Color baharRed = Color(0xFFD32F2F);
  static const Color jokerYellow = Color(0xFFFBC02D);
}
```

## 🔧 State Management Patterns

### Provider Pattern Implementation

```dart
// Using Consumer for reactive UI
Consumer<GameProvider>(
  builder: (context, gameProvider, child) {
    return Text('Balance: ${gameProvider.getPlayerBalance("player_1")}');
  },
)

// Using Provider.of for non-reactive access
final gameProvider = Provider.of<GameProvider>(context, listen: false);
gameProvider.placeBet(BetSide.andar, 100);
```

### State Update Best Practices

```dart
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();

  // Good: Clear method names and validation
  bool placeBet(BetSide side, int amount) {
    if (_gameState.phase != GamePhase.betting) return false;
    if (!_hasEnoughBalance(amount)) return false;

    _gameState = _gameState.copyWith(
      bets: [..._gameState.bets, Bet(side: side, amount: amount)]
    );

    notifyListeners(); // Trigger UI update
    return true;
  }

  bool _hasEnoughBalance(int amount) {
    return _gameState.playerBalances[_currentPlayerId] >= amount;
  }
}
```

## 🚨 Debugging Tips

### Common Issues and Solutions

1. **Hot Reload Not Working**

   ```bash
   # Restart with clean build
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

2. **Animation Jank**

   ```dart
   // Use Transform instead of changing size/position
   Transform.translate(
     offset: Offset(x, y),
     child: myWidget,
   )
   ```

3. **Memory Leaks from Timers**

   ```dart
   Timer? _myTimer;

   @override
   void dispose() {
     _myTimer?.cancel(); // Always cancel timers
     super.dispose();
   }
   ```

### Debug Tools

```dart
// Debug prints for development
if (kDebugMode) {
  print('Game phase changed: ${gameState.phase}');
}

// Flutter Inspector for widget tree
// DevTools for performance analysis
// Network tab for future API calls
```

## 📝 Code Style Guidelines

### Dart/Flutter Conventions

```dart
// Good naming conventions
class GameProvider extends ChangeNotifier {} // PascalCase for classes
void startNewRound() {}                      // camelCase for methods
final int _privateField = 0;                 // _underscore for private
const Duration BETTING_TIME = Duration(seconds: 8); // UPPER_CASE for constants

// Good documentation
/// Calculates payout based on bet amount and winning side.
///
/// Returns the total payout including the original bet amount.
/// Andar wins pay 0.9:1, Bahar wins pay 1:1.
int calculatePayout(int betAmount, BetSide winningSide) {
  // Implementation
}
```

### Code Organization

```dart
// Order class members consistently
class MyWidget extends StatefulWidget {
  // 1. Final fields
  final String title;

  // 2. Constructor
  const MyWidget({Key? key, required this.title}) : super(key: key);

  // 3. Override methods
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 1. Fields
  late AnimationController _controller;

  // 2. Lifecycle methods (in order)
  @override
  void initState() { super.initState(); }

  @override
  void dispose() { super.dispose(); }

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 4. Private helper methods
  void _privateMethod() {}
}
```

## 🔄 Git Workflow

### Branch Naming

```
feature/add-sound-effects
bugfix/fix-animation-memory-leak
hotfix/betting-timer-issue
chore/update-dependencies
```

### Commit Messages

```
feat: add confetti celebration for wins
fix: prevent memory leak in animation controller
docs: update README with installation steps
test: add unit tests for card comparison logic
refactor: extract betting logic into separate method
```

### Pull Request Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing

- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Animation performance verified

## Screenshots/GIFs

[If applicable]
```

## 🚀 Performance Optimization

### Build Performance

```bash
# Analyze bundle size
flutter build web --analyze-size

# Profile build performance
flutter build web --profile
```

### Runtime Performance

```dart
// Use const constructors when possible
const Text('Static text');

// Minimize Widget rebuilds
Consumer<GameProvider>(
  builder: (context, provider, child) {
    return Column(
      children: [
        child!, // Cached widget
        Text('Dynamic: ${provider.balance}'),
      ],
    );
  },
  child: const ExpensiveWidget(), // Built once, reused
);
```

## 🔮 Future Development Areas

### Planned Features

- [ ] **Real-time Multiplayer**: WebSocket integration
- [ ] **Sound System**: Audio feedback and music
- [ ] **Statistics**: Player performance tracking
- [ ] **Tournaments**: Competitive gameplay modes
- [ ] **Mobile Apps**: Android and iOS versions

### Technical Improvements

- [ ] **PWA Support**: Progressive Web App features
- [ ] **Offline Mode**: Local gameplay capability
- [ ] **Analytics**: User behavior tracking
- [ ] **Localization**: Multi-language support

## 📚 Learning Resources

### Flutter/Dart

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

### Game Development

- [Flutter Games Toolkit](https://flutter.dev/games)
- [Animation and Motion](https://flutter.dev/docs/development/ui/animations)
- [State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

## 🆘 Getting Help

### Internal Resources

- Code comments and documentation
- Architecture.md for technical details
- GameRules.md for business logic

### External Support

- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Discord](https://discord.gg/flutter)

---

Happy coding! 🎮 Remember to write tests, document your code, and have fun building awesome gaming experiences!

💻 **Code with passion, test with precision!** 💻

## 🔧 Current Implementation Status

### ✅ **Working Features**

- **Immediate Betting Response**: Countdown starts instantly when ANDAR/BAHAR clicked
- **AI Opponent**: Automatically places random bets when player bets
- **Automatic Game Flow**: No manual intervention needed after bet placement
- **Timer Management**: 10-second server betting (5-second UI) → 0.7s joker reveal → 400ms card dealing
- **State Management**: Proper GameState integration with Provider pattern
- **Balance Management**: Correct player/AI balance tracking using playerBalances map
- **Payout System**: Automatic calculation and distribution of winnings
- **Animations**: Smooth card dealing, confetti celebrations, countdown display

### 🎮 **Current Game Flow**

1. **Start**: Game begins in betting phase ("Choose Your Side & Amount")
2. **Bet**: User clicks ANDAR/BAHAR → Immediate countdown trigger
3. **AI Response**: AI automatically places counter-bet
4. **Countdown**: 5-second timer with visual feedback
5. **Dealing**: Automatic card dealing with 400ms intervals after 0.7s joker reveal
6. **Results**: Winner determination, payouts, celebrations
7. **Loop**: New round after 3.5s total delay

### 🏗️ **Architecture Decisions**

#### State Management

```dart
// Using existing GameState structure
class GameState {
  Map<String, int> playerBalances;  // Multi-player balance tracking
  List<Bet> bets;                   // All bets with playerId
  bool placeBet(BetSide, int, String playerId);  // Existing method
}

// GameProvider integration
void placeBet(BetSide side, int amount) {
  bool success = _gameState.placeBet(side, amount, _currentPlayerId);
  if (success) {
    _aiPlaceBet();  // Trigger AI response
    _startCountdownTimer();  // Begin countdown
  }
}
```

#### Timer Strategy

- **No Betting Timer**: Removed pressure, player-paced betting
- **Immediate Countdown**: Responsive to user action
- **Automatic Progression**: Smooth game flow without manual intervention

## Testing Disconnection Handling

### Winner Screen Stuck Issue Fix

**Problem**: When Player A and Player B are playing and Player B leaves the game, Player A's screen gets stuck on the winner screen instead of transitioning to the waiting screen.

**Solution**:

1. **Client-side**: Winner overlay shows during `GamePhase.showResult` (games continue even if players disconnect)
2. **Server-side**: Games continue running when players disconnect during active gameplay
3. **New round check**: Player count is only checked when starting new rounds (after win/lose screen)
4. **State cleanup**: Clean game state reset only when transitioning to waiting phase between rounds

**Test Scenarios**:

**Initial Game Start**:

1. Start server: `cd server && node server.js`
2. Open two browser tabs with the game
3. Create room in first tab, join with second tab
4. Verify game does NOT auto-start when Player B joins
5. Host must click "START GAME" button to begin

**New Round Auto-Start**:

1. Complete a full round (reach winner screen)
2. If Player B leaves, first tab shows waiting screen
3. When Player B rejoins (or new player joins), new round auto-starts after 2 seconds
4. No manual "START GAME" needed for subsequent rounds

**Key Changes**:

- Winner overlay displays during showResult phase: `wsService.getGamePhase() == GamePhase.showResult`
- Server allows games to continue when players disconnect during betting/dealing
- Player count only checked when starting new rounds (in `finishRound()` function)
- Added `hasGameEverStarted` flag to distinguish initial vs. subsequent game starts
- Initial game requires host to manually click "START GAME"
- New rounds auto-start when sufficient players join (after game has been started once)
- Clean transition to waiting phase only between rounds, not during active gameplay
- Enhanced logging for debugging disconnection scenarios
