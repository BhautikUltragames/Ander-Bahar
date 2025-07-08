# 🏗️ Andar Bahar - Technical Architecture

## 📋 Overview

This document provides a comprehensive technical overview of the Andar Bahar Flutter web application, including architecture decisions, code structure, state management, implementation details, and the latest enhancements including the animated card dealer system.

## ⚠️ **CRITICAL ARCHITECTURE ISSUES**

### **Current Status: ARCHITECTURE IMPLEMENTED BUT CRITICAL BUGS PRESENT**

**Issue**: The application architecture is well-designed and fully implemented, but critical bugs in the MaterialApp structure cause severe runtime issues that prevent stable operation.

**Root Problems**:

1. **Missing MaterialLocalizations** - Dialog calls fail due to missing localization context
2. **Navigator Context Issues** - Navigation operations fail with incorrect context hierarchy
3. **Error Boundary Gaps** - Insufficient error handling causes cascading failures
4. **Widget Lifecycle Problems** - Widgets unmount unexpectedly during gameplay
5. **Audio Service Integration** - File reference issues cause runtime errors

**Current Problematic Structure**:

```dart
// lib/main.dart - CURRENT IMPLEMENTATION (HAS ISSUES)
class AndarBaharApp extends StatelessWidget {
  const AndarBaharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Andar Bahar - अंदर बाहर',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // ... theme configuration
        ),
        home: const HomeScreen(), // ❌ ISSUE: Missing proper localization setup
      ),
    );
  }
}
```

**Required Fix Structure**:

```dart
// PROPOSED FIX - Proper MaterialApp Structure
class AndarBaharApp extends StatelessWidget {
  const AndarBaharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Andar Bahar - अंदर बाहर',
        debugShowCheckedModeBanner: false,

        // ✅ FIX: Proper localization setup
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('hi', ''), // Hindi
        ],

        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // ... theme configuration
        ),

        // ✅ FIX: Proper error handling wrapper
        builder: (context, child) {
          return ErrorBoundary(
            child: child ?? Container(),
          );
        },

        home: const HomeScreen(),
      ),
    );
  }
}

// ✅ FIX: Error Boundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Something went wrong. Please refresh the page.'),
          ),
        ),
      );
    }

    return widget.child;
  }
}
```

### **Dialog System Architecture Issues**

**Current Problem**:

```dart
// CURRENT IMPLEMENTATION (CAUSES CRASHES)
void _showNoInternetDialog() {
  showDialog( // ❌ FAILS: No MaterialLocalizations found
    context: context,
    builder: (context) => AlertDialog(
      title: Text('No Internet Connection'),
      content: Text('Please check your internet connection and try again.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // ❌ FAILS: Navigator context error
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

**Required Fix**:

```dart
// PROPOSED FIX - Safe Dialog Implementation
void _showNoInternetDialog() {
  try {
    final context = navigatorKey.currentContext;
    if (context != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Fallback error handling
    print('Error showing dialog: $e');
    // Could implement alternative notification method
  }
}
```

---

## 🎯 Architecture Principles

- **Clean Architecture**: Separation of concerns with distinct layers
- **Reactive Programming**: State-driven UI updates using Provider
- **Component-Based Design**: Reusable, modular widgets
- **Immutable State**: Predictable state management with proper cloning
- **Animation-First**: Smooth, native-feeling animations throughout
- **AI Integration**: Seamless single-player experience with automatic AI behavior
- **Timer Synchronization**: Consistent timing across all game modes
- **Professional Polish**: WCAG compliant design with hover effects
- **🔧 Error Resilience**: Proper error boundaries and fallback mechanisms (NEEDS IMPLEMENTATION)

---

## 🏗️ Project Structure

```
andar_bahar_game/
├── lib/
│   ├── main.dart                 # ⚠️ App entry point - NEEDS FIXING
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
│       ├── websocket_service.dart # WebSocket communication
│       └── audio_service.dart   # ⚠️ Audio system - NEEDS CLEANUP
├── assets/                      # Static assets
│   ├── images/                  # Game images and icons
│   └── sounds/                  # ⚠️ Audio files - NEEDS CLEANUP
│       └── Button.wav           # ✅ New audio file
├── server/                      # ✅ Node.js WebSocket server (WORKING)
│   ├── server.js               # Main server implementation
│   ├── package.json            # Server dependencies
│   └── node-v22.17.0-win-x64/  # Bundled Node.js runtime
├── web/                         # Web-specific configuration
└── test/                        # Unit and widget tests
```

---

## 🔧 Core Components

### 1. Application Entry Point (`main.dart`) - ⚠️ NEEDS FIXING

#### Current Issues

```dart
// CURRENT PROBLEMATIC IMPLEMENTATION
void main() {
  runApp(const AndarBaharApp()); // ❌ No error handling
}

class AndarBaharApp extends StatelessWidget {
  const AndarBaharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Andar Bahar - अंदर बाहर',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // ... theme configuration
        ),
        home: const HomeScreen(), // ❌ Missing proper context setup
      ),
    );
  }
}
```

#### Required Architecture Fix

```dart
// PROPOSED FIXED IMPLEMENTATION
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// ... other imports

