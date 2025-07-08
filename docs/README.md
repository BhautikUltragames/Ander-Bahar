# 🃏 Andar Bahar - Traditional Indian Card Game

**A modern Flutter implementation of the classic Andar Bahar card game with real-time multiplayer support and professional UI**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-22.17-green.svg)](https://nodejs.org/)
[![Status](https://img.shields.io/badge/Status-Under%20Maintenance-orange.svg)](https://github.com/BhautikUltragames/Ander-Bahar.git)

---

## ⚠️ **CRITICAL ISSUES - IMMEDIATE ATTENTION REQUIRED**

### **Current Status: UNSTABLE**

**❌ The app is experiencing severe technical issues that prevent stable operation. All features are implemented but critical bugs cause frequent crashes.**

---

## 🚨 **CRITICAL TECHNICAL PROBLEMS**

### **1. MaterialLocalizations Error (App Breaking)**

**Error Message:**

```
No MaterialLocalizations found.
AndarBaharApp widgets require MaterialLocalizations to be provided by a Localizations widget ancestor.
```

**Impact**:

- ❌ All dialog boxes crash the app immediately
- ❌ Error handling is completely broken
- ❌ User feedback mechanisms don't work
- ❌ App becomes unusable when errors occur

**Current Status**: **BLOCKING** - Prevents normal app operation

### **2. Navigator Context Error (Navigation Failure)**

**Error Message:**

```
Navigator operation requested with a context that does not include a Navigator.
```

**Impact**:

- ❌ Navigation between screens fails unpredictably
- ❌ Back button functionality broken
- ❌ App flow is severely disrupted
- ❌ Users get trapped in error states

**Current Status**: **BLOCKING** - Prevents proper navigation

### **3. Widget Unmounting Issues (App Crashes)**

**Error Pattern**: Flutter framework unmounting widgets unexpectedly during gameplay

**Impact**:

- ❌ App crashes mid-game without warning
- ❌ User sessions are lost
- ❌ Gameplay becomes impossible
- ❌ No recovery mechanism available

**Current Status**: **CRITICAL** - Makes app unusable

### **4. Audio System Issues (Runtime Errors)**

**Issue**: Audio service references deleted files (`StarCollect.wav` removed, `Button.wav` added)

**Impact**:

- ⚠️ Audio playback failures
- ⚠️ Potential runtime errors
- ⚠️ Degraded user experience
- ⚠️ May contribute to app instability

**Current Status**: **NEEDS CLEANUP** - Requires immediate attention

---

## 🛠️ **TROUBLESHOOTING GUIDE**

### **For Users (Current Workarounds)**

#### **If App Crashes on Launch:**

1. **Use Incognito/Private Mode** - Avoid cached error states
2. **Clear Browser Cache** - Reset application state
3. **Refresh Page** - Force app restart
4. **Try Different Browser** - Some browsers may be more stable

#### **If Navigation Fails:**

1. **Use Browser Back Button** - May work when app back button doesn't
2. **Refresh and Restart** - Reset navigation state
3. **Avoid Rapid Clicks** - Give time for navigation to complete
4. **Use Direct URLs** - Bookmark specific game screens

#### **If Dialogs Don't Appear:**

1. **Expect Silent Failures** - Dialogs crash silently
2. **Watch Console** - Check browser dev tools for errors
3. **Restart When Stuck** - Refresh to reset state
4. **Don't Rely on Error Messages** - App can't show them properly

#### **If Audio Fails:**

1. **Expect No Audio** - Audio system may not work
2. **Ignore Audio Errors** - Don't affect core gameplay
3. **Play Without Sound** - Game is fully functional without audio

### **For Developers (Debug Information)**

#### **Error Reproduction:**

```bash
# Launch app
flutter run -d chrome

# Trigger MaterialLocalizations error:
# - Try to show any dialog
# - App will crash with localization error

# Trigger Navigator error:
# - Navigate between screens
# - Context hierarchy will fail
```

#### **Quick Debug Steps:**

1. **Check Console** - Browser dev tools show detailed errors
2. **Monitor Network** - WebSocket server continues to work
3. **Test Server Separately** - Backend functionality is stable
4. **Use Safe Mode** - Disable error-prone features

---

## 🎯 **CURRENT FUNCTIONALITY STATUS**

### **What Currently Works (When Stable)**

- ✅ **Core Game Logic** - Traditional Andar Bahar rules
- ✅ **UI Components** - Modern design with hover animations
- ✅ **WebSocket Server** - Multiplayer backend is stable
- ✅ **Animated Card Dealer** - Professional card dealing animations
- ✅ **Color Psychology** - Blue ANDAR vs Yellow BAHAR

### **What Needs Fixing**

- ❌ **Dialog System** - MaterialLocalizations error
- ❌ **Navigation System** - Navigator context error
- ❌ **Audio System** - File reference cleanup needed
- ❌ **Stability** - App crashes during gameplay

---

## 🔧 **Developer Notes**

### **For Developers Working on Fixes**

1. **Priority 1**: Fix MaterialApp structure to provide proper localization context
2. **Priority 2**: Implement error boundaries to prevent crashes
3. **Priority 3**: Clean up audio service file references
4. **Priority 4**: Add comprehensive error handling

### **Testing Recommendations**

- Test in incognito mode to avoid cached errors
- Use browser developer tools to monitor console errors
- Test navigation flows carefully
- Verify audio functionality after fixes

---

## 🎮 **Game Overview**

Andar Bahar is a traditional Indian gambling card game that originated in South India. This digital version brings the authentic experience to the web with beautiful animations, interactive hover effects, animated card dealer, and real-time multiplayer support.

### 🌟 **Planned Features** (When Issues Are Fixed)

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

## 🚀 **Setup Instructions (HIGH RISK - Use with Extreme Caution)**

⚠️ **CRITICAL WARNING**: These instructions are for development/debugging purposes only. The app is currently unstable and will crash frequently.

### **Single Player Mode (Expect Crashes)**

```bash
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game
flutter pub get
flutter run -d chrome
```

**⚠️ CRITICAL ISSUES TO EXPECT**:

- ❌ **App will crash** when any dialog tries to display
- ❌ **Navigation will fail** due to context errors
- ❌ **Audio system will malfunction** due to file reference issues
- ❌ **Widgets will unmount unexpectedly** causing crashes
- ❌ **No error recovery** - crashes require full restart

**⚠️ TESTING RECOMMENDATIONS**:

- Use **incognito mode** to avoid cached errors
- Keep **browser dev tools open** to monitor crashes
- **Expect frequent restarts** - app is not stable
- **Don't rely on error messages** - they cause crashes

### **Multiplayer Mode (Server Stable, Client Crashes)**

```bash
# Terminal 1: Start WebSocket server (This works perfectly)
.\start_server.bat    # Windows
# OR
./start_server.sh     # Linux/Mac

# Terminal 2: Start Flutter app (This will crash frequently)
flutter run -d chrome
```

**⚠️ MULTIPLAYER ISSUES TO EXPECT**:

- ✅ **WebSocket server works perfectly** - no issues here
- ❌ **Client crashes prevent stable multiplayer** - frontend issues
- ❌ **Connection drops due to crashes** - client-side instability
- ❌ **Players get disconnected** due to navigation errors
- ❌ **No graceful error handling** - crashes interrupt gameplay

**⚠️ MULTIPLAYER TESTING TIPS**:

- **Test server separately** - use WebSocket testing tools
- **Multiple browser tabs** - test server stability
- **Expect client disconnects** - server continues working
- **Monitor server console** - shows stable operation

---

## 🎨 **Enhanced User Experience (When Working)**

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

## ❌ **WHAT'S CURRENTLY BROKEN**

### **Complete Single Player System (Unusable)**

- ❌ **CRITICAL: App Crashes** - MaterialLocalizations error crashes all dialogs
- ❌ **CRITICAL: Navigation Broken** - Context errors prevent screen transitions
- ❌ **CRITICAL: Widget Unmounting** - App crashes mid-game unexpectedly
- ❌ **HIGH: Audio System** - File reference issues cause runtime errors
- ❌ **BLOCKING: Error Handling** - No error recovery mechanisms
- ❌ **RESULT: Unusable** - App cannot be used reliably

### **Complete Multiplayer System (Server Works, Client Unusable)**

- ✅ **Server Functionality** - WebSocket server is completely stable
- ❌ **CRITICAL: Client Crashes** - Frontend crashes prevent any multiplayer
- ❌ **CRITICAL: Connection Drops** - Client instability breaks connections
- ❌ **CRITICAL: Navigation Errors** - Context errors trap users
- ❌ **BLOCKING: No Error Recovery** - Crashes require complete restart
- ❌ **RESULT: Unusable** - Multiplayer impossible due to client crashes

---

## 🎯 **Game Modes (When Fixed)**

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

### **Frontend (Flutter Web) - ⚠️ Issues Present**

- **Framework** - Flutter 3.19+ for web
- **State Management** - Provider pattern with reactive UI
- **Interactive Elements** - MouseRegion + AnimatedScale for hover effects
- **Animated Card Dealer** - Custom widget with flying card animations
- **Real-time Communication** - WebSocket integration
- **Responsive Design** - MediaQuery-based sizing (70% width buttons)
- **Smooth Animations** - 60fps card dealing and 200ms hover transitions
- **❌ Error Handling** - Needs fixes for MaterialLocalizations and Navigator context

### **Backend (Node.js) - ✅ Working**

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

## 🚀 **Deployment (Currently Limited)**

### **Local Development**

```bash
# Clone and setup
git clone https://github.com/BhautikUltragames/Ander-Bahar.git
cd andar_bahar_game
flutter pub get

# Start server (this works fine)
.\start_server.bat    # Windows
./start_server.sh     # Linux/Mac

# Start app (this has issues)
flutter run -d chrome
```

**Note**: Expect crashes and limited functionality due to current issues.

### **Production Deployment**

⚠️ **Not recommended until issues are resolved**

The app needs the following fixes before production deployment:

1. MaterialLocalizations error resolution
2. Navigator context error fixes
3. Audio system cleanup
4. Comprehensive error handling

---

## 🎯 **Future Roadmap**

### **Immediate Fixes Needed**

1. **Fix MaterialApp Structure** - Resolve localization issues
2. **Implement Error Boundaries** - Prevent crashes
3. **Clean Audio System** - Update file references
4. **Add Comprehensive Testing** - Prevent regressions

### **Enhancement Goals**

1. **Improved Error Messages** - Better user feedback
2. **Enhanced Stability** - Robust error handling
3. **Performance Optimization** - Faster loading and rendering
4. **Additional Features** - New game modes and options

---

## 📞 **Support & Issues**

### **Reporting Issues**

If you encounter issues (which are expected currently):

1. **Check Console Logs** - Use browser developer tools
2. **Note Error Messages** - Document specific error text
3. **Report Context** - What you were doing when the error occurred
4. **Include Screenshots** - Visual evidence of issues

### **Developer Support**

For developers working on fixes:

1. **Focus on MaterialApp Structure** - Primary issue
2. **Implement Error Boundaries** - Prevent cascading failures
3. **Test Navigation Flows** - Verify context hierarchy
4. **Validate Audio References** - Clean up file dependencies

---

## 🎮 **Conclusion**

This Andar Bahar game represents a comprehensive digital recreation of the traditional Indian card game with modern UI/UX enhancements. While the current version has critical issues that need resolution, the underlying architecture and feature set are solid foundations for a professional gaming experience.

**Current Status**: Under maintenance - use with caution and expect instability.

**Future Potential**: Once issues are resolved, this will be a production-ready, accessible, and engaging digital card game experience.

---

_For the latest updates on issue resolution and new features, check the project's STATUS.md file._
