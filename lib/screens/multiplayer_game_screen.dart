import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../services/websocket_service.dart';
import '../widgets/card_widget.dart';
import '../widgets/multiplayer_betting_panel.dart';
import '../widgets/animated_card_dealer.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardSlideAnimation;
  late AnimationController _dealerAnimationController;
  bool _isThrowingCard = false;
  bool _throwToAndar = true;
  Widget? _flyingCard;
  int _prevAndarCount = 0;
  int _prevBaharCount = 0;
  bool _showFlyingCard = false;
  Alignment _cardTargetAlignment = Alignment(0, -0.8);
  int _bettingTimeRemaining = 10;
  int _previousBalance = 0;
  String? _lastPhase;

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
    _dealerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Set up WebSocket callbacks
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.onGameStateUpdate = (gameState, players) {
      if (mounted) {
        setState(() {
          final phase = gameState['phase'] as String?;
          
          // Show confetti when round finishes
          if (phase == 'finished') {
            _confettiController.play();
          }
          
          // Schedule dealer animation on state update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _listenForCardDealing(wsService);
          });
        });
      }
    };
    

  }

  void _startBettingTimer() {
    _bettingTimeRemaining = 10;
    _updateBettingTimer();
  }

  void _updateBettingTimer() {
    if (_bettingTimeRemaining > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _bettingTimeRemaining--;
          });
          _updateBettingTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _dealerAnimationController.dispose();
    _confettiController.dispose();
    _cardAnimationController.dispose();
    
    // Disconnect when screen is disposed
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.disconnect();
    
    super.dispose();
  }

  void _listenForCardDealing(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    if (gameState != null) {
      // Simply update previous counts for instantaneous display
      _prevAndarCount = (gameState['andarCards'] as List).length;
      _prevBaharCount = (gameState['baharCards'] as List).length;
    } else {
      _prevAndarCount = 0;
      _prevBaharCount = 0;
    }
  }

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
    _dealerAnimationController.forward().then((_) => _dealerAnimationController.reverse());
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _cardTargetAlignment = toAndar ? Alignment(-0.5, 0.25) : Alignment(0.5, 0.25);
      });
    });
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
    return Consumer<WebSocketService>(
      builder: (context, wsService, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background
              _buildBackground(),
              
              // Main Layout with Player Panel
              Row(
                children: [
                  // Left Player Panel
                  _buildPlayerPanel(wsService),
                  
                  // Main Game Area
                  Expanded(
                    child: Column(
                      children: [
                        // Top Bar
                        _buildTopBar(wsService),
                        
                        // Dealer section removed
                        
                        // Game Table
                        Expanded(
                          child: _buildGameTable(wsService),
                        ),
                        
                        // Multiplayer Betting Panel
                        _buildMultiplayerBettingPanel(wsService),
                      ],
                    ),
                  ),
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
              
              // Winner overlay - show when round finished (game continues even if players disconnect)
              if (wsService.serverGameState?['phase'] == 'finished')
                _buildWinnerOverlay(wsService),
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

  Widget _buildTopBar(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    final roundNumber = gameState?['roundNumber'] ?? 0;
    final phase = gameState?['phase'] ?? 'betting';
    final bettingTimeLeft = wsService.getBettingTimeLeft();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () {
                _showLeaveConfirmation();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            
            // Spacer to push timer to the right
            const Spacer(),
            
            // Betting timer (only show during betting phase)
            if (phase == 'betting')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bettingTimeLeft <= 3 ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${bettingTimeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTable(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Column(
        children: [
          // Game stats and timer
          _buildGameStats(wsService),
          const SizedBox(height: 20),
          
          // Card table
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Andar pile
                Expanded(
                  child: AnimatedCardDealer(
                    title: 'ANDAR',
                    cards: _getCardsFromGameState(gameState?['andarCards']),
                    titleColor: Colors.blue.shade700,
                    isWinner: gameState?['winningSide'] == 'andar',
                    totalBets: _getTotalBetForSide(wsService, 'andar'),
                    gamePhase: gameState?['phase'] ?? 'betting',
                    gameState: gameState,
                    wsService: wsService,
                  ),
                ),
                
                // Center Joker display
                Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'JOKER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (gameState?['jokerCard'] != null)
                        CardWidget(
                          card: _convertToPlayingCard(gameState!['jokerCard']),
                          width: 100,
                          height: 150,
                          showAnimation: false,
                          isJoker: true,
                        )
                      else
                        Container(
                          width: 100,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Icon(Icons.help_outline, size: 30),
                        ),
                    ],
                  ),
                ),
                
                // Bahar pile
                Expanded(
                  child: AnimatedCardDealer(
                    title: 'BAHAR',
                    cards: _getCardsFromGameState(gameState?['baharCards']),
                    titleColor: Colors.yellow.shade700,
                    isWinner: gameState?['winningSide'] == 'bahar',
                    totalBets: _getTotalBetForSide(wsService, 'bahar'),
                    gamePhase: gameState?['phase'] ?? 'betting',
                    gameState: gameState,
                    wsService: wsService,
                  ),
                ),
              ],
            ),
          ),
          

        ],
      ),
    );
  }

  Widget _buildGameStats(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    final phase = gameState?['phase'] ?? 'betting';
    final bettingTimeLeft = wsService.getBettingTimeLeft();
    final roundNumber = gameState?['roundNumber'] ?? 0;
    
    String phaseText = 'Waiting...';
    Color phaseColor = Colors.grey;
    
    switch (phase) {
      case 'betting':
        phaseText = 'Betting Time: ${bettingTimeLeft}s';
        phaseColor = bettingTimeLeft <= 3 ? Colors.red : Colors.green;
        break;
      case 'dealing':
        phaseText = 'Cards Being Dealt...';
        phaseColor = Colors.blue;
        break;
      case 'matchFound':
        final winningSide = gameState?['winningSide'];
        phaseText = winningSide != null ? 'MATCH FOUND! ${winningSide.toUpperCase()} WINS!' : 'Match Found!';
        phaseColor = Colors.yellow;
        break;
      case 'finished':
        phaseText = 'Round Finished';
        phaseColor = Colors.purple;
        break;
      case 'showResult':
        final winningSide = gameState?['winningSide'];
        phaseText = winningSide != null ? '${winningSide.toUpperCase()} WINS!' : 'Round Complete';
        phaseColor = Colors.orange;
        break;
      default:
        phaseText = 'Round $roundNumber - Join anytime!';
        phaseColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseColor),
      ),
      child: Text(
        phaseText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }





  Widget _buildDealerPosition(String gamePhase) {
    final isDealing = gamePhase == 'dealing' || gamePhase == 'matchFound';
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDealing 
            ? Colors.green.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDealing ? Colors.green : Colors.grey,
          width: 2,
        ),
        boxShadow: isDealing ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dealer icon
          Icon(
            Icons.person,
            color: isDealing ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          
          // Dealer label
          Text(
            'DEALER',
            style: TextStyle(
              color: isDealing ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Card deck indicator
          const SizedBox(height: 6),
          Stack(
            children: [
              // Back cards to show deck thickness
              Positioned(
                top: -2,
                left: -1,
                child: Container(
                  width: 35,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade700,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Top card
              Container(
                width: 35,
                height: 25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade800, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.casino_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          
          // Status text
          const SizedBox(height: 4),
          Text(
            isDealing ? 'DEALING' : 'READY',
            style: TextStyle(
              color: isDealing ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplayerBettingPanel(WebSocketService wsService) {
    return MultiplayerBettingPanel(
      wsService: wsService,
      bettingTimeRemaining: wsService.getBettingTimeLeft(),
    );
  }

  Widget _buildWinnerOverlay(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    final winningSide = gameState?['winningSide'] as String?;
    final winnerText = winningSide == 'andar' ? 'ANDAR WINS!' : 'BAHAR WINS!';
    final winnerColor = winningSide == 'andar' ? Colors.blue : Colors.red;

    // Determine current player info
    final currentPlayer = wsService.getCurrentPlayer();
    final playerName = currentPlayer?['name'] ?? 'You';
    final currentBalance = wsService.getPlayerBalance();
    
    // Calculate detailed betting information
    final bets = gameState?['bets'] as List<dynamic>? ?? [];
    final myBets = bets.where((b) => b['playerId'] == wsService.playerId).toList();
    
    // Calculate separate bets for Andar and Bahar
    int andarBetAmount = 0;
    int baharBetAmount = 0;
    int totalBetAmount = 0;
    int winningBetAmount = 0;
    int losingBetAmount = 0;
    int netGain = 0;
    
    for (final bet in myBets) {
      final side = bet['side'] as String;
      final amount = bet['amount'] as int;
      totalBetAmount += amount;
      
      if (side == 'andar') {
        andarBetAmount += amount;
      } else {
        baharBetAmount += amount;
      }
      
      if (side == winningSide) {
        winningBetAmount += amount;
        // Simple 2x payout: bet ₹250 → get ₹500
        final totalPayout = amount * 2;
        netGain += totalPayout - amount; // Net gain = payout - original bet
      } else {
        losingBetAmount += amount;
      }
    }
    
    // Calculate total payout: 2x the winning bet amount
    final totalPayout = winningBetAmount * 2;
    
    final didWin = winningBetAmount > 0;
    final mainBetSide = andarBetAmount > baharBetAmount ? 'ANDAR' : 
                       baharBetAmount > andarBetAmount ? 'BAHAR' : 
                                               myBets.isNotEmpty ? (myBets.first['side'] as String).toUpperCase() : 'N/A';

    return _buildGameResultDialog(playerName, didWin, andarBetAmount, baharBetAmount, totalBetAmount, netGain, losingBetAmount, totalPayout, currentBalance);
  }

  Widget _buildGameResultDialog(String playerName, bool didWin, int andarBetAmount, int baharBetAmount, int totalBetAmount, int netGain, int losingBetAmount, int totalPayout, int currentBalance) {
    final winnerColor = didWin == true ? Colors.green : Colors.red;
    final winnerText = didWin == true ? '🎉 YOU WIN! 🎉' : '😔 YOU LOSE';

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 120, vertical: 80),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.black,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Centered Header with Result
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: winnerColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: winnerColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        didWin ? Icons.celebration : Icons.sentiment_dissatisfied,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      didWin == true ? '🎉 YOU WIN! 🎉' : '😔 YOU LOSE',
                      style: TextStyle(
                        color: didWin == true ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      winnerText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: const Offset(1, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Compact Betting & Results Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      // Betting Summary Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(didWin ? Icons.trending_up : Icons.trending_down, 
                               color: didWin ? Colors.greenAccent : Colors.redAccent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Round Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: const Offset(1, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Total Bet Amount
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade600, Colors.orange.shade800],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'My Total Bet: ₹$totalBetAmount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Bets in compact rows
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.6)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_back, color: Colors.lightBlueAccent, size: 16),
                                  const SizedBox(width: 6),
                                  const Text('ANDAR:', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('₹$andarBetAmount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.6)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_forward, color: Colors.redAccent, size: 16),
                                  const SizedBox(width: 6),
                                  const Text('BAHAR:', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('₹$baharBetAmount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Result Summary
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: didWin 
                              ? [Colors.green.shade600, Colors.green.shade800]
                              : [Colors.red.shade600, Colors.red.shade800],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: didWin ? Colors.green.shade400 : Colors.red.shade400,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(didWin ? Icons.add_circle : Icons.remove_circle, 
                                 color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                                                        Text(
                              didWin ? 'Total Won: ₹$totalPayout' : 'Lost: -₹$losingBetAmount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Balance Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Balance:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₹$currentBalance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Continue Button (moved down)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      elevation: 4,
                      shadowColor: Colors.green.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerPanel(WebSocketService wsService) {
    final players = wsService.players;
    final currentPlayerId = wsService.playerId;
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          // Panel Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Players (${players.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Players List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isCurrentPlayer = player['id'] == currentPlayerId;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentPlayer 
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrentPlayer
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player name and balance
                      Row(
                        children: [
                          Icon(
                            isCurrentPlayer ? Icons.person : Icons.person_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              player['name'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Balance
                      Text(
                        'Balance: ₹${player['balance'] ?? 0}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Round bets
                      Row(
                        children: [
                          // Andar bet
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Andar: ₹${player['roundBets']?['andar'] ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          
                          // Bahar bet
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Bahar: ₹${player['roundBets']?['bahar'] ?? 0}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game'),
        content: const Text('Are you sure you want to leave the multiplayer game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Properly disconnect from WebSocket server
              final wsService = Provider.of<WebSocketService>(context, listen: false);
              wsService.disconnect();
              
              Navigator.pop(context); // Go back to main menu
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<PlayingCard> _getCardsFromGameState(dynamic cards) {
    if (cards == null) return [];
    
    return (cards as List).map((cardData) => _convertToPlayingCard(cardData)).toList();
  }

  PlayingCard _convertToPlayingCard(Map<String, dynamic> cardData) {
    return PlayingCard(
      suit: _convertSuit(cardData['suit']),
      rank: _convertRank(cardData['rank']),
      isVisible: cardData['isVisible'] ?? true,
    );
  }

  Suit _convertSuit(String suitStr) {
    switch (suitStr) {
      case 'hearts':
        return Suit.hearts;
      case 'diamonds':
        return Suit.diamonds;
      case 'clubs':
        return Suit.clubs;
      case 'spades':
        return Suit.spades;
      default:
        return Suit.hearts;
    }
  }

  Rank _convertRank(String rankStr) {
    switch (rankStr) {
      case 'A':
        return Rank.ace;
      case '2':
        return Rank.two;
      case '3':
        return Rank.three;
      case '4':
        return Rank.four;
      case '5':
        return Rank.five;
      case '6':
        return Rank.six;
      case '7':
        return Rank.seven;
      case '8':
        return Rank.eight;
      case '9':
        return Rank.nine;
      case '10':
        return Rank.ten;
      case 'J':
        return Rank.jack;
      case 'Q':
        return Rank.queen;
      case 'K':
        return Rank.king;
      default:
        return Rank.ace;
    }
  }

  int _getTotalBetForSide(WebSocketService wsService, String side) {
    final gameState = wsService.serverGameState;
    if (gameState == null || gameState['bets'] == null) return 0;
    
    int total = 0;
    for (final bet in gameState['bets']) {
      if (bet['side'] == side) {
        total += bet['amount'] as int;
      }
    }
    return total;
  }

  int _getPlayerBetCount(WebSocketService wsService, String side) {
    final gameState = wsService.serverGameState;
    if (gameState == null || gameState['bets'] == null) return 0;
    
    Set<String> uniquePlayers = {};
    for (final bet in gameState['bets']) {
      if (bet['side'] == side) {
        uniquePlayers.add(bet['playerId'] as String);
      }
    }
    return uniquePlayers.length;
  }
} 