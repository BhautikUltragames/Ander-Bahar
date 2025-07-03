# 🎨 UI Design Documentation

## 📋 Overview

This document provides comprehensive documentation of the UI design system, components, layouts, visual patterns, and animation system used in the Andar Bahar Flutter web game, including the new animated card dealer. Use this as a reference for maintaining consistency and implementing new features.

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

RadialGradient lobbyBackground = RadialGradient(
  center: Alignment.center,
  radius: 1.5,
  colors: [
    Colors.green.shade700,     // #388E3C
    Colors.green.shade800,     // #2E7D32
    Colors.green.shade900,     // #1B5E20
  ],
);
```

#### Game Element Colors (Updated 2024)

```dart
// Card Table Colors - Current Theme
const Color ANDAR_COLOR = Colors.blue.shade700;      // #1976D2 - Blue
const Color BAHAR_COLOR = Colors.yellow.shade700;    // #F57F17 - Bright Yellow
const Color JOKER_BACKGROUND = Color(0xFFFBC02D);    // Yellow

// Button Colors
LinearGradient playButtonGradient = LinearGradient(
  colors: [Colors.green.shade600, Colors.green.shade800]
);

LinearGradient andarButtonGradient = LinearGradient(
  colors: [Colors.blue.shade600, Colors.blue.shade800]
);

LinearGradient baharButtonGradient = LinearGradient(
  colors: [Colors.yellow.shade600, Colors.yellow.shade700]
);

// Text Colors
const Color PRIMARY_TEXT = Colors.white;
const Color SECONDARY_TEXT = Color(0xB3FFFFFF); // 70% white
const Color TERTIARY_TEXT = Color(0x99FFFFFF);  // 60% white
const Color BAHAR_TEXT = Colors.black;          // Black text on yellow background
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
// Title Text (Home Screen) - Updated
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

// Main Button Text - Enhanced
TextStyle mainButtonText = TextStyle(
  fontSize: 28,        // Increased from 22
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

// Secondary Button Text
TextStyle secondaryButtonText = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.red.shade700,
);

// Betting Button Text
TextStyle bettingButtonText = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,  // White for ANDAR
);

TextStyle baharButtonText = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,  // Black for yellow BAHAR
);
```

### Interactive Elements

#### Hover Animations (New Feature)

```dart
// Hover Scale Animation
class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double hoverScale = 1.05;
  final Duration animationDuration = Duration(milliseconds: 200);
  final Curve animationCurve = Curves.easeInOut;
}

// Implementation
MouseRegion(
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: AnimatedScale(
    scale: isHovered ? 1.05 : 1.0,
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    child: buttonWidget,
  ),
);
```

#### Button Dimensions (Updated)

```dart
// Main Game Mode Button
const double MAIN_BUTTON_HEIGHT = 120.0;
const double MAIN_BUTTON_WIDTH = 70% of screen width;  // Responsive
const BorderRadius MAIN_BUTTON_RADIUS = BorderRadius.circular(20);

// Secondary Button (How to Play)
const double SECONDARY_BUTTON_HEIGHT = 70.0;
const double SECONDARY_BUTTON_WIDTH = 70% of screen width;  // Responsive
const BorderRadius SECONDARY_BUTTON_RADIUS = BorderRadius.circular(15);

// Betting Buttons
const double BETTING_BUTTON_HEIGHT = 60.0;
const BorderRadius BETTING_BUTTON_RADIUS = BorderRadius.circular(25);
```

## 🏗️ Screen Layouts

### Home Screen Layout (Simplified Design)

#### Structure Overview - Current Implementation

```
HomeScreen
├── Background (RadialGradient - Orange to Red)
├── SafeArea
    └── Column
        ├── Header Section
        │   ├── Logo Icon (Circle with Casino icon)
        │   ├── Hindi Title (अंदर बाहर)
        │   ├── English Title (ANDAR BAHAR)
        │   └── Subtitle (Traditional Indian Card Game)
        └── Main Content (Expanded + ScrollView)
            ├── Welcome Instructions
            ├── PLAY Button (Green, Hover Animation)
            └── HOW TO PLAY Button (White, Hover Animation)

Note: Footer and Game Features sections removed for cleaner design
```

#### Header Component

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Logo Container with Gradient
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow.shade400,
                Colors.orange.shade500,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.casino,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        // Bilingual Title
        const Text(
          'अंदर बाहर',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const Text(
          'ANDAR BAHAR',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );
}
```

### Game Screen Layout

#### Structure Overview

