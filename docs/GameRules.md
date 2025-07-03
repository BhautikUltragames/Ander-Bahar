# 🎴 Andar Bahar Game Rules & Features

## 🎮 **Game Overview**

**Andar Bahar** is a traditional Indian card game that has been enjoyed for generations. This digital version brings the authentic experience to modern web browsers with beautiful animations, interactive hover effects, animated card dealer, and both single-player and real-time multiplayer modes.

---

## 🎨 **Visual Design & Color Scheme**

### **Color Psychology**

Our game uses color psychology to enhance the gaming experience:

- **🔵 ANDAR (Blue)** - Represents trust, stability, and tradition
- **🟡 BAHAR (Yellow)** - Represents luck, prosperity, and positive energy
- **🟢 PLAY (Green)** - Encourages action and forward movement
- **🟠 REBET (Orange)** - Secondary action, complementary to the main scheme

### **Interactive Elements**

- **Hover Animations** - All buttons scale to 1.05x on hover with smooth 200ms transitions
- **Visual Feedback** - Immediate response to user interactions
- **High Contrast Text** - Black text on yellow backgrounds, white text on blue backgrounds
- **Accessibility Compliant** - WCAG AA compliant color combinations
- **Animated Card Dealer** - Professional card dealing with flying card animations

---

## 🎯 **Traditional Game Rules**

### **Basic Concept**

Andar Bahar is a simple yet exciting betting game where players predict which side (🔵 Andar or 🟡 Bahar) will first receive a card matching the Joker card's rank.

### **Game Setup**

1. **Deck**: Standard 52-card deck is used
2. **Sides**: Two sides - **🔵 Andar** (left, blue) and **🟡 Bahar** (right, yellow)
3. **Joker**: First card drawn becomes the "Joker" card (displayed on yellow background)
4. **Starting Balance**: Each player begins with ₹5000
5. **Animated Dealer**: Professional card dealing system with flying animations

### **Game Flow**

1. **Joker Selection**: A random card is drawn and placed in center on yellow background
2. **Betting Phase**: Players have 10 seconds to place bets on 🔵 Andar or 🟡 Bahar
3. **Animated Card Dealing**: Cards fly from dealer to color-coded sides with smooth animations
4. **Starting Side Rule**:
   - If Joker is **RED** (♥♦): First card goes to **🟡 Bahar** (yellow pile)
   - If Joker is **BLACK** (♣♠): First card goes to **🔵 Andar** (blue pile)
5. **Winning**: First side to receive a card matching Joker's rank wins
6. **Payouts**: Winners receive their bet back plus profit

### **Payout System**

- **House Edge**: 5% (95% payout to winners)
- **🔵 Andar Wins**: 95% return on bet (0.95:1 payout)
- **🟡 Bahar Wins**: 95% return on bet (0.95:1 payout)
- **Example**: Bet ₹100 on winning side → Receive ₹195 total (₹95 profit)

---

## 🎮 **Game Modes**

### 🎯 **Single Player Mode**

**Perfect for learning and practicing!**

#### Features:

- **One-Click Access** - Streamlined "PLAY" button with hover animation
- **Smart AI Opponent** - Computer automatically places bets
- **Animated Card Dealer** - Professional flying card animations
- **Offline Mode** - Works without internet connection
- **Interactive UI** - Hover effects and visual feedback throughout
- **Color-Coded Betting** - Blue ANDAR vs Yellow BAHAR for easy recognition

#### How to Play:

1. Click **"PLAY"** from main menu (notice the hover effect!)
2. Choose your bet amount (₹25, ₹50, ₹100, ₹250, ₹500)
3. Select **🔵 ANDAR** (blue button) or **🟡 BAHAR** (yellow button)
4. AI automatically places a counter-bet
5. Watch animated card dealer dealing cards with flying animations
6. Celebrate wins with appropriate color-themed celebrations!

---

### 🌐 **Real-time Multiplayer Mode**

**Play with friends and other players online!**

#### Features:

- ✅ **Global Room System** - Single shared room for all players
- ✅ **Continuous Rounds** - New round every 10 seconds automatically
- ✅ **Unlimited Players** - Join anytime, no capacity limits
- ✅ **Real-time Updates** - Live game state synchronization
- ✅ **Complete Player Management** - Instant join/leave functionality
- ✅ **Cross-browser Support** - Test with multiple browser tabs
- ✅ **Interactive Elements** - Hover animations on all multiplayer buttons
- ✅ **Synchronized Animations** - All players see same flying card animations

