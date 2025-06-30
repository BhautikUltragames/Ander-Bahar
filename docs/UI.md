# 🎨 UI Design Documentation

## 📋 Overview

This document provides comprehensive documentation of the UI design system, components, layouts, and visual patterns used in the Andar Bahar Flutter web game. Use this as a reference for maintaining consistency and implementing new features.

## 🎨 Design System

### Color Palette

#### Primary Colors

```dart
// Background Gradients
RadialGradient homeBackground = RadialGradient(
  center: Alignment.center,
  radius: 1.2,
  colors: [
    Colors.orange.shade600,    // #FF8F00
    Colors.red.shade700,       // #D32F2F
    Colors.red.shade900,       // #B71C1C
  ],
);

RadialGradient gameBackground = RadialGradient(
  center: Alignment.center,
  radius: 1.5,
  colors: [
    Colors.green.shade700,     // #388E3C
    Colors.green.shade800,     // #2E7D32
    Colors.green.shade900,     // #1B5E20
  ],
);
```

#### Game Element Colors

```dart
// Card Table Colors
const Color ANDAR_COLOR = Color(0xFF1976D2);     // Blue
const Color BAHAR_COLOR = Color(0xFF388E3C);     // Green
const Color JOKER_BACKGROUND = Color(0xFFFBC02D); // Yellow

// Button Colors
LinearGradient humanVsAIGradient = LinearGradient(
  colors: [Colors.blue.shade600, Colors.blue.shade800]
);

LinearGradient multiplayerGradient = LinearGradient(
  colors: [Colors.green.shade600, Colors.green.shade800]
);

// Text Colors
const Color PRIMARY_TEXT = Colors.white;
const Color SECONDARY_TEXT = Color(0xB3FFFFFF); // 70% white
const Color TERTIARY_TEXT = Color(0x99FFFFFF);  // 60% white
```

#### Status Colors

```dart
const Color SUCCESS_COLOR = Color(0xFF4CAF50);
const Color ERROR_COLOR = Color(0xFFF44336);
const Color WARNING_COLOR = Color(0xFFFF9800);
const Color INFO_COLOR = Color(0xFF2196F3);
```

### Typography

#### Font Hierarchy

```dart
// Title Text (Home Screen)
TextStyle titleLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  shadows: [
    Shadow(
      color: Colors.black54,
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
  ],
);

// Subtitle Text
TextStyle titleMedium = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Colors.white70,
  letterSpacing: 2,
);

// Body Text
TextStyle bodyLarge = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

TextStyle bodyMedium = TextStyle(
  fontSize: 16,
  color: Colors.white60,
  fontStyle: FontStyle.italic,
);

// Button Text
TextStyle buttonLarge = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

TextStyle buttonMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

// Card Text
TextStyle cardText = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);
```

### Spacing System

#### Consistent Spacing Values

```dart
// Padding/Margin Values
const double SPACE_XS = 4.0;
const double SPACE_SM = 8.0;
const double SPACE_MD = 16.0;
const double SPACE_LG = 20.0;
const double SPACE_XL = 32.0;
const double SPACE_2XL = 40.0;
const double SPACE_3XL = 50.0;

// Component Spacing
const EdgeInsets SCREEN_PADDING = EdgeInsets.all(20);
const EdgeInsets BUTTON_PADDING = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
const EdgeInsets CARD_PADDING = EdgeInsets.all(16);
```

#### Layout Spacing

```dart
// Between major sections
const SizedBox SECTION_SPACING = SizedBox(height: 40);

// Between related elements
const SizedBox ELEMENT_SPACING = SizedBox(height: 20);

// Between buttons
const SizedBox BUTTON_SPACING = SizedBox(height: 30);

// Small spacing within components
const SizedBox SMALL_SPACING = SizedBox(height: 12);
```

## 🏗️ Screen Layouts

### Home Screen Layout

#### Structure Overview

```
HomeScreen
├── Background (RadialGradient)
├── SafeArea
    └── Column
        ├── Header Section
        │   ├── Logo Icon (Circle with Casino icon)
        │   ├── Hindi Title (अंदर बाहर)
        │   ├── English Title (ANDAR BAHAR)
        │   └── Subtitle (Traditional Indian Card Game)
        ├── Main Content (Expanded)
        │   ├── Instructions Text
        │   ├── Human vs AI Button (Animated from left)
        │   ├── Multiplayer Button (Animated from right)
        │   └── How to Play Button (Animated from bottom)
        └── Footer Section
            ├── Disclaimer Text
            └── Experience Badge
```

