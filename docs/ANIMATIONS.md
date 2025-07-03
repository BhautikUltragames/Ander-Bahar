# 🎬 Animations Documentation

## 📋 Overview

This document provides comprehensive documentation of all animations, transitions, and motion effects used in the Andar Bahar Flutter web game, including the new animated card dealer system. Use this as a reference for maintaining animation consistency and implementing new animated features.

## 🎯 Animation Principles

### Design Philosophy

- **Smooth and Natural**: All animations should feel natural and smooth
- **Purposeful Motion**: Every animation serves a functional purpose
- **Performance First**: Optimized for 60fps performance
- **Accessibility**: Animations don't interfere with usability

### Timing Guidelines

```dart
// Standard Duration Constants
const Duration QUICK_ANIMATION = Duration(milliseconds: 200);
const Duration NORMAL_ANIMATION = Duration(milliseconds: 400);
const Duration SLOW_ANIMATION = Duration(milliseconds: 600);
const Duration EXTRA_SLOW_ANIMATION = Duration(milliseconds: 1000);

// Game-Specific Timings
const Duration BUTTON_ENTRANCE_DURATION = Duration(milliseconds: 2000);
const Duration CARD_DEALING_INTERVAL = Duration(milliseconds: 400);
const Duration CONFETTI_DURATION = Duration(seconds: 2);
const Duration JOKER_REVEAL_DELAY = Duration(milliseconds: 700);
const Duration RESULT_DISPLAY_DURATION = Duration(seconds: 5);
const Duration BETTING_TIMER_DURATION = Duration(seconds: 10);
const Duration UI_COUNTDOWN_DURATION = Duration(seconds: 5);
```

### Easing Curves

```dart
// Standard Curves
Curves.easeIn          // Slow start, fast finish
Curves.easeOut         // Fast start, slow finish
Curves.easeInOut       // Slow start and finish
Curves.easeOutBack     // Bouncy overshoot effect
Curves.elasticOut      // Elastic spring effect
Curves.bounceOut       // Bouncing effect
```

## 🏠 Home Screen Animations

### Animation Controller Setup

```dart
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _button1SlideAnimation;
  late Animation<Offset> _button2SlideAnimation;
  late Animation<Offset> _button3SlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    // Header fade-in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Header slide-up animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    // Button 1 - Slide from left
    _button1SlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    ));

    // Button 2 - Slide from right
    _button2SlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
    ));

    // Button 3 - Slide from bottom
    _button3SlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### Animation Implementation

#### Header Entrance Animation

```dart
Widget _buildAnimatedHeader() {
  return AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildHeader(),
        ),
      );
    },
  );
}
```

#### Staggered Button Animations

```dart
// Button 1 - From Left
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return SlideTransition(
      position: _button1SlideAnimation,
      child: _buildGameModeButton(
        title: 'HUMAN vs AI',
        subtitle: 'Play against computer',
        icon: Icons.smart_toy,
        gradient: blueGradient,
        onTap: () => _navigateToGame(true),
      ),
    );
  },
)

// Button 2 - From Right
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return SlideTransition(
      position: _button2SlideAnimation,
      child: _buildGameModeButton(
        title: 'MULTIPLAYER',
        subtitle: 'Play with other players',
        icon: Icons.group,
        gradient: greenGradient,
        onTap: () => _navigateToGame(false),
      ),
    );
  },
)

// Button 3 - From Bottom
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return SlideTransition(
      position: _button3SlideAnimation,
      child: _buildSecondaryButton(
        title: 'HOW TO PLAY',
        icon: Icons.help_outline,
        onTap: _showHowToPlay,
      ),
    );
  },
)
```

### Animation Timing Breakdown

```
Total Duration: 2000ms (2 seconds)

Timeline:
0ms - 800ms    : Header fade-in and slide-up (0.0 - 0.4 interval)
600ms - 1400ms : Button 1 slides from left (0.3 - 0.7 interval)
1000ms - 1800ms: Button 2 slides from right (0.5 - 0.9 interval)
1400ms - 2000ms: Button 3 slides from bottom (0.7 - 1.0 interval)

