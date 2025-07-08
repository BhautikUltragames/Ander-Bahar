# 🎬 Animations Documentation

## 📋 Overview

This document provides comprehensive documentation of all animations, transitions, and motion effects used in the Andar Bahar Flutter web game, including the new animated card dealer system. Use this as a reference for maintaining animation consistency and implementing new animated features.

## ⚠️ **CRITICAL ANIMATION ISSUES**

### **Current Animation Status: SYSTEM COMPLETE BUT CRITICAL INTERRUPTIONS**

**Status**: The animation system is professionally implemented with comprehensive card dealing animations and smooth transitions, but critical runtime issues frequently interrupt animations and cause jarring user experiences.

### **1. Animation Interruption Issues**

**Problem**: App crashes due to MaterialLocalizations and Navigator context errors interrupt animations mid-playback.

**Impact**:

- Card dealing animations may stop abruptly
- Hover animations might freeze
- Loading animations get stuck
- User experience is severely degraded

**Affected Animations**:

- Animated card dealer sequences
- Button hover effects
- Loading state animations
- Screen transition animations

### **2. Missing Error State Animations**

**Problem**: The app lacks animated feedback for error states.

**Impact**:

- No visual feedback when errors occur
- Users don't understand what's happening
- Poor error communication
- Jarring experience when errors happen

**Required Error State Animations**:

```dart
// ✅ PROPOSED ERROR STATE ANIMATIONS

// 1. Error Shake Animation
class ErrorShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool triggerShake;

  const ErrorShakeAnimation({
    Key? key,
    required this.child,
    required this.triggerShake,
  }) : super(key: key);

  @override
  _ErrorShakeAnimationState createState() => _ErrorShakeAnimationState();
}

class _ErrorShakeAnimationState extends State<ErrorShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void didUpdateWidget(ErrorShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerShake && !oldWidget.triggerShake) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_shakeAnimation.value * 10) *
            (1 - 2 * (_shakeAnimation.value * 2).round()),
            0,
          ),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}

// 2. Error Fade-In Animation
class ErrorFadeInAnimation extends StatefulWidget {
  final Widget child;
  final bool show;

  const ErrorFadeInAnimation({
    Key? key,
    required this.child,
    required this.show,
  }) : super(key: key);

  @override
  _ErrorFadeInAnimationState createState() => _ErrorFadeInAnimationState();
}

class _ErrorFadeInAnimationState extends State<ErrorFadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(ErrorFadeInAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _fadeController.forward();
    } else if (!widget.show && oldWidget.show) {
      _fadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeController,
      child: widget.child,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}

// 3. Loading State Animation
class LoadingPulseAnimation extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LoadingPulseAnimation({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  _LoadingPulseAnimationState createState() => _LoadingPulseAnimationState();
}

class _LoadingPulseAnimationState extends State<LoadingPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LoadingPulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      child: widget.child,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
```

### **3. Safe Animation Wrappers**

**Problem**: Current animations don't handle errors gracefully.

**Required Safe Animation System**:

```dart
// ✅ PROPOSED SAFE ANIMATION SYSTEM

// Safe Animation Mixin
mixin SafeAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  List<AnimationController> _controllers = [];

  AnimationController createSafeController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    try {
      final controller = AnimationController(
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        vsync: this,
      );
      _controllers.add(controller);
      return controller;
    } catch (e) {
      print('Error creating animation controller: $e');
      // Return a dummy controller that does nothing
      return AnimationController(
        duration: duration,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      try {
        controller.dispose();
      } catch (e) {
        print('Error disposing animation controller: $e');
      }
    }
    _controllers.clear();
    super.dispose();
  }

  void safeStartAnimation(AnimationController controller) {
    try {
      if (mounted && !controller.isDisposed) {
        controller.forward();
      }
    } catch (e) {
      print('Error starting animation: $e');
    }
  }

  void safeStopAnimation(AnimationController controller) {
    try {
      if (!controller.isDisposed) {
        controller.stop();
      }
    } catch (e) {
      print('Error stopping animation: $e');
    }
  }
}
```

---

## 🎯 Animation Principles

### Design Philosophy

- **Smooth and Natural**: All animations should feel natural and smooth
- **Purposeful Motion**: Every animation serves a functional purpose
- **Performance First**: Optimized for 60fps performance
- **Accessibility**: Animations don't interfere with usability
- **🔧 Error Resilience**: Animations handle errors gracefully (NEEDS IMPLEMENTATION)

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