#### Header Component

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Logo Container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.yellow.shade400, Colors.orange.shade500],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.casino, size: 60, color: Colors.white),
        ),

        SizedBox(height: 20),

        // Title Stack
        Text('अंदर बाहर', style: titleLarge),
        SizedBox(height: 8),
        Text('ANDAR BAHAR', style: titleMedium),
        SizedBox(height: 12),
        Text('Traditional Indian Card Game', style: bodyMedium),
      ],
    ),
  );
}
```

#### Button Components

```dart
// Primary Game Mode Button
Widget _buildGameModeButton({
  required String title,
  required String subtitle,
  required IconData icon,
  required Gradient gradient,
  required VoidCallback onTap,
}) {
  return Container(
    width: double.infinity,
    height: 100,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Icon Section (100x100)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Icon(icon, size: 36, color: Colors.white),
              ),

              // Text Section (Expanded)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(title, style: buttonLarge),
                      ),
                      SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(subtitle, style: TextStyle(
                          fontSize: 16, color: Colors.white70
                        )),
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow Section
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Secondary Button (How to Play)
Widget _buildSecondaryButton({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Container(
    width: double.infinity,
    height: 70,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.red.shade700),
              SizedBox(width: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

### Game Screen Layout

#### Structure Overview

```
GameScreen
├── Background (Green RadialGradient)
├── Stack
    ├── Main Content Column
    │   ├── Top Bar
    │   │   ├── Back Button
    │   │   ├── Game Title
    │   │   └── Settings Button
    │   ├── Game Table (Expanded)
    │   │   ├── Game Stats Row
    │   │   ├── Card Table Row
    │   │   │   ├── Andar Pile
    │   │   │   ├── Joker Card (Center)
    │   │   │   └── Bahar Pile
    │   │   └── Game Status Display
    │   └── Betting Panel
    │       ├── Balance Display
    │       ├── Betting Options
    │       └── Quick Bet Buttons
    ├── Confetti Overlay
    └── Winner Result Overlay
```

#### Top Bar Component

```dart
Widget _buildTopBar(GameProvider gameProvider) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.black.withOpacity(0.3), Colors.transparent],
      ),
    ),
    child: SafeArea(
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Title (Centered)
          Expanded(
            child: Center(
              child: Text(
                widget.isAIGame ? 'Andar Bahar - vs AI' : 'Andar Bahar - Multiplayer',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Settings Button
          IconButton(
            onPressed: () => _showSettingsDialog(gameProvider),
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
```

#### Game Table Component

```dart
Widget _buildGameTable(GameProvider gameProvider) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Game Statistics
        _buildGameStats(gameProvider),
        const SizedBox(height: 20),

        // Card Table
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Andar Side
              Expanded(
                child: _buildCardPile(
                  'ANDAR',
                  gameProvider.gameState.andarCards,
                  Colors.blue.shade700,
                  gameProvider.gameState.winningSide == BetSide.andar,
                  gameProvider.gameState.getTotalBetForSide(BetSide.andar),
                ),
              ),

              // Center Joker
              Container(
                width: 120,
                child: _buildJokerCard(gameProvider.gameState.jokerCard),
              ),

              // Bahar Side
              Expanded(
                child: _buildCardPile(
                  'BAHAR',
                  gameProvider.gameState.baharCards,
                  Colors.green.shade700,
                  gameProvider.gameState.winningSide == BetSide.bahar,
                  gameProvider.gameState.getTotalBetForSide(BetSide.bahar),
                ),
              ),
            ],
          ),
        ),

        // Game Status
        _buildGameStatus(gameProvider),
      ],
    ),
  );
}
```

## 🧩 UI Components

### Card Widget

#### Visual Design

```dart
class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final double width;
  final double height;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 60,
      height: height ?? 84,
      decoration: BoxDecoration(
        color: card.isVisible ? Colors.white : Colors.blue.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: card.isVisible ? Colors.grey.shade300 : Colors.blue.shade700,
          width: 1,
        ),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
      child: card.isVisible
        ? _buildCardFace()
        : _buildCardBack(),
    );
  }

  Widget _buildCardFace() {
    return Center(
      child: Text(
        card.cardDisplay,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: card.isRed ? Colors.red.shade700 : Colors.black,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.blue.shade900],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.casino,
          color: Colors.white.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
}
```

### Betting Panel

#### Layout Structure

```dart
Widget _buildBettingPanel(GameProvider gameProvider) {
  return Container(
    height: 120,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      children: [
        // Balance and Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBalanceDisplay(gameProvider),
            _buildTimer(gameProvider),
          ],
        ),

        SizedBox(height: 16),

        // Dynamic Content Based on Game Phase
        if (gamePhase == GamePhase.betting) ...[
          // Chip Selection
          _buildChipSelection(),
          SizedBox(height: 16),
          // Betting Buttons
          _buildBettingButtons(),
        ] else if (gamePhase == GamePhase.readyToPlay) ...[
          // Countdown Timer
          _buildCountdownDisplay(),
        ] else if (!canBet && !isCountdown) ...[
          // Rebet Button
          _buildRebetButton(),
        ],
      ],
    ),
  );
}
```

### Dialog Components

#### How to Play Dialog

```dart
void _showHowToPlay() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue.shade700),
          SizedBox(width: 8),
          Text('How to Play Andar Bahar'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRuleSection(
              '1. Game Setup',
              '• A single deck of 52 cards is used\n'
              '• Two betting areas: Andar (Left) and Bahar (Right)\n'
            ),
            _buildRuleSection(
              '2. How to Play',
              '• Place your bet on either Andar or Bahar\n'
              '• A Joker card is revealed in the center\n'
              '• Cards are dealt alternately to both sides\n'
            ),
            // ... more sections
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Got It!', style: TextStyle(color: Colors.blue.shade700)),
        ),
      ],
    ),
  );
}

Widget _buildRuleSection(String title, String content) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    ),
  );
}
```

## 📱 Responsive Design

### Breakpoints

```dart
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}
```

### Responsive Layouts

```dart
Widget _buildResponsiveLayout(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 600) {
    // Mobile Layout
    return _buildMobileLayout();
  } else if (screenWidth < 1200) {
    // Tablet Layout
    return _buildTabletLayout();
  } else {
    // Desktop Layout
    return _buildDesktopLayout();
  }
}

// Responsive Padding
EdgeInsets _getResponsivePadding(BuildContext context) {
  if (ScreenBreakpoints.isMobile(context)) {
    return EdgeInsets.all(16);
  } else if (ScreenBreakpoints.isTablet(context)) {
    return EdgeInsets.all(24);
  } else {
    return EdgeInsets.all(32);
  }
}

// Responsive Font Sizes
double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 600) {
    return baseFontSize * 0.9;  // 90% on mobile
  } else if (screenWidth > 1200) {
    return baseFontSize * 1.1;  // 110% on desktop
  }

  return baseFontSize;  // 100% on tablet
}
```

## 🎯 Visual States

### Button States

```dart
// Normal State
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade800]),
    borderRadius: BorderRadius.circular(20),
  ),
)

// Pressed State (InkWell ripple effect)
InkWell(
  borderRadius: BorderRadius.circular(20),
  splashColor: Colors.white.withOpacity(0.2),
  highlightColor: Colors.white.withOpacity(0.1),
  onTap: onTap,
)

// Disabled State
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade600,
    borderRadius: BorderRadius.circular(20),
  ),
)
```

### Game States Visual Feedback

#### Betting Phase

```dart
// Active betting indicators
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.yellow, width: 2),
    borderRadius: BorderRadius.circular(15),
  ),
)

// Timer visual countdown
LinearProgressIndicator(
  value: timeRemaining / totalTime,
  backgroundColor: Colors.white.withOpacity(0.3),
  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
)
```

#### Ready to Play Phase

```dart
// Phase indicator styling
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.yellow.withOpacity(0.2),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.yellow),
  ),
  child: Text(
    'Ready to Play - Press Play!',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  ),
)

// Play button prominent styling
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.yellow.shade600, Colors.orange.shade600],
    ),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.yellow.withOpacity(0.4),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

#### Dealing Phase

```dart
// Cards appearing with scale animation
Transform.scale(
  scale: _cardAppearAnimation.value,
  child: CardWidget(card: dealtCard),
)

// Dealing direction indicators
AnimatedContainer(
  decoration: BoxDecoration(
    color: isActiveDealing ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
    borderRadius: BorderRadius.circular(12),
  ),
)
```

#### Result Phase

```dart
// Winner highlight
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.gold.shade400, Colors.gold.shade600],
    ),
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.yellow.withOpacity(0.5),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  ),
)