```
GameScreen/MultiplayerGameScreen
├── Background (RadialGradient - Green)
├── Stack
    ├── Main Content Column
    │   ├── Top Bar
    │   │   ├── Back Button
    │   │   ├── Game Title & Round Info
    │   │   └── Timer/Settings
    │   ├── Game Table (Expanded)
    │   │   ├── Game Stats Row
    │   │   ├── Card Table Row
    │   │   │   ├── Andar Pile (Blue)
    │   │   │   ├── Joker Card (Center, Yellow)
    │   │   │   └── Bahar Pile (Yellow)
    │   │   └── Game Status Display
    │   └── Betting Panel
    │       ├── Balance Display
    │       ├── Chip Selection
    │       └── Betting Buttons (Blue ANDAR | Yellow BAHAR)
    └── Winner Result Overlay (when applicable)
```

#### Betting Panel Component

```dart
Widget _buildBettingButtons(bool canBet) {
  return Row(
    children: [
      // ANDAR Button - Blue Theme
      Expanded(
        child: _buildBetButton(
          'ANDAR',
          BetSide.andar,
          Colors.blue.shade700,    // Blue background
          Colors.white,            // White text
          canBet,
        ),
      ),
      const SizedBox(width: 16),

      // BAHAR Button - Yellow Theme
      Expanded(
        child: _buildBetButton(
          'BAHAR',
          BetSide.bahar,
          Colors.yellow.shade700,  // Yellow background
          Colors.black,            // Black text for readability
          canBet,
        ),
      ),
    ],
  );
}
```

## 🎯 Component Guidelines

### Button Design Principles

#### Primary Action Buttons

- **Green gradient** for main game actions (PLAY)
- **120px height** for main buttons
- **70% screen width** for responsive design
- **Hover scale: 1.05x** with 200ms transition
- **Rounded corners: 20px**

#### Secondary Action Buttons

- **White/light background** for secondary actions
- **70px height** for secondary buttons
- **No border highlighting** (removed for cleaner look)
- **Hover animations** for better UX

#### Betting Buttons

- **Blue for ANDAR** - Traditional, trustworthy color
- **Yellow for BAHAR** - Bright, lucky, positive color
- **High contrast text** (white on blue, black on yellow)
- **Equal sizing** for fair representation

### Color Usage Guidelines

#### When to Use Each Color

**Blue (ANDAR)**

- Traditional side, left position
- Associated with stability and trust
- White text for optimal contrast

**Yellow (BAHAR)**

- Modern side, right position
- Associated with luck, wealth, prosperity
- Black text for optimal readability
- Higher opacity (0.8) for better visibility

**Green**

- Primary action buttons (PLAY, JOIN)
- Success states and confirmations
- Background themes

**Orange**

- Secondary accent color
- Chip selections and highlights
- REBET functionality

### Accessibility Considerations

#### Color Contrast

- **WCAG AA compliant** color combinations
- **Black text on yellow** for BAHAR elements
- **White text on blue** for ANDAR elements
- **High contrast** shadows and borders

#### Interactive Feedback

- **Hover animations** for all clickable elements
- **Visual feedback** during button press
- **Clear disabled states** when actions unavailable
- **Loading indicators** during network operations

## 📱 Responsive Design

### Breakpoints

- **Mobile**: < 768px (not currently implemented)
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px (primary target)

### Current Implementation

- **70% width buttons** for better proportions
- **Centered layouts** for visual balance
- **Flexible text sizing** with FittedBox widgets
- **Responsive spacing** using MediaQuery

## 🔄 Recent Updates (2024)

### Major Changes Made

1. **✅ Color Scheme Overhaul**

   - Changed BAHAR from red → purple → yellow
   - Maintained blue ANDAR for consistency
   - Updated all related UI elements

2. **✅ Simplified Home Screen**

   - Removed game features section
   - Removed footer elements
   - Streamlined to essential actions only

3. **✅ Enhanced Interactivity**

   - Added hover animations to all buttons
   - Implemented smooth scaling effects
   - Improved user feedback systems

4. **✅ Button Improvements**

   - Increased main button text size (22px → 28px)
   - Optimized button proportions (70% width)
   - Added professional hover effects

5. **✅ Typography Enhancements**
   - Better contrast ratios
   - Improved readability on yellow backgrounds
   - Consistent sizing hierarchy

## 🎨 Design Assets

### Icons Used

- **Casino icon** for main logo
- **Play arrow** for PLAY button
- **Help outline** for HOW TO PLAY
- **Timer** for countdown displays
- **Group** for multiplayer features

### Gradients

- **Radial gradients** for backgrounds
- **Linear gradients** for buttons
- **Shadow effects** for depth

This documentation reflects the current state of the UI as of December 2024, featuring the bright yellow BAHAR color scheme and enhanced interactive elements.
