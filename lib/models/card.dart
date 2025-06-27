enum Suit { hearts, diamonds, clubs, spades }

enum Rank { 
  ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king 
}

class PlayingCard {
  final Suit suit;
  final Rank rank;
  bool isVisible;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.isVisible = false,
  });

  // Get color based on suit
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;
  bool get isBlack => suit == Suit.clubs || suit == Suit.spades;

  // Get suit symbol
  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  // Get rank display
  String get rankDisplay {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
    }
  }

  // Get card display
  String get cardDisplay => '$rankDisplay$suitSymbol';

  // Check if two cards have same rank
  bool hasSameRank(PlayingCard other) {
    return rank == other.rank;
  }

  @override
  String toString() => cardDisplay;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayingCard && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
} 