// Loser fade out
AnimatedOpacity(
  opacity: isWinner ? 1.0 : 0.5,
  duration: Duration(milliseconds: 500),
  child: cardPileWidget,
)
```

##### Winner Overlay

The winner overlay displays results with player outcome as the primary message (updated design):

```dart
// Layout hierarchy (updated for better UX)
Column(
  children: [
    Icon(Icons.celebration, size: 48, color: winnerColor),
    SizedBox(height: 16),
    // PRIMARY MESSAGE - Player result (larger text, main focus)
    Text(
      didWin ? 'You Win!' : 'You Lose',
      style: TextStyle(
        color: didWin ? Colors.green : Colors.red,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8),
    // SECONDARY INFO - Game result (smaller text, supporting info)
    Text(
      'ANDAR WINS!' / 'BAHAR WINS!',
      style: TextStyle(
        color: winnerColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
)
```

**Design Rationale (Updated):**

- **Player result shown FIRST** as it's most relevant to the user experience
- **Larger font size (28px)** for personal result draws immediate attention
- **Game outcome shown SECOND** as supporting information with smaller text (20px)
- **Clear hierarchy**: Personal impact > Game mechanics
- **Color coding**: Green for wins, Red for losses, Blue/Red for game sides
- **Improved UX**: Users immediately see their result without parsing game state

## 🛠️ Custom Widgets

### Reusable Components

#### Chip Widget

```dart
class ChipWidget extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isSelected
              ? [Colors.yellow.shade400, Colors.orange.shade500]
              : [Colors.grey.shade600, Colors.grey.shade800],
          ),
          border: Border.all(
            color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade500,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Status Badge Widget

```dart
class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

## 🎨 Visual Effects

### Shadows and Elevation

```dart
// Card shadows
BoxShadow cardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 4,
  offset: Offset(0, 2),
);

// Button elevation
BoxShadow buttonShadow = BoxShadow(
  color: Colors.black.withOpacity(0.3),
  blurRadius: 8,
  offset: Offset(0, 4),
);

// Winner glow effect
BoxShadow winnerGlow = BoxShadow(
  color: Colors.yellow.withOpacity(0.5),
  blurRadius: 20,
  spreadRadius: 5,
);
```

### Gradients

```dart
// Background gradients
RadialGradient backgroundGradient = RadialGradient(
  center: Alignment.center,
  radius: 1.2,
  colors: [startColor, middleColor, endColor],
);

// Button gradients
LinearGradient buttonGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [lightColor, darkColor],
);
```

#### Countdown Timer Display

```dart
Widget _buildCountdownDisplay() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer, color: Colors.yellow, size: 20),
        const SizedBox(width: 8),
        Text(
          'Starting in ${countdownSeconds}s...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
```

**Features:**

- Timer icon with yellow color
- Dynamic countdown text showing remaining seconds
- Semi-transparent dark background
- Rounded corners for modern look
- Appears automatically after betting phase

### Game Phase Indicator

The game phase indicator shows current game status with dynamic colors:

- **Betting Phase**: "Choose Your Side & Amount" (Green) - No timer, patient waiting
- **Countdown Phase**: "Starting in 5s..." (Yellow) - Triggered instantly by bet placement
- **Dealing Phase**: "Cards Being Dealt..." (Blue) - Active card dealing
- **Finished Phase**: "Round Finished" (Purple) - Round completed
- **Results Phase**: "Showing Results" (Orange) - Celebration and payout display

Colors and text update automatically based on game state transitions.

### Current Game Flow in UI

#### 1. Initial State

```dart
// Game starts in betting phase
gamePhase: GamePhase.betting
phaseText: "Choose Your Side & Amount"
phaseColor: Colors.green
```

#### 2. Bet Placement Trigger

```dart
// User clicks ANDAR or BAHAR button
onTap: () => gameProvider.placeBet(side, selectedAmount)
// Immediately transitions to countdown
gamePhase: GamePhase.readyToPlay
```

#### 3. Countdown Display

```dart
Widget _buildCountdownDisplay() {
  return Container(
    child: Row(
      children: [
        Icon(Icons.timer, color: Colors.yellow),
        Text('Starting in ${countdownSeconds}s...'),
      ],
    ),
  );
}
```

#### 4. Automatic Progression

- Countdown reaches 0 → Dealing phase begins
- Cards dealt with 400ms intervals after 0.7s joker reveal delay
- Winner determined → Results shown
- After 1.5s + 2s delay → New betting phase

---

This UI documentation serves as the complete visual reference for the Andar Bahar game. Use it to maintain consistency, implement new features, and understand the design system.

🎨 **Consistent design creates better user experiences!** 🎨