Overlap Pattern:
- Header starts immediately
- Button 1 starts when header is 75% complete
- Button 2 starts when button 1 is 50% complete
- Button 3 starts when button 2 is 50% complete
```

## 🎮 Game Screen Animations

### Animation Controllers Setup

```dart
class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti controller for celebrations
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2)
    );

    // Card dealing animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Pulse animation for active elements
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _setupGameAnimations();
  }

  void _setupGameAnimations() {
    // Card appearance animation
    _cardSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Pulse animation for active betting areas
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Repeat pulse animation
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }
}
```

### Card Dealing Animations

#### Card Appearance Animation

```dart
Widget _buildAnimatedCard(PlayingCard card, bool isNewCard) {
  if (isNewCard) {
    _cardAnimationController.reset();
    _cardAnimationController.forward();
  }

  return AnimatedBuilder(
    animation: _cardAnimationController,
    builder: (context, child) {
      return Transform.scale(
        scale: _cardSlideAnimation.value,
        child: Opacity(
          opacity: _cardSlideAnimation.value,
          child: CardWidget(card: card),
        ),
      );
    },
  );
}
```

#### Card Flip Animation

```dart
class FlipCard extends StatefulWidget {
  final PlayingCard card;
  final Duration duration;

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: widget.duration ?? Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  void flipCard() {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isShowingFront = _flipAnimation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value * math.pi),
          child: isShowingFront
            ? _buildCardBack()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _buildCardFront(),
              ),
        );
      },
    );
  }
}
```

### Betting Phase Animations

#### Active Betting Area Pulse

```dart
Widget _buildPulsingBettingArea(BetSide side, bool isActive) {
  return AnimatedBuilder(
    animation: _pulseAnimation,
    builder: (context, child) {
      return Transform.scale(
        scale: isActive ? _pulseAnimation.value : 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive
                ? Colors.yellow.withOpacity(0.8)
                : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: _buildBettingAreaContent(side),
        ),
      );
    },
  );
}
```

#### Timer Countdown Animation

```dart
class AnimatedTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  _AnimatedTimerState createState() => _AnimatedTimerState();
}

