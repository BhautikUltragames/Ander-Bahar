# 🎴 Andar Bahar Game Rules

## 🎯 Overview

**Andar Bahar** (अंदर बाहर) is a traditional Indian card game that has been enjoyed for generations. This digital implementation brings the authentic experience to your web browser with both single-player and multiplayer modes.

## 🎮 Current Game Modes

### ✅ **Single Player Mode** (Ready to Play)

- Play against an intelligent AI opponent
- Immediate gameplay - no setup required
- Perfect for learning the game or quick entertainment

### 🌐 **Multiplayer Mode** (Server Setup Required)

- Play with 2-6 friends online
- Real-time synchronized gameplay
- Requires Node.js WebSocket server to be running

## 🃏 Basic Game Setup

### **Equipment**

- **Single Deck**: Standard 52-card deck (no jokers)
- **Two Sides**: Andar (अंदर - Inside/Left) and Bahar (बाहर - Outside/Right)
- **Starting Balance**: 5000 chips per player

### **Objective**

Predict which side (Andar or Bahar) will receive the first card that matches the rank of the Joker card.

## 📋 How to Play

### **Step 1: Place Your Bet**

1. **Choose Bet Amount**: Select from 25, 50, 100, 250, or 500 chips
2. **Select Side**: Click either ANDAR (left) or BAHAR (right) button
3. **Timing**:
   - Single Player: Take your time, 5-second UI countdown starts when you bet
   - Multiplayer: All players have 10 seconds to place bets (5-second UI countdown)

### **Step 2: Joker Reveal**

- A random card is drawn and placed in the center as the "Joker"
- This card determines the target rank to match
- The joker's color determines the dealing pattern

### **Step 3: Card Dealing**

- Cards are dealt alternately to Andar and Bahar sides
- **Starting Rule**:
  - **Black Joker** (♣ Clubs, ♠ Spades): First card goes to **Andar**
  - **Red Joker** (♥ Hearts, ♦ Diamonds): First card goes to **Bahar**
- Cards continue alternating until a match is found

### **Step 4: Winning**

- The first side to receive a card matching the Joker's rank wins
- All bets on the winning side receive payouts
- Losing bets are forfeited

## 💰 Betting & Payouts

### **Available Bet Amounts**

- 25 chips (minimum)
- 50 chips
- 100 chips
- 250 chips
- 500 chips (maximum)

### **Payout Ratios**

- **Andar Wins**: 0.9:1 (bet 100, win 190 total)
- **Bahar Wins**: 1:1 (bet 100, win 200 total)

### **Why Different Payouts?**

Andar has a slight statistical advantage due to the dealing pattern, so it pays slightly less to maintain game balance.

## 🎲 Game Flow Examples

### **Single Player Example**

1. You have 5000 chips
2. Select 100 chips and click BAHAR
3. 5-second UI countdown begins, AI automatically places counter-bet
4. Joker revealed: 7♥ (red card)
5. First card goes to Bahar: 3♠
6. Second card goes to Andar: K♦
7. Third card goes to Bahar: 7♣ - **BAHAR WINS!**
8. You win 200 chips (100 bet + 100 payout)
9. New round starts automatically

### **Multiplayer Example** (When Server Running)

1. 4 players in room, each with 5000 chips
2. Host starts the game
3. 10-second betting timer for all players (5-second UI countdown)
4. Player 1 bets 250 on Andar, Player 2 bets 100 on Bahar
5. Joker revealed: Q♠ (black card)
6. Cards dealt starting with Andar
7. Game continues until Queen is matched
8. Winners receive payouts, balances updated for all players

## ⚡ Special Rules & Features

### **Immediate Countdown (Single Player)**

- No waiting periods - place your bet and play instantly
- 5-second UI countdown creates excitement
- AI opponent ensures dynamic gameplay

### **Synchronized Betting (Multiplayer)**

- All players must bet within the same 10-second window (5-second UI countdown)
- No late bets accepted after timer expires
- Host manually starts initial game, then new rounds auto-start
- Games continue even if players disconnect during betting/dealing

### **Automatic Progression**

- New rounds start automatically after results
- Balances update in real-time
- Confetti celebrations for wins

## 🎯 Strategy Tips

### **Basic Strategy**

- **Andar Advantage**: Slightly better odds but lower payout
- **Bahar Strategy**: Higher risk, higher reward
- **Bankroll Management**: Don't bet more than you can afford to lose

### **Advanced Tips**

- Watch for patterns in Joker colors (though each round is independent)
- In multiplayer, observe other players' betting patterns
- Start with smaller bets to learn the game rhythm

### **Psychological Aspects**

- Stay calm during losing streaks
- Don't chase losses with bigger bets
- Enjoy the social aspect in multiplayer mode

## 🌍 Cultural Context

### **Traditional Origins**

- Ancient Indian card game, also known as "Katti"
- Popular in Indian casinos and family gatherings
- Simple rules make it accessible to all ages

### **Modern Adaptation**

- This digital version maintains authentic rules
- Added modern UI and multiplayer capabilities
- Preserves the excitement of the traditional game

## 🔧 Technical Implementation

### **Game Logic**

- True random card shuffling
- Fair dealing algorithm
- Accurate payout calculations
- Real-time balance tracking

### **Multiplayer Synchronization**

- Server-authoritative game state
- WebSocket real-time communication
- Automatic reconnection handling
- Fair play enforcement

## ❓ Frequently Asked Questions

### **Q: Is the game fair?**

A: Yes, the game uses true random number generation for card shuffling and dealing.

### **Q: Can I play without internet?**

A: Single-player mode works offline after initial load. Multiplayer requires internet connection.

### **Q: Why can't I access multiplayer?**

A: Multiplayer requires the WebSocket server to be running. See setup instructions in README.md.

### **Q: What happens if I disconnect during a multiplayer game?**

A: You have 10 seconds to reconnect. Games continue even if players disconnect during active rounds. Your bets and balance are preserved.

### **Q: Can I change my bet after placing it?**

A: No, bets are final once placed. Choose carefully!

### **Q: Is there a maximum number of cards that can be dealt?**

A: Theoretically, a match could take many cards, but statistically, most games end within 10-15 cards.

## 🎊 Winning & Celebrations

### **Win Indicators**

- Confetti animation for wins
- Balance increase notification
- Visual highlighting of winning side

### **Statistics Tracking**

- Real-time balance updates
- Win/loss tracking (visual only)
- Game history (session-based)

## 🚀 Getting Started

### **Single Player (Immediate)**

1. Run `flutter run -d chrome`
2. Click "HUMAN vs AI"
3. Start playing immediately!

### **Multiplayer (Setup Required)**

1. Install Node.js
2. Start server: `cd server && npm start`
3. Click "MULTIPLAYER"
4. Create or join rooms with friends

---

_Enjoy playing Andar Bahar! May luck be on your side! 🍀_
