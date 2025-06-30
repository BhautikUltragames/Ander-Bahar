import 'card.dart';

enum GamePhase {
  waiting,     // Waiting for players
  betting,     // Betting phase
  readyToPlay, // Ready to start dealing (waiting for play button)
  dealing,     // Cards being dealt
  finished,    // Round finished
  showResult   // Showing results
}

enum BetSide { andar, bahar }

class Bet {
  final BetSide side;
  final int amount;
  final String playerId;
  
  Bet({
    required this.side,
    required this.amount,
    required this.playerId,
  });
}

class GameState {
  GamePhase phase;
  PlayingCard? jokerCard;
  List<PlayingCard> andarCards;
  List<PlayingCard> baharCards;
  List<PlayingCard> deck;
  List<Bet> bets;
  BetSide? winningSide;
  int totalCardsDealt;
  bool isMultiplayer;
  String? gameId;
  Map<String, int> playerBalances;
  
  GameState({
    this.phase = GamePhase.waiting,
    this.jokerCard,
    List<PlayingCard>? andarCards,
    List<PlayingCard>? baharCards,
    List<PlayingCard>? deck,
    List<Bet>? bets,
    this.winningSide,
    this.totalCardsDealt = 0,
    this.isMultiplayer = false,
    this.gameId,
    Map<String, int>? playerBalances,
  }) : andarCards = andarCards ?? [],
       baharCards = baharCards ?? [],
       deck = deck ?? [],
       bets = bets ?? [],
       playerBalances = playerBalances ?? {};

  // Create a fresh deck of 52 cards
  List<PlayingCard> createDeck() {
    List<PlayingCard> newDeck = [];
    for (Suit suit in Suit.values) {
      for (Rank rank in Rank.values) {
        newDeck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    return newDeck;
  }

  // Shuffle the deck
  void shuffleDeck() {
    deck.shuffle();
  }

  // Start new round
  void startNewRound() {
    phase = GamePhase.betting;
    jokerCard = null;
    andarCards.clear();
    baharCards.clear();
    bets.clear();
    winningSide = null;
    totalCardsDealt = 0;
    deck = createDeck();
    shuffleDeck();
  }

  // Place a bet
  bool placeBet(BetSide side, int amount, String playerId) {
    if (phase != GamePhase.betting) return false;
    if (playerBalances[playerId] == null || playerBalances[playerId]! < amount) {
      return false;
    }
    
    // Allow multiple bets - don't remove previous bets
    // Just add new bet and deduct balance
    bets.add(Bet(side: side, amount: amount, playerId: playerId));
    playerBalances[playerId] = playerBalances[playerId]! - amount;
    
    return true;
  }

  // Reveal joker card
  void revealJoker() {
    if (deck.isEmpty) return;
    
    jokerCard = deck.removeAt(0);
    jokerCard!.isVisible = true;
    phase = GamePhase.dealing;
  }

  // Deal next card based on joker color rule
  PlayingCard? dealNextCard() {
    if (deck.isEmpty || jokerCard == null) return null;
    
    PlayingCard nextCard = deck.removeAt(0);
    nextCard.isVisible = true;
    
    // Determine which side to deal to
    BetSide dealToSide;
    
    if (totalCardsDealt == 0) {
      // First card goes to side based on joker color
      dealToSide = jokerCard!.isBlack ? BetSide.andar : BetSide.bahar;
    } else {
      // Alternate sides
      dealToSide = (andarCards.length <= baharCards.length) ? BetSide.andar : BetSide.bahar;
    }
    
    // Add card to appropriate side
    if (dealToSide == BetSide.andar) {
      andarCards.add(nextCard);
    } else {
      baharCards.add(nextCard);
    }
    
    totalCardsDealt++;
    
    // Check for winning condition
    if (nextCard.hasSameRank(jokerCard!)) {
      winningSide = dealToSide;
      phase = GamePhase.finished;
    }
    
    return nextCard;
  }

  // Calculate payouts
  Map<String, int> calculatePayouts() {
    Map<String, int> payouts = {};
    
    if (winningSide == null) return payouts;
    
    for (Bet bet in bets) {
      if (bet.side == winningSide) {
        // Winner payouts based on PRD
        int payout = bet.side == BetSide.andar 
            ? (bet.amount * 1.9).round()  // 0.9:1 payout
            : bet.amount * 2;             // 1:1 payout
            
        payouts[bet.playerId] = (payouts[bet.playerId] ?? 0) + payout;
      }
    }
    
    return payouts;
  }

  // Apply payouts to player balances
  void applyPayouts() {
    Map<String, int> payouts = calculatePayouts();
    
    for (String playerId in payouts.keys) {
      playerBalances[playerId] = (playerBalances[playerId] ?? 0) + payouts[playerId]!;
    }
  }

  // Get total bet amount for a side
  int getTotalBetForSide(BetSide side) {
    return bets
        .where((bet) => bet.side == side)
        .fold(0, (sum, bet) => sum + bet.amount);
  }

  // Get player's current bet (first bet for compatibility)
  Bet? getPlayerBet(String playerId) {
    try {
      return bets.firstWhere((bet) => bet.playerId == playerId);
    } catch (e) {
      return null;
    }
  }

  // Get all bets for a player
  List<Bet> getPlayerBets(String playerId) {
    return bets.where((bet) => bet.playerId == playerId).toList();
  }

  // Get total bet amount for a player
  int getPlayerTotalBetAmount(String playerId) {
    return bets
        .where((bet) => bet.playerId == playerId)
        .fold(0, (sum, bet) => sum + bet.amount);
  }

  // Clone game state for immutability
  GameState copyWith({
    GamePhase? phase,
    PlayingCard? jokerCard,
    List<PlayingCard>? andarCards,
    List<PlayingCard>? baharCards,
    List<PlayingCard>? deck,
    List<Bet>? bets,
    BetSide? winningSide,
    int? totalCardsDealt,
    bool? isMultiplayer,
    String? gameId,
    Map<String, int>? playerBalances,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      jokerCard: jokerCard ?? this.jokerCard,
      andarCards: andarCards ?? List.from(this.andarCards),
      baharCards: baharCards ?? List.from(this.baharCards),
      deck: deck ?? List.from(this.deck),
      bets: bets ?? List.from(this.bets),
      winningSide: winningSide ?? this.winningSide,
      totalCardsDealt: totalCardsDealt ?? this.totalCardsDealt,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      gameId: gameId ?? this.gameId,
      playerBalances: playerBalances ?? Map.from(this.playerBalances),
    );
  }
} 