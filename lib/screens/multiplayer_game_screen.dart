import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../services/websocket_service.dart';
import '../widgets/card_widget.dart';
import '../widgets/multiplayer_betting_panel.dart';
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
      setState(() {
        final phase = gameState['phase'] as String?;
        // Capture balance when betting phase starts
        if (phase == 'betting' && _lastPhase != 'betting') {
          _previousBalance = wsService.getPlayerBalance();
          _startBettingTimer();
        }
        _lastPhase = phase;
        // Show confetti on win
        if (phase == 'showResult') {
          _confettiController.play();
        }
        // Schedule dealer animation on state update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _listenForCardDealing(wsService);
        });
      });
    };
    
    wsService.onRoomLeft = () {
      Navigator.pop(context);
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
    
    // Leave room when screen is disposed
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.leaveRoom();
    
    super.dispose();
  }

  void _listenForCardDealing(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    if (gameState != null) {
      final andarCards = (gameState['andarCards'] as List).length;
      final baharCards = (gameState['baharCards'] as List).length;
      
      if (andarCards > _prevAndarCount) {
        final card = _convertToPlayingCard(gameState['andarCards'].last);
        _triggerDealAnimation(true, card);
      } else if (baharCards > _prevBaharCount) {
        final card = _convertToPlayingCard(gameState['baharCards'].last);
        _triggerDealAnimation(false, card);
      }
      _prevAndarCount = andarCards;
      _prevBaharCount = baharCards;
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
              
              // Main Game Layout
              Column(
                children: [
                  // Top Bar
                  _buildTopBar(wsService),
                  
                  // Dealer section
                  _buildDealerSection(wsService),
                  
                  // Game Table
                  Expanded(
                    child: _buildGameTable(wsService),
                  ),
                  
                  // Multiplayer Betting Panel
                  _buildMultiplayerBettingPanel(wsService),
                ],
              ),
              
              // Flying card animation
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
              
              // Winner overlay - show during showResult phase (game continues even if players disconnect)
              if (wsService.getGamePhase() == GamePhase.showResult)
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
              onPressed: () {
                _showLeaveConfirmation(wsService);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            
            // Room info
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Room: ${wsService.roomId ?? "Unknown"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${wsService.players.length} players connected',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Host controls
            if (wsService.isHost() && wsService.getGamePhase() == GamePhase.waiting)
              ElevatedButton(
                onPressed: () => wsService.startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('START GAME'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTable(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    
    return Padding(
      padding: const EdgeInsets.all(16),
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
                  child: _buildCardPile(
                    'ANDAR',
                    _getCardsFromGameState(gameState?['andarCards']),
                    Colors.blue.shade700,
                    gameState?['winningSide'] == 'andar',
                    _getTotalBetForSide(wsService, 'andar'),
                  ),
                ),
                
                // Joker card in center
                Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      if (gameState?['jokerCard'] != null)
                        CardWidget(
                          card: _convertToPlayingCard(gameState!['jokerCard']),
                          width: 70,
                          height: 100,
                          showAnimation: true,
                        )
                      else
                        Container(
                          width: 70,
                          height: 100,
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
                  child: _buildCardPile(
                    'BAHAR',
                    _getCardsFromGameState(gameState?['baharCards']),
                    Colors.red.shade700,
                    gameState?['winningSide'] == 'bahar',
                    _getTotalBetForSide(wsService, 'bahar'),
                  ),
                ),
              ],
            ),
          ),
          
          // Players list
          _buildPlayersSection(wsService),
        ],
      ),
    );
  }

  Widget _buildGameStats(WebSocketService wsService) {
    final gameState = wsService.serverGameState;
    final phase = wsService.getGamePhase();
    
    String phaseText = 'Waiting...';
    Color phaseColor = Colors.grey;
    
    switch (phase) {
      case GamePhase.waiting:
        final connectedPlayerCount = wsService.getConnectedPlayerCount();
        if (connectedPlayerCount < 2) {
          phaseText = 'Waiting for more players to join (${connectedPlayerCount}/2)';
        } else {
          phaseText = wsService.isHost() ? 'Press START GAME' : 'Waiting for host';
        }
        phaseColor = Colors.orange;
        break;
      case GamePhase.betting:
        phaseText = 'Betting Time: ${_bettingTimeRemaining}s';
        phaseColor = Colors.green;
        break;
      case GamePhase.readyToPlay:
        phaseText = 'Starting...';
        phaseColor = Colors.yellow;
        break;
      case GamePhase.dealing:
        phaseText = 'Cards Being Dealt...';
        phaseColor = Colors.blue;
        break;
      case GamePhase.finished:
        phaseText = 'Round Finished';
        phaseColor = Colors.purple;
        break;
      case GamePhase.showResult:
        phaseText = 'Showing Results';
        phaseColor = Colors.orange;
        break;
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

  Widget _buildCardPile(String title, List<PlayingCard> cards, Color titleColor, bool isWinner, int totalBets) {
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

  Widget _buildPlayersSection(WebSocketService wsService) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wsService.players.length,
        itemBuilder: (context, index) {
          final player = wsService.players[index];
          final isCurrentPlayer = player['id'] == wsService.playerId;
          final currentBet = player['currentBet'];
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentPlayer ? Colors.blue.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentPlayer ? Colors.blue : Colors.white30,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: isCurrentPlayer ? Colors.blue : Colors.white,
                      size: 16,
                    ),
                    if (player['isHost'] == true)
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                    Expanded(
                      child: Text(
                        player['name'] ?? 'Unknown',
                        style: TextStyle(
                          color: isCurrentPlayer ? Colors.blue : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${player['balance'] ?? 0}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                if (currentBet != null)
                  Text(
                    '${currentBet['side'].toUpperCase()}: ₹${currentBet['amount']}',
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMultiplayerBettingPanel(WebSocketService wsService) {
    return MultiplayerBettingPanel(
      wsService: wsService,
      bettingTimeRemaining: _bettingTimeRemaining,
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
    // Find this round's bet
    final bets = gameState?['bets'] as List<dynamic>? ?? [];
    final myBetEntry = bets.firstWhere(
        (b) => b['playerId'] == wsService.playerId,
        orElse: () => null);
    final mySide = myBetEntry != null ? (myBetEntry['side'] as String).toUpperCase() : 'N/A';
    final myBet = myBetEntry != null ? (myBetEntry['amount'] as int) : 0;
    // Compute net earned (could be negative)
    final netEarned = currentBalance - _previousBalance;
    final didWin = winningSide == myBetEntry?['side'];

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.celebration, size: 48, color: winnerColor),
                const SizedBox(height: 16),
                // Show result for current player first (main message)
                Text(
                  didWin == true ? 'You Win!' : 'You Lose',
                  style: TextStyle(
                    color: didWin == true ? Colors.green : Colors.red,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  winnerText,
                  style: TextStyle(
                    color: winnerColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: winnerColor.withOpacity(0.5)),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Name'),
                  subtitle: Text(playerName),
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Choice'),
                  subtitle: Text(mySide),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Bet Amount'),
                  subtitle: Text('₹$myBet'),
                ),
                ListTile(
                  leading: Icon(
                    didWin == true ? Icons.thumb_up : Icons.thumb_down,
                    color: didWin == true ? Colors.green : Colors.red,
                  ),
                  title: const Text('Result'),
                  subtitle: Text(didWin == true ? 'Won' : 'Lost'),
                ),
                ListTile(
                  leading: const Icon(Icons.monetization_on),
                  title: Text(didWin == true ? 'You Earned' : 'You Lost'),
                  subtitle: Text('₹${didWin == true ? netEarned : myBet}'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: winnerColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDealerSection(WebSocketService wsService) {
    final phase = wsService.getGamePhase();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _dealerAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _dealerAnimationController.value * (_throwToAndar ? -15 : 15),
                -_dealerAnimationController.value * 10,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.brown.shade700,
                child: Text('🎩', style: const TextStyle(fontSize: 24)),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'DEALER',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        if (phase == GamePhase.dealing)
          Text('Dealing...', style: TextStyle(color: Colors.yellow.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  void _showLeaveConfirmation(WebSocketService wsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room'),
        content: const Text('Are you sure you want to leave the room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              wsService.leaveRoom();
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

  bool _didCurrentPlayerWin(WebSocketService wsService) {
    final currentBet = wsService.getCurrentBet();
    final gameState = wsService.serverGameState;
    
    if (currentBet == null || gameState == null) return false;
    
    return currentBet['side'] == gameState['winningSide'];
  }
} 