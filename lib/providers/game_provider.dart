import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/card.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState();
  Timer? _bettingTimer;
  Timer? _dealingTimer;
  String _currentPlayerId = 'player_1';
  
  // Getters
  GameState get gameState => _gameState;
  String get currentPlayerId => _currentPlayerId;
  
  // Initialize player with starting balance
  void initializePlayer(String playerId, {int startingBalance = 5000}) {
    _gameState.playerBalances[playerId] = startingBalance;
    _currentPlayerId = playerId;
    notifyListeners();
  }

  // Start multiplayer game
  void startMultiplayerGame() {
    _gameState = GameState(isMultiplayer: true);
    
    // Initialize player balance
    initializePlayer('player_1', startingBalance: 5000);
    
    startNewRound();
  }

  // Start new round
  void startNewRound() {
    _bettingTimer?.cancel();
    _dealingTimer?.cancel();
    
    _gameState.startNewRound();
    notifyListeners();
    
    // Start 10-second betting timer
    _startBettingTimer();
  }

  // Place a bet
  void placeBet(BetSide side, int amount) {
    if (_gameState.phase != GamePhase.betting) return;
    
    // Use the existing GameState method to place bet
    bool success = _gameState.placeBet(side, amount, _currentPlayerId);
    
    if (success) {
      notifyListeners();
    }
  }

  // Start 10-second betting timer
  void _startBettingTimer() {
    if (_gameState.phase != GamePhase.betting) return;
    
    _bettingTimer = Timer(const Duration(seconds: 10), () {
      if (_gameState.phase == GamePhase.betting) {
        _gameState.phase = GamePhase.readyToPlay;
        notifyListeners();
        _startCountdownTimer();
      }
    });
  }

  // Automatic countdown timer (5 seconds)
  void _startCountdownTimer() {
    if (_gameState.phase != GamePhase.readyToPlay) return;
    
    Timer(const Duration(seconds: 5), () {
      if (_gameState.phase == GamePhase.readyToPlay) {
        _startDealing();
      }
    });
  }

  // Start dealing phase
  void _startDealing() {
    if (_gameState.phase != GamePhase.readyToPlay) return;
    
    // Reveal joker card
    _gameState.revealJoker();
    notifyListeners();
    
    // Wait 0.7s then start dealing cards
    Timer(const Duration(milliseconds: 700), () {
      _startDealingCards();
    });
  }

  // Start dealing cards automatically
  void _startDealingCards() {
    _dealingTimer?.cancel();
    
    _dealingTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      PlayingCard? dealtCard = _gameState.dealNextCard();
      
      if (dealtCard != null) {
        notifyListeners();
        
        // Check if game is finished
        if (_gameState.phase == GamePhase.finished) {
          timer.cancel();
          _finishRound();
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Finish the round
  void _finishRound() {
    _gameState.phase = GamePhase.showResult;
    _gameState.applyPayouts();
    
    notifyListeners();
    
    // Show result for 1.5s then prepare for next round
    Timer(const Duration(milliseconds: 1500), () {
      if (_canStartNewRound()) {
        Timer(const Duration(seconds: 2), () {
          startNewRound();
        });
      } else {
        _gameState.phase = GamePhase.waiting;
        notifyListeners();
      }
    });
  }

  // Check if new round can be started
  bool _canStartNewRound() {
    // Check if any player has enough balance to continue
    return _gameState.playerBalances.values.any((balance) => balance >= 25);
  }

  // Get player balance
  int getPlayerBalance(String playerId) {
    return _gameState.playerBalances[playerId] ?? 0;
  }

  // Get current player's bet
  Bet? getCurrentPlayerBet() {
    return _gameState.getPlayerBet(_currentPlayerId);
  }

  // Get all current player's bets
  List<Bet> getCurrentPlayerBets() {
    return _gameState.getPlayerBets(_currentPlayerId);
  }

  // Get current player's total bet amount
  int getCurrentPlayerTotalBet() {
    return _gameState.getPlayerTotalBetAmount(_currentPlayerId);
  }

  // Quick bet functions for common amounts
  void quickBet25(BetSide side) => placeBet(side, 25);
  void quickBet50(BetSide side) => placeBet(side, 50);
  void quickBet100(BetSide side) => placeBet(side, 100);
  void quickBet250(BetSide side) => placeBet(side, 250);

  // Rebet - place same bet as last round
  void rebet() {
    // This would need to store last bet info
    // For now, just place a default bet
    placeBet(BetSide.andar, 50);
  }

  // Add chips (for testing or ads reward)
  void addChips(String playerId, int amount) {
    _gameState.playerBalances[playerId] = 
        (_gameState.playerBalances[playerId] ?? 0) + amount;
    notifyListeners();
  }

  // Force start dealing (for testing/debugging)
  void forceStartDealing() {
    if (_gameState.phase == GamePhase.betting || _gameState.phase == GamePhase.readyToPlay) {
      _startDealing();
    }
  }

  // Get game statistics
  Map<String, dynamic> getGameStats() {
    return {
      'totalCardsDealt': _gameState.totalCardsDealt,
      'andarCards': _gameState.andarCards.length,
      'baharCards': _gameState.baharCards.length,
      'totalBets': _gameState.bets.length,
      'andarBetTotal': _gameState.getTotalBetForSide(BetSide.andar),
      'baharBetTotal': _gameState.getTotalBetForSide(BetSide.bahar),
    };
  }

  @override
  void dispose() {
    _bettingTimer?.cancel();
    _dealingTimer?.cancel();
    super.dispose();
  }
} 