// ✅ NEW: Error State Animation Timings
const Duration ERROR_SHAKE_DURATION = Duration(milliseconds: 500);
const Duration ERROR_FADE_DURATION = Duration(milliseconds: 400);
const Duration LOADING_PULSE_DURATION = Duration(milliseconds: 1000);
const Duration CONNECTION_RETRY_DURATION = Duration(milliseconds: 600);
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

// ✅ NEW: Error State Curves
Curves.elasticIn       // For shake animations
Curves.easeOutBack     // For error slide-ins
Curves.easeInExpo      // For loading pulses
```

---

## 🏠 Home Screen Animations

### Animation Controller Setup

```dart
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, SafeAnimationMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _button1SlideAnimation;
  late Animation<Offset> _button2SlideAnimation;
  late Animation<Offset> _button3SlideAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ UPDATED: Use safe animation controller
    _animationController = createSafeController(
      duration: const Duration(milliseconds: 2000),
      debugLabel: 'HomeScreenAnimation',
    );

    _setupAnimations();
    safeStartAnimation(_animationController);
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

---

## 🎮 Game Screen Animations

### **Animated Card Dealer System** - Core Feature

#### Implementation

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
    with TickerProviderStateMixin, SafeAnimationMixin {
  late AnimationController _dealerController;
  late AnimationController _cardController;
  late Animation<double> _dealerRotation;
  late Animation<Offset> _cardFlightPath;
  late Animation<double> _cardScale;

  @override
  void initState() {
    super.initState();

    // ✅ UPDATED: Use safe animation controllers
    _dealerController = createSafeController(
      duration: const Duration(milliseconds: 800),
      debugLabel: 'DealerAnimation',
    );

    _cardController = createSafeController(
      duration: const Duration(milliseconds: 350),
      debugLabel: 'CardFlightAnimation',
    );

    _setupDealerAnimations();
  }

  void _setupDealerAnimations() {
    _dealerRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _dealerController,
      curve: Curves.easeInOut,
    ));

    _cardFlightPath = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0),
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutQuart,
    ));

    _cardScale = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCardDealer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDealing && !oldWidget.isDealing) {
      _startDealingAnimation();
    } else if (!widget.isDealing && oldWidget.isDealing) {
      _stopDealingAnimation();
    }
  }

  void _startDealingAnimation() {
    safeStartAnimation(_dealerController);
    safeStartAnimation(_cardController);
  }

  void _stopDealingAnimation() {
    safeStopAnimation(_dealerController);
    safeStopAnimation(_cardController);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_dealerController, _cardController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _dealerRotation.value,
            child: Transform.translate(
              offset: Offset(
                _cardFlightPath.value.dx * 50,
                _cardFlightPath.value.dy * 30,
              ),
              child: Transform.scale(
                scale: _cardScale.value,
                child: Container(
                  width: 80,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Card Dealing Sequence Animation

```dart
class CardDealingSequence extends StatefulWidget {
  final List<PlayingCard> cards;
  final bool isDealing;
  final Function(PlayingCard, bool)? onCardPlaced;

  const CardDealingSequence({
    Key? key,
    required this.cards,
    required this.isDealing,
    this.onCardPlaced,
  }) : super(key: key);
}

class _CardDealingSequenceState extends State<CardDealingSequence>
    with TickerProviderStateMixin, SafeAnimationMixin {
  late AnimationController _sequenceController;
  late List<Animation<Offset>> _cardAnimations;

  @override
  void initState() {
    super.initState();

    // ✅ UPDATED: Use safe animation controller
    _sequenceController = createSafeController(
      duration: Duration(milliseconds: widget.cards.length * 400),
      debugLabel: 'CardDealingSequence',
    );

    _setupCardAnimations();

    if (widget.isDealing) {
      safeStartAnimation(_sequenceController);
    }
  }

  void _setupCardAnimations() {
    _cardAnimations = widget.cards.asMap().entries.map((entry) {
      final index = entry.key;
      final startTime = index / widget.cards.length;
      final endTime = (index + 1) / widget.cards.length;

      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset(index.isEven ? -2.0 : 2.0, 0),
      ).animate(CurvedAnimation(
        parent: _sequenceController,
        curve: Interval(
          startTime,
          endTime,
          curve: Curves.easeOutQuart,
        ),
      ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dealer position
        const AnimatedCardDealer(isDealing: true),

        // Flying cards
        ...widget.cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;

          return AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _cardAnimations[index].value.dx * 100,
                  _cardAnimations[index].value.dy * 50,
                ),
                child: CardWidget(
                  card: card,
                  size: CardSize.small,
                  showFace: true,
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }
}
```

### Hover Animation System

```dart
class HoverScaleAnimation extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final bool enabled;

  const HoverScaleAnimation({
    Key? key,
    required this.child,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
  }) : super(key: key);
}

class _HoverScaleAnimationState extends State<HoverScaleAnimation>
    with SingleTickerProviderStateMixin, SafeAnimationMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // ✅ UPDATED: Use safe animation controller
    _hoverController = createSafeController(
      duration: widget.duration,
      debugLabel: 'HoverAnimation',
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  void _onHoverEnter() {
    if (widget.enabled && mounted) {
      setState(() => _isHovered = true);
      safeStartAnimation(_hoverController);
    }
  }

  void _onHoverExit() {
    if (widget.enabled && mounted) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        child: widget.child,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
      ),
    );
  }
}
```

---

## 🎯 **Animation Status & Issues**

### **✅ What's Working (When App is Stable)**

- **Animated Card Dealer** - Professional card dealing with flying animations
- **Hover Animations** - 1.05x scale effects on interactive elements
- **Screen Transitions** - Smooth page transitions with staggered effects
- **Loading Animations** - Basic loading indicators work
- **Timing System** - Professional animation timing and curves

### **❌ What's Broken (Critical Issues)**

- **Animation Interruption** - App crashes interrupt animations mid-playback
- **Error State Animations** - No animated feedback for error states
- **Loading State Animations** - Limited error-safe loading indicators
- **Animation Safety** - No error handling for animation controllers
- **Context-Dependent Animations** - Navigator context errors affect transitions

### **⚠️ What Needs Improvement**

- **Error State Animations** - Need comprehensive error feedback animations
- **Safe Animation System** - Need error-handling animation controllers
- **Performance Monitoring** - Need animation performance indicators
- **Accessibility Animations** - Need reduced motion support
- **Error Recovery Animations** - Need animations for error recovery flows

---

## 🎯 **Animation Roadmap**

### **Phase 1: Critical Animation Fixes (Immediate)**

1. **Implement Safe Animation System**

   - Add SafeAnimationMixin for error handling
   - Implement safe animation controller creation
   - Add animation error recovery mechanisms

2. **Add Error State Animations**

   - Implement error shake animations
   - Add error fade-in animations
   - Create loading pulse animations

3. **Fix Animation Interruption**
   - Add proper animation lifecycle management
   - Implement crash-resistant animations
   - Test all animation scenarios

### **Phase 2: Enhanced Animation Features (Short-term)**

1. **Loading State Animations**

   - Add skeleton loading animations
   - Implement progress indicator animations
   - Add connection status animations

2. **Error Recovery Animations**

   - Add retry button animations
   - Implement reconnection animations
   - Add error dismissal animations

3. **Performance Animations**
   - Add performance monitoring animations
   - Implement memory usage indicators
   - Add network status animations

### **Phase 3: Advanced Animation Features (Long-term)**

1. **Accessibility Animations**

   - Add reduced motion support
   - Implement high contrast animations
   - Add screen reader friendly animations

2. **Customization Animations**

   - Add theme transition animations
   - Implement preference change animations
   - Add personalization animations

3. **Analytics Animations**
   - Add user interaction tracking animations
   - Implement performance metrics animations
   - Add debugging animations

---

## 🔧 **Animation Implementation Priority**

### **Critical (Fix First)**

1. **Safe Animation System** - Prevent animation crashes
2. **Error State Animations** - Show errors with animation feedback
3. **Loading State Animations** - Show loading states safely
4. **Animation Error Handling** - Handle animation failures gracefully

### **High Priority**

1. **Connection Status Animations** - Show network status changes
2. **Error Recovery Animations** - Animate error recovery flows
3. **Performance Animations** - Monitor animation performance
4. **Accessibility Animations** - Support reduced motion preferences

### **Medium Priority**

1. **Customization Animations** - Allow animation preferences
2. **Advanced Error Animations** - Detailed error state feedback
3. **Analytics Animations** - Show usage statistics with animations
4. **Debug Animations** - Development animation tools

---

**Next Steps**: Focus on implementing safe animation systems first, then build robust error state animations and loading indicators to improve the overall user experience and app stability.