#### How to Join:

1. **Start Server**: Run `.\start_server.bat` (Windows) or `./start_server.sh` (Linux/Mac)
2. **Launch Game**: Run `flutter run -d chrome`
3. **Enter Game**: Click **"PLAY"** from main menu (hover animation active)
4. **Join Multiplayer**: Click "MULTIPLAYER" button with hover effect
5. **Start Playing**: Continuous 10-second betting rounds begin

#### Multiplayer Game Flow:

1. **Auto-Join**: Instantly connected to global room with ₹5000 balance
2. **Live Player Panel**: See all players and their current round bets
3. **Enhanced Betting**: 10 seconds to place bets on color-coded buttons
   - **🔵 ANDAR** - Blue button with white text
   - **🟡 BAHAR** - Yellow button with black text (for readability)
4. **Real-time Updates**: Watch other players' bets in real-time
5. **Synchronized Dealing**: All players see same animated card dealer with flying cards
6. **Results Display**: Winners shown with appropriate color themes
7. **Continuous Rounds**: New round starts automatically every 10 seconds
8. **Join Anytime**: Late joiners can watch current round, bet in next

#### Leave Game:

1. **Hover Back Button**: Visual feedback with scale animation
2. **Confirmation Dialog**: Clean dialog with consistent styling
3. **Clean Disconnection**: WebSocket properly disconnected
4. **Instant Removal**: Player disappears from all other players' screens immediately
5. **Return to Menu**: Navigate back to main menu with hover effects

---

## 💰 **Enhanced Betting System**

### **Chip Denominations**

- **₹25** - Small bets for cautious players
- **₹50** - Standard betting amount
- **₹100** - Medium risk betting
- **₹250** - High stakes gaming
- **₹500** - Maximum bet per round

### **Visual Betting Interface**

- **🔵 ANDAR Button** - Blue background, white text, hover animation
- **🟡 BAHAR Button** - Yellow background, black text, hover animation
- **Color-Coded Feedback** - Immediate visual response to selections
- **High Contrast** - Optimized for readability and accessibility

### **Betting Rules**

- **Time Limit**: 10 seconds per round to place bets
- **Multiple Bets**: Can bet on both 🔵 Andar and 🟡 Bahar in same round
- **Balance Check**: Server validates sufficient balance before accepting bets
- **Instant Deduction**: Money deducted immediately when bet is placed
- **Visual Confirmation**: Color-coded feedback for successful bets

### **Payout Calculation**

```
Winning Bet = Bet Amount × 1.95
Total Received = Original Bet + (Bet Amount × 0.95)
House Edge = 5% of winning bets
```

**Example Scenarios:**

- Bet ₹100 on 🔵 Andar, Andar wins → Receive ₹195 (₹95 profit)
- Bet ₹250 on 🟡 Bahar, Bahar wins → Receive ₹487.50 (₹237.50 profit)
- Bet ₹500 on losing side → Lose ₹500

---

## 🎯 **Player Management System**

### **Joining the Game**

- **Single Player**: One-click "PLAY" button access with hover animation
- **Multiplayer**: Clean "MULTIPLAYER" interface with visual feedback
- **Starting Balance**: ₹5000 for all new players
- **Unique ID**: System assigns unique player identifier

### **Active Player Features**

- **Real-time Balance**: Live updates after each round
- **Color-Coded Betting History**: See your current round bets with proper colors
- **Enhanced Player List**: View all active players and their bets
- **Interactive Statistics**: Round number and betting countdown with hover effects
- **Animated Gameplay**: Professional card dealing with flying animations

### **Leave System (Multiplayer)**

- **Hover Feedback**: Visual response when hovering over back button
- **Proper Disconnect**: Clean WebSocket termination
- **Instant Removal**: Player disappears from all screens immediately
- **No Ghost Players**: Complete cleanup from server memory
- **Real-time Updates**: All other players notified instantly

---

## ⏰ **Round Management**

### **Single Player Rounds**

- **Manual Start**: Player initiates by placing bet
- **AI Response**: Computer automatically places counter-bet
- **5-Second Countdown**: Visual timer with animated feedback
- **Animated Dealing**: Professional card dealing with flying animations
- **Automatic Progression**: New round starts after results display

### **Multiplayer Rounds**

