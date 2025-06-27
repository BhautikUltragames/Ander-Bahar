import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
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
                  
                  // Game Table
                  Expanded(
                    child: _buildGameTable(gameProvider),
                  ),
                  
                  // Betting Panel
                  _buildBettingPanel(gameProvider),
                ],
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
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game stats
          _buildGameStats(gameProvider),
          const SizedBox(height: 20),
          
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: titleColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWinner ? Colors.yellow : titleColor,
              width: isWinner ? 3 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isWinner ? Colors.yellow : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (totalBets > 0)
                Text(
                  'Total Bets: ₹$totalBets',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cards
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: cards.map<Widget>((card) {
                return CardWidget(
                  card: card,
                  width: 50,
                  height: 75,
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
      currentBet: gameProvider.getCurrentPlayerBet(),
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