// Global navigator key for proper context management
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // ✅ FIX: Add error handling at app level
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log error details
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  runApp(const AndarBaharApp());
}

class AndarBaharApp extends StatelessWidget {
  const AndarBaharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Andar Bahar - अंदर बाहर',
        debugShowCheckedModeBanner: false,

        // ✅ FIX: Add global navigator key
        navigatorKey: navigatorKey,

        // ✅ FIX: Add proper localization support
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('hi', 'IN'), // Hindi
        ],

        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),

        // ✅ FIX: Add error boundary wrapper
        builder: (context, child) {
          return ErrorBoundary(
            child: child ?? const SizedBox.shrink(),
          );
        },

        home: const HomeScreen(),
      ),
    );
  }
}

// ✅ FIX: Error Boundary Implementation
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                errorMessage ?? 'An unexpected error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                    errorMessage = null;
                  });
                },
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }

  void catchError(dynamic error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
      errorMessage = error.toString();
    });
  }
}
```

### 2. Audio Service Architecture - ⚠️ NEEDS CLEANUP

#### Current Issues

```dart
// CURRENT PROBLEMATIC IMPLEMENTATION
class AudioService {
  static const String _starCollectSound = 'assets/sounds/StarCollect.wav'; // ❌ File deleted
  static const String _buttonSound = 'assets/sounds/Button.wav'; // ✅ New file

  static Future<void> playStarCollect() async {
    // ❌ Will fail - file doesn't exist
    await _audioPlayer.play(AssetSource(_starCollectSound));
  }
}
```

#### Required Architecture Fix

```dart
// PROPOSED FIXED IMPLEMENTATION
class AudioService {
  static const String _buttonSound = 'assets/sounds/Button.wav'; // ✅ Updated reference

  static Future<void> playButtonSound() async {
    try {
      await _audioPlayer.play(AssetSource(_buttonSound));
    } catch (e) {
      // ✅ FIX: Proper error handling
      print('Audio playback failed: $e');
      // Don't crash the app for audio failures
    }
  }

  // ✅ FIX: Remove old method references
  // static Future<void> playStarCollect() async { ... } // REMOVED
}
```

### 3. Navigation Architecture - ⚠️ NEEDS FIXING

#### Current Issues

```dart
// CURRENT PROBLEMATIC NAVIGATION
class HomeScreen extends StatelessWidget {
  void _navigateToGame() {
    Navigator.of(context).push( // ❌ Context might not have Navigator
      MaterialPageRoute(
        builder: (context) => GameScreen(),
      ),
    );
  }
}
```

#### Required Architecture Fix

```dart
// PROPOSED FIXED NAVIGATION
class HomeScreen extends StatelessWidget {
  void _navigateToGame() {
    final context = navigatorKey.currentContext;
    if (context != null && Navigator.canPush(context)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(),
        ),
      );
    } else {
      // ✅ FIX: Fallback navigation
      print('Navigation failed - no valid context');
    }
  }
}
```

---

## 🔧 Error Handling Architecture

### **Current State: Insufficient Error Handling**

**Problems**:

- No error boundaries to catch widget errors
- Dialog failures crash the entire app
- Navigation errors prevent app usage
- Audio errors can cause instability

### **Required Error Handling Architecture**

```dart
// ✅ PROPOSED ERROR HANDLING SYSTEM