- **Continuous Cycles**: Automatic 10-second betting windows
- **Synchronized Timer**: All players see same countdown
- **Real-time Betting**: Live updates of all player bets
- **Synchronized Dealing**: All players see same animated card dealer
- **Instant Results**: Winners calculated and displayed immediately
- **No Interruption**: Rounds continue even if players disconnect during dealing

---

## 🎪 **Animation Features**

### **Animated Card Dealer**

- **Flying Cards**: Cards fly from dealer position to piles with smooth animations
- **Professional Timing**: 350ms flight duration for realistic feel
- **Synchronized Multiplayer**: All players see identical animations
- **Performance Optimized**: Efficient animation controllers for smooth gameplay

### **Interactive Animations**

- **Hover Effects**: 1.05x scale on all interactive elements
- **Button Feedback**: Immediate visual response to user actions
- **Smooth Transitions**: 200ms duration for professional feel
- **Color Transitions**: Smooth color changes during state updates

### **Visual Polish**

- **🔵 ANDAR Side** - Blue pile on left, white text, trust-based color
- **🟡 BAHAR Side** - Yellow pile on right, black text, luck-based color
- **🟡 Joker Card** - Center position with yellow background
- **Balance Display** - Clear, readable font with consistent styling
- **Timer** - Visual countdown with smooth transitions

### **Interactive Feedback**

- **Hover Animations** - 200ms smooth scaling on all interactive elements
- **Visual Confirmation** - Immediate feedback for all user actions
- **Color Psychology** - Strategic use of colors to enhance user experience
- **Accessibility** - High contrast ratios for all text combinations

---

## 🎪 **Special Features**

### **Accessibility Features**

- **WCAG AA Compliance** - All color combinations meet accessibility standards
- **High Contrast Text** - Optimized readability on all backgrounds
- **Visual Hierarchy** - Clear information structure and priority
- **Interactive Feedback** - Immediate response to user actions
- **Keyboard Navigation** - Full keyboard accessibility support

### **Performance Features**

- **Smooth Animations** - 60fps transitions throughout the game
- **Optimized Interactions** - Instant hover response (<16ms)
- **Responsive Design** - Adapts to different screen sizes
- **Memory Efficient** - Clean player removal, no memory leaks
- **Professional Polish** - Consistent timing and visual feedback

### **Color Scheme Benefits**

- **🔵 Blue (ANDAR)** - Promotes trust and confidence in betting
- **🟡 Yellow (BAHAR)** - Evokes feelings of luck and prosperity
- **Psychology-Based** - Colors chosen for optimal gaming experience
- **Cultural Relevance** - Respects traditional Indian color associations

---

## 🏆 **Winning Strategies**

### **Understanding the Game**

- **Random Outcome** - Each round is independent and random
- **50/50 Odds** - Both sides have equal probability (minus house edge)
- **Manage Bankroll** - Bet responsibly within your means
- **Enjoy the Experience** - Focus on the entertainment value and animations

### **Visual Cues**

- **Color Recognition** - Learn to quickly identify 🔵 Andar vs 🟡 Bahar
- **Animation Timing** - Watch the animated card dealer for engaging gameplay
- **Hover Feedback** - Use interactive elements for better engagement
- **Pattern Awareness** - Observe but remember each round is independent

---

## 🎯 **Game Features Summary**

### **Single Player Experience**

✅ **Instant Play** - No setup required, works offline  
✅ **AI Opponent** - Smart computer player with auto-betting  
✅ **Animated Card Dealer** - Professional flying card animations  
✅ **Interactive UI** - Hover effects and visual feedback  
✅ **Color Psychology** - Blue vs Yellow for optimal experience

### **Multiplayer Experience**

✅ **Global Room** - Single shared room for all players  
✅ **Real-time Sync** - Live updates and synchronized animations  
✅ **Continuous Rounds** - Automatic 10-second betting cycles  
✅ **Professional Animations** - Flying cards synchronized for all players  
✅ **Cross-browser** - Works on all modern browsers

### **Technical Excellence**

✅ **Performance** - Smooth 60fps animations  
✅ **Accessibility** - WCAG AA compliant design  
✅ **Responsive** - Optimized for all screen sizes  
✅ **Professional** - High-quality visual polish  
✅ **Reliable** - Stable multiplayer connections

---

**🎮 Experience the most authentic and visually stunning digital Andar Bahar game with professional animations and interactive design! 🎮**
