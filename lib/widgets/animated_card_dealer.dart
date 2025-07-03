import 'package:flutter/material.dart';
import '../models/card.dart';
import 'card_widget.dart';

class AnimatedCardDealer extends StatefulWidget {
  final List<PlayingCard> cards;
  final String title;
  final Color titleColor;
  final bool isWinner;
  final int totalBets;
  final String gamePhase;
  final Map<String, dynamic>? gameState;
  final dynamic wsService;

  const AnimatedCardDealer({
    Key? key,
    required this.cards,
    required this.title,
    required this.titleColor,
    required this.isWinner,
    required this.totalBets,
    required this.gamePhase,
    this.gameState,
    this.wsService,
  }) : super(key: key);

  @override
  State<AnimatedCardDealer> createState() => _AnimatedCardDealerState();
}

class _AnimatedCardDealerState extends State<AnimatedCardDealer> with TickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightScale;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _fadingIndex = -1;

  @override
  void initState() {
    super.initState();
    // Highlight controller for winning card pulsing
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _highlightScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));
    // Fade controller for new card reveal
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(AnimatedCardDealer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start or stop highlight pulsing when winner status changes
    if (widget.isWinner && !oldWidget.isWinner) {
      _highlightController.repeat(reverse: true);
    } else if (!widget.isWinner && oldWidget.isWinner) {
      _highlightController.stop();
      _highlightController.reset();
    }
    // Fade in newly added card at end of list
    if (widget.cards.length > oldWidget.cards.length) {
      _fadingIndex = widget.cards.length - 1;
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPlayerBetDisplay(),
        _buildTitleSection(),
        const SizedBox(height: 8),
        _buildCardArea(),
      ],
    );
  }

  Widget _buildPlayerBetDisplay() {
    final playerBetCount = _getPlayerBetCount();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: widget.titleColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        'Total Player\'s Bet:- $playerBetCount',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.titleColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isWinner ? Colors.yellow : widget.titleColor,
          width: widget.isWinner ? 3 : 1,
        ),
        boxShadow: widget.isWinner ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: widget.isWinner ? Colors.yellow : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.totalBets > 0)
            Text(
              'Total Bets: ₹${widget.totalBets}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardArea() {
    // Display cards directly without expanding to fill vertical space
    return _buildCards();
  }

  Widget _buildCards() {
    if (widget.cards.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'No cards dealt yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Calculate dynamic spacing based on available width
    return LayoutBuilder(
      builder: (context, constraints) {
        final sectionCards = widget.cards;
        final count = sectionCards.length;
        const double cardWidth = 50.0;
        // Compute spacing based on available width, clamped to [0, 5]
        final double spacing = (count > 1)
            ? ((constraints.maxWidth - cardWidth * count) / (count - 1))
                .clamp(0.0, 5.0) as double
            : 5.0;
        // Build card widgets with dynamic spacing
        final cardWidgets = sectionCards.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final card = entry.value;
          final globalIndex = _getGlobalIndex(card);
          final isWinningCard = _isWinningCard(card, globalIndex);
          Widget baseChild = CardWidget(
            card: card,
            width: cardWidth,
            height: cardWidth * 1.5,
            showAnimation: false,
            isWinningCard: isWinningCard,
          );
          // Apply winner pulse and glow
          if (isWinningCard && widget.isWinner) {
            baseChild = Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.6),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ScaleTransition(
                scale: _highlightScale,
                child: baseChild,
              ),
            );
          }
          // Fade newly added card
          if (index == _fadingIndex) {
            baseChild = FadeTransition(opacity: _fadeAnimation, child: baseChild);
          }
          return Container(
            margin: EdgeInsets.only(right: spacing),
            child: baseChild,
          );
        }).toList();

        // Always render in a Row without scrolling; spacing handles fit
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: cardWidgets,
        );
      },
    );
  }

  int _getGlobalIndex(PlayingCard card) {
    for (int i = 0; i < widget.cards.length; i++) {
      if (widget.cards[i] == card) {
        return i;
      }
    }
    return 0;
  }

  bool _isWinningCard(PlayingCard card, int index) {
    if (widget.gameState == null) return false;
    
    final winningSide = widget.gameState!['winningSide'] as String?;
    final jokerCard = widget.gameState!['jokerCard'];
    final phase = widget.gameState!['phase'] as String?;
    
    if (winningSide == null || jokerCard == null) return false;
    if (phase != 'matchFound' && phase != 'finished' && phase != 'showResult') {
      return false;
    }
    
    final isLastCard = index == widget.cards.length - 1;
    final jokerRank = _getCardRank(jokerCard);
    final matchesJoker = card.rankDisplay == jokerRank;
    final isOnWinningSide = (widget.title == 'ANDAR' && winningSide == 'andar') || 
                           (widget.title == 'BAHAR' && winningSide == 'bahar');
    
    return isLastCard && matchesJoker && isOnWinningSide;
  }

  String _getCardRank(dynamic jokerCard) {
    if (jokerCard is Map) {
      return jokerCard['rank']?.toString() ?? '';
    }
    return '';
  }

  int _getPlayerBetCount() {
    if (widget.wsService == null || widget.gameState == null) return 0;
    
    final bets = widget.gameState!['bets'] as List<dynamic>? ?? [];
    final side = widget.title.toLowerCase();
    
    Set<String> uniquePlayers = {};
    for (final bet in bets) {
      if (bet['side'] == side) {
        uniquePlayers.add(bet['playerId'] as String);
      }
    }
    return uniquePlayers.length;
  }
} 