// 1. Global Error Handler
class GlobalErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    // Log error
    print('Global Error: $error');
    print('Stack Trace: $stackTrace');

    // Could send to crash reporting service
    // Could show user-friendly error message
  }
}

// 2. Safe Dialog Helper
class SafeDialogHelper {
  static Future<void> showSafeDialog({
    required BuildContext context,
    required Widget dialog,
  }) async {
    try {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => dialog,
        );
      }
    } catch (e) {
      print('Dialog error: $e');
      // Fallback: could show snackbar or other notification
    }
  }
}

// 3. Safe Navigation Helper
class SafeNavigationHelper {
  static Future<void> pushSafe({
    required BuildContext context,
    required Widget page,
  }) async {
    try {
      if (context.mounted && Navigator.canPush(context)) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    } catch (e) {
      print('Navigation error: $e');
      // Fallback: could show error message
    }
  }
}
```

---

## 📊 **Architecture Status**

### **✅ What's Working**

- **Backend Architecture** - Node.js WebSocket server is well-structured
- **Widget Architecture** - UI components are properly organized
- **Animation Architecture** - Card dealer animations are well-implemented
- **State Management** - Provider pattern works when app is stable

### **❌ What's Broken**

- **MaterialApp Structure** - Missing proper localization setup
- **Error Handling** - Insufficient error boundaries
- **Navigation System** - Context hierarchy issues
- **Audio Architecture** - Outdated file references

### **⚠️ What Needs Improvement**

- **Error Resilience** - Need comprehensive error handling
- **Testing Architecture** - Limited due to current instability
- **Performance Monitoring** - Need better error tracking
- **Logging System** - Need structured logging for debugging

---

## 🎯 **Architecture Roadmap**

### **Phase 1: Stability (Immediate)**

1. **Fix MaterialApp Structure**

   - Add proper localization delegates
   - Implement error boundaries
   - Fix Navigator context issues

2. **Implement Error Handling**

   - Add safe dialog helpers
   - Implement safe navigation
   - Add comprehensive error boundaries

3. **Clean Audio Architecture**
   - Update file references
   - Add error handling for audio failures
   - Test audio system thoroughly

### **Phase 2: Enhancement (Short-term)**

1. **Performance Architecture**

   - Add performance monitoring
   - Optimize widget rebuilds
   - Improve animation performance

2. **Testing Architecture**

   - Add unit test infrastructure
   - Implement integration tests
   - Add performance tests

3. **Logging Architecture**
   - Implement structured logging
   - Add error reporting
   - Add performance metrics

### **Phase 3: Optimization (Long-term)**

1. **Scalability Architecture**

   - Optimize for larger user bases
   - Improve server architecture
   - Add caching strategies

2. **Security Architecture**

   - Add input validation
   - Implement rate limiting
   - Add security headers

3. **Analytics Architecture**
   - Add user behavior tracking
   - Implement performance analytics
   - Add business metrics

---

## 🔧 **Implementation Priority**

### **Critical (Fix First)**

1. **MaterialApp Structure** - Add proper localization
2. **Error Boundaries** - Prevent cascading failures
3. **Navigator Context** - Fix navigation issues
4. **Audio Service** - Clean up file references

### **High Priority**

1. **Safe Dialog System** - Implement error-safe dialogs
2. **Safe Navigation** - Implement error-safe navigation
3. **Error Logging** - Add comprehensive error tracking
4. **Performance Monitoring** - Add performance metrics

### **Medium Priority**

1. **Testing Infrastructure** - Add automated testing
2. **Documentation** - Update architecture docs
3. **Code Quality** - Add linting and formatting
4. **Security** - Add security measures

---

**Next Steps**: Focus on critical architecture fixes first, then build upon the stable foundation with enhanced error handling and performance improvements.