class _AnimatedTimerState extends State<AnimatedTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));

    _timerController.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              '${(_progressAnimation.value * widget.duration.inSeconds).ceil()}s',
              style: TextStyle(
                color: _progressAnimation.value < 0.3
                  ? Colors.red
                  : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressAnimation.value < 0.3
                  ? Colors.red
                  : Colors.yellow,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Result Animations

#### Winner Celebration

```dart
void _showWinnerCelebration(BetSide winningSide) {
  // Start confetti
  _confettiController.play();

  // Animate winner highlight
  _animateWinnerHighlight(winningSide);

  // Show result overlay with animation
  _showAnimatedResultOverlay(winningSide);
}

void _animateWinnerHighlight(BetSide winningSide) {
  // Winner glow animation
  setState(() {
    _isWinnerAnimating = true;
  });

  Timer(Duration(milliseconds: 1500), () {
    setState(() {
      _isWinnerAnimating = false;
    });
  });
}

Widget _buildWinnerHighlight(bool isWinner) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: isWinner && _isWinnerAnimating ? [
        BoxShadow(
          color: Colors.yellow.withOpacity(0.6),
          blurRadius: 20,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: Colors.orange.withOpacity(0.4),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ] : null,
    ),
    child: cardPileWidget,
  );
}
```

#### Result Overlay Animation

```dart
Widget _buildAnimatedResultOverlay(BetSide winningSide) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 800),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeOutBack,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: Opacity(
          opacity: value,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.yellow,
                ),
                SizedBox(height: 16),
                Text(
                  '${winningSide.name.toUpperCase()} WINS!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
```

### Confetti Animation

#### Confetti Configuration

```dart
Widget _buildConfettiOverlay() {
  return Align(
    alignment: Alignment.topCenter,
    child: ConfettiWidget(
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
      ],
      createParticlePath: _createStarPath,
      emissionFrequency: 0.1,
      numberOfParticles: 10,
      gravity: 0.1,
      maxBlastForce: 20,
      minBlastForce: 5,
    ),
  );
}

Path _createStarPath(Size size) {
  // Create star-shaped confetti particles
  Path path = Path();
  double width = size.width;
  double height = size.height;

  path.moveTo(width * 0.5, 0);
  path.lineTo(width * 0.61, height * 0.35);
  path.lineTo(width, height * 0.35);
  path.lineTo(width * 0.68, height * 0.57);
  path.lineTo(width * 0.79, height * 0.91);
  path.lineTo(width * 0.5, height * 0.7);
  path.lineTo(width * 0.21, height * 0.91);
  path.lineTo(width * 0.32, height * 0.57);
  path.lineTo(0, height * 0.35);
  path.lineTo(width * 0.39, height * 0.35);
  path.close();

  return path;
}
```

## 🎭 Micro-Animations

### Button Interactions

#### Tap Animation

```dart
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
```

### Hover Effects

#### Card Hover Animation

```dart
class HoverCard extends StatefulWidget {
  final Widget child;

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            boxShadow: _isHovered ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
```

## 🔧 Animation Utilities

### Animation Helpers

```dart
class AnimationUtils {
  // Staggered animation builder
  static List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int count,
    required Duration delay,
    Curve curve = Curves.easeOut,
  }) {
    List<Animation<double>> animations = [];
    double intervalSize = 1.0 / count;

    for (int i = 0; i < count; i++) {
      double start = i * intervalSize * 0.5;
      double end = start + intervalSize;

      animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: curve),
          ),
        ),
      );
    }

    return animations;
  }

  // Slide animation helper
  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    required Offset begin,
    required Offset end,
    double startInterval = 0.0,
    double endInterval = 1.0,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }

  // Scale animation helper
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    double startInterval = 0.0,
    double endInterval = 1.0,
    Curve curve = Curves.easeOutBack,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(startInterval, endInterval, curve: curve),
      ),
    );
  }
}
```

### Performance Optimization

```dart
class AnimationPerformance {
  // Use RepaintBoundary for expensive animations
  static Widget optimizedAnimation({
    required Widget child,
    required Animation animation,
  }) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => child,
      ),
    );
  }

  // Cached animation widgets
  static final Map<String, Widget> _animationCache = {};

  static Widget getCachedAnimation(String key, Widget Function() builder) {
    return _animationCache.putIfAbsent(key, builder);
  }
}
```

## 📊 Animation Performance Monitoring

### Performance Metrics

```dart
class AnimationMetrics {
  static void logAnimationPerformance(String animationName, Duration duration) {
    if (kDebugMode) {
      print('Animation: $animationName completed in ${duration.inMilliseconds}ms');
    }
  }

  static void monitorFPS(AnimationController controller, String name) {
    controller.addListener(() {
      if (kDebugMode && controller.lastElapsedDuration != null) {
        double fps = 1000 / controller.lastElapsedDuration!.inMilliseconds;
        if (fps < 55) {
          print('Warning: $name animation FPS dropped to ${fps.toStringAsFixed(1)}');
        }
      }
    });
  }
}
```

### Countdown Timer Animation

The countdown timer appears with automatic updates during the readyToPlay phase:

```dart
// Countdown timer updates every second
void _startCountdown() {
  countdownSeconds = 5;
  _countdownTimer?.cancel();

  _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      countdownSeconds--;
    });

    if (countdownSeconds <= 0) {
      timer.cancel();
    }
  });
}
```

**Animation Features:**

- Text changes smoothly as countdown decreases (5, 4, 3, 2, 1)
- Timer icon provides visual cue with yellow color
- Automatic state management - no user interaction required
- Triggers immediately when user places bet
- Seamlessly transitions to dealing phase at 0

### Current Animation Timing

#### Game Flow Animations

```dart
// Immediate bet placement response
onTap: () => gameProvider.placeBet(side, amount)
// → Instant transition to countdown (0ms delay)

// Countdown completion
Timer(Duration(seconds: 5), () => _startDealing())
// → Automatic dealing start

// Joker reveal delay
Timer(Duration(milliseconds: 700), () => _startDealingCards())
// → Card dealing begins

// Card dealing interval
Timer.periodic(Duration(milliseconds: 400), (timer) => dealNextCard())
// → Smooth card appearance

// Result display duration
Timer(Duration(milliseconds: 1500), () => showNextRound())
// → Brief celebration period
```

### Performance Optimizations

#### Timer Management

```dart
@override
void dispose() {
  _countdownTimer?.cancel();
  super.dispose();
}

@override
void didUpdateWidget(BettingPanel oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Clean timer management
  if (oldWidget.gamePhase == GamePhase.readyToPlay &&
      widget.gamePhase != GamePhase.readyToPlay) {
    _stopCountdown();
  }
}
```

---

This animation documentation serves as the complete motion reference for the Andar Bahar game. Use it to maintain animation consistency, optimize performance, and implement new animated features.

🎬 **Smooth animations create delightful user experiences!** 🎬
