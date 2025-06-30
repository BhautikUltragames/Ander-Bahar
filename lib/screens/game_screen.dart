import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../models/card.dart';
import '../widgets/card_widget.dart';
import '../widgets/betting_panel.dart';

class GameScreen extends StatefulWidget {
  final bool isAIGame;

  const GameScreen({Key? key, required this.isAIGame}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardSlideAnimation;
  
  // Dealer animation controllers
  late AnimationController _dealerAnimationController;
  bool _isThrowingCard = false;
  bool _throwToAndar = true; // Alternates between Andar and Bahar
  Widget? _flyingCard;
  int _prevAndarCount = 0;
  int _prevBaharCount = 0;
  bool _showFlyingCard = false;
  Alignment _cardTargetAlignment = Alignment(0, -0.8);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _cardSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));

    // Dealer animation setup
    _dealerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize the game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (widget.isAIGame) {
        gameProvider.startAIGame();
      } else {
        gameProvider.startMultiplayerGame();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardAnimationController.dispose();
    _dealerAnimationController.dispose();
    super.dispose();
  }

  // Dealer animation methods
  void _triggerDealAnimation(bool toAndar, PlayingCard dealtCard) {
    final cardWidget = CardWidget(
      card: dealtCard,
      width: 50,
      height: 75,
      showAnimation: false,
    );
    if (_isThrowingCard) return;
    setState(() {
      _isThrowingCard = true;
      _throwToAndar = toAndar;
      _flyingCard = cardWidget;
      _cardTargetAlignment = Alignment(0, -0.8);
      _showFlyingCard = true;
    });
    // animate dealer hand
    _dealerAnimationController.forward().then((_) => _dealerAnimationController.reverse());
    // flight start
    Future.delayed(const Duration(milliseconds: 20), () {
      if (!mounted) return;
      setState(() {
        _cardTargetAlignment = toAndar ? Alignment(-0.5, 0.25) : Alignment(0.5, 0.25);
      });
    });
    // clear after flight duration (350ms)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _showFlyingCard = false;
        _isThrowingCard = false;
        _flyingCard = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Schedule card dealing checks after current frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _listenForCardDealing(gameProvider);
        });
        return Scaffold(
          body: Stack(
            children: [
              // Background
              _buildBackground(),
              
              // Main Game Layout
              Column(
                children: [
                  // Top Bar
                  _buildTopBar(gameProvider),
                  
                  // Dealer Section
                  _buildDealerSection(gameProvider),
                  
                  // Game Table
                  Expanded(
                    child: _buildGameTable(gameProvider),
                  ),
                  
                  // Betting Panel
                  _buildBettingPanel(gameProvider),
                ],
              ),
              
              // Flying card animation using AnimatedAlign
              if (_showFlyingCard && _flyingCard != null)
                AnimatedAlign(
                  alignment: _cardTargetAlignment,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutQuart,
                  child: Transform.rotate(
                    angle: _throwToAndar ? -0.3 : 0.3,
                    child: _flyingCard,
                  ),
                ),
              
              // Confetti overlay
              Align(
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
                    Colors.purple
                  ],
                ),
              ),
              
              // Winner overlay
              if (gameProvider.gameState.phase == GamePhase.showResult)
                _buildWinnerOverlay(gameProvider),
            ],
          ),
        );
      },
    );
  }

  void _listenForCardDealing(GameProvider gameProvider) {
    final gameState = gameProvider.gameState;
    if (gameState.phase == GamePhase.dealing) {
      final currAndar = gameState.andarCards.length;
      final currBahar = gameState.baharCards.length;
      // If a new card added to Andar
      if (currAndar > _prevAndarCount) {
        final card = gameState.andarCards.last;
        _triggerDealAnimation(true, card);
      }
      // Else if new card added to Bahar
      else if (currBahar > _prevBaharCount) {
        final card = gameState.baharCards.last;
        _triggerDealAnimation(false, card);
      }
      _prevAndarCount = currAndar;
      _prevBaharCount = currBahar;
    } else {
      // reset counts when not dealing
      _prevAndarCount = 0;
      _prevBaharCount = 0;
    }
  }

  Widget _buildDealerSection(GameProvider gameProvider) {
    final gameState = gameProvider.gameState;
    final isDealing = gameState.phase == GamePhase.dealing;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dealer avatar and animation
            AnimatedBuilder(
              animation: _dealerAnimationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dealer body
                    Transform.translate(
                      offset: Offset(
                        _dealerAnimationController.value * (_throwToAndar ? -15 : 15),
                        -_dealerAnimationController.value * 5,
                      ),
                      child: Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade700,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Dealer face
                            Container(
                              width: 40,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.brown.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  '🎩',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Dealer body
                            Container(
                              width: 50,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Dealer hands with card deck
                    Positioned(
                      left: 20 + (_dealerAnimationController.value * (_throwToAndar ? -25 : 25)),
                      top: 25 - (_dealerAnimationController.value * 8),
                      child: Transform.rotate(
                        angle: _dealerAnimationController.value * (_throwToAndar ? -0.3 : 0.3),
                        child: Container(
                          width: 20,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🂠',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Throwing hand animation
                    if (_isThrowingCard)
                      Positioned(
                        right: 20 - (_dealerAnimationController.value * (_throwToAndar ? 25 : -25)),
                        top: 25 - (_dealerAnimationController.value * 12),
                        child: Transform.rotate(
                          angle: _dealerAnimationController.value * (_throwToAndar ? 0.5 : -0.5),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            // Dealer label with status
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEALER',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isDealing)
                  Text(
                    'Dealing...',
                    style: TextStyle(
                      color: Colors.yellow.withOpacity(0.8),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Colors.green.shade700,
            Colors.green.shade800,
            Colors.green.shade900,
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            
            // Title
            Expanded(
              child: Center(
                child: Text(
                  widget.isAIGame ? 'Andar Bahar - vs AI' : 'Andar Bahar - Multiplayer',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Settings button
            IconButton(
              onPressed: () {
                // Show settings dialog
                _showSettingsDialog(gameProvider);
              },
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTable(GameProvider gameProvider) {
    final gameState = gameProvider.gameState;
    // In AI mode, show both human and AI bets
    final Bet? humanBet = gameProvider.getCurrentPlayerBet();
    final Bet? aiBet = gameState.getPlayerBet('ai_1');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game stats
          _buildGameStats(gameProvider),
          const SizedBox(height: 20),
          if (gameProvider.isAIGame) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'You',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      humanBet != null ? '${humanBet.side == BetSide.andar ? 'Andar' : 'Bahar'} - ₹${humanBet.amount}' : 'No Bet',
                      style: TextStyle(color: humanBet?.side == BetSide.andar ? Colors.blue : Colors.red),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'AI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      aiBet != null ? '${aiBet.side == BetSide.andar ? 'Andar' : 'Bahar'} - ₹${aiBet.amount}' : 'No Bet',
                      style: TextStyle(color: aiBet?.side == BetSide.andar ? Colors.blue : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // Card table
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Andar pile
                Expanded(
                  child: _buildCardPile(
                    'ANDAR',
                    gameState.andarCards,
                    Colors.blue.shade700,
                    gameState.winningSide == BetSide.andar,
                    gameState.getTotalBetForSide(BetSide.andar),
                  ),
                ),
                
                // Center - Joker card
                SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'JOKER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CardWidget(
                        card: gameState.jokerCard,
                        width: 80,
                        height: 120,
                        isJoker: true,
                        showAnimation: gameState.jokerCard?.isVisible ?? false,
                      ),
                      if (gameState.jokerCard != null && gameState.jokerCard!.isVisible)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Starting: ${gameState.jokerCard!.isBlack ? 'ANDAR' : 'BAHAR'}',
                            style: TextStyle(
                              color: gameState.jokerCard!.isBlack 
                                  ? Colors.blue.shade300 
                                  : Colors.red.shade300,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Bahar pile
                Expanded(
                  child: _buildCardPile(
                    'BAHAR',
                    gameState.baharCards,
                    Colors.red.shade700,
                    gameState.winningSide == BetSide.bahar,
                    gameState.getTotalBetForSide(BetSide.bahar),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats(GameProvider gameProvider) {
    final stats = gameProvider.getGameStats();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Cards Dealt', '${stats['totalCardsDealt']}'),
          _buildStatItem('Andar Bets', '₹${stats['andarBetTotal']}'),
          _buildStatItem('Bahar Bets', '₹${stats['baharBetTotal']}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCardPile(String title, List cards, Color titleColor, bool isWinner, int totalBets) {
    return Column(
      children: [
        // Title and bet total
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: titleColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWinner ? Colors.yellow : titleColor,
              width: isWinner ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isWinner ? Colors.yellow : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalBets > 0)
                Text(
                  '₹$totalBets',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Cards
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: cards.map<Widget>((card) {
                return CardWidget(
                  card: card,
                  width: 40,
                  height: 60,
                  showAnimation: true,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBettingPanel(GameProvider gameProvider) {
    return BettingPanel(
      playerBalance: gameProvider.getPlayerBalance(gameProvider.currentPlayerId),
      gamePhase: gameProvider.gameState.phase,
      currentBets: gameProvider.getCurrentPlayerBets(),
      totalBetAmount: gameProvider.getCurrentPlayerTotalBet(),
      onBetPlaced: (side, amount) {
        gameProvider.placeBet(side, amount);
      },
      onRebet: () {
        gameProvider.rebet();
      },
    );
  }

  Widget _buildWinnerOverlay(GameProvider gameProvider) {
    final winningSide = gameProvider.gameState.winningSide;
    final winnerText = winningSide == BetSide.andar ? 'ANDAR WINS!' : 'BAHAR WINS!';
    final winnerColor = winningSide == BetSide.andar ? Colors.blue : Colors.red;
    
    // Show confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
    
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              color: winnerColor,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              winnerText,
              style: TextStyle(
                color: winnerColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (gameProvider.getCurrentPlayerBet()?.side == winningSide)
              const Text(
                'You Win!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Force Start Dealing'),
              subtitle: const Text('Skip betting timer'),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  gameProvider.forceStartDealing();
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Add Test Chips'),
              subtitle: const Text('Add 1000 chips'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  gameProvider.addChips(gameProvider.currentPlayerId, 1000);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 