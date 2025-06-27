import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../models/game_state.dart';

class MultiplayerBettingPanel extends StatefulWidget {
  final WebSocketService wsService;
  final int bettingTimeRemaining;

  const MultiplayerBettingPanel({
    Key? key,
    required this.wsService,
    required this.bettingTimeRemaining,
  }) : super(key: key);

  @override
  State<MultiplayerBettingPanel> createState() => _MultiplayerBettingPanelState();
}

class _MultiplayerBettingPanelState extends State<MultiplayerBettingPanel> {
  int selectedAmount = 50;
  final List<int> chipValues = [25, 50, 100, 250, 500];

  @override
  Widget build(BuildContext context) {
    final gamePhase = widget.wsService.getGamePhase();
    final playerBalance = widget.wsService.getPlayerBalance();
    final currentBet = widget.wsService.getCurrentBet();
    final canBet = gamePhase == GamePhase.betting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade800,
            Colors.green.shade900,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Balance Display
          _buildBalanceDisplay(playerBalance),
          const SizedBox(height: 16),
          
          // Current Bet Display
          if (currentBet != null) _buildCurrentBetDisplay(currentBet),
          
          // Game Phase Indicator
          _buildGamePhaseIndicator(gamePhase),
          const SizedBox(height: 16),
          
          // Chip Selection (only during betting phase)
          if (canBet) _buildChipSelection(),
          if (canBet) const SizedBox(height: 16),
          
          // Betting Buttons (only during betting phase)
          if (canBet) _buildBettingButtons(),
          
          // Status message for non-betting phases
          if (!canBet) _buildStatusMessage(gamePhase),
        ],
      ),
    );
  }

  Widget _buildBalanceDisplay(int balance) {
    return Row(
      children: [
        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Balance: ',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Text(
          '₹$balance',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBetDisplay(Map<String, dynamic> bet) {
    final side = bet['side']?.toString().toUpperCase() ?? '';
    final amount = bet['amount'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            'Your Bet: $side - ₹$amount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePhaseIndicator(GamePhase gamePhase) {
    String phaseText;
    Color phaseColor;
    
    switch (gamePhase) {
      case GamePhase.waiting:
        phaseText = widget.wsService.isHost() ? 'Press START GAME' : 'Waiting for host';
        phaseColor = Colors.orange;
        break;
      case GamePhase.betting:
        phaseText = 'Place Your Bets! (${widget.bettingTimeRemaining}s)';
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
      default:
        phaseText = 'Waiting...';
        phaseColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: phaseColor),
      ),
      child: Text(
        phaseText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChipSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Chip Amount:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chipValues.map((value) {
              final isSelected = selectedAmount == value;
              final canAfford = value <= widget.wsService.getPlayerBalance();
              
              return GestureDetector(
                onTap: canAfford ? () {
                  setState(() {
                    selectedAmount = value;
                  });
                } : null,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.yellow.shade600 
                        : canAfford 
                            ? Colors.orange.shade600 
                            : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected ? Colors.yellow.shade800 : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹$value',
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBettingButtons() {
    final canAfford = selectedAmount <= widget.wsService.getPlayerBalance();
    
    return Row(
      children: [
        // Andar Button
        Expanded(
          child: GestureDetector(
            onTap: canAfford ? () => _placeBet('andar') : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: canAfford ? [
                    Colors.blue.shade600,
                    Colors.blue.shade700,
                  ] : [
                    Colors.grey.shade600,
                    Colors.grey.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'ANDAR',
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹$selectedAmount',
                    style: TextStyle(
                      color: canAfford ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Bahar Button
        Expanded(
          child: GestureDetector(
            onTap: canAfford ? () => _placeBet('bahar') : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: canAfford ? [
                    Colors.red.shade600,
                    Colors.red.shade700,
                  ] : [
                    Colors.grey.shade600,
                    Colors.grey.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'BAHAR',
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹$selectedAmount',
                    style: TextStyle(
                      color: canAfford ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(GamePhase gamePhase) {
    String message;
    IconData icon;
    Color color;
    
    switch (gamePhase) {
      case GamePhase.waiting:
        message = widget.wsService.isHost() 
            ? 'You are the host. Start the game when ready!'
            : 'Waiting for the host to start the game...';
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case GamePhase.readyToPlay:
        message = 'Get ready! Cards will be dealt soon...';
        icon = Icons.timer;
        color = Colors.yellow;
        break;
      case GamePhase.dealing:
        message = 'Cards are being dealt. Watch for the match!';
        icon = Icons.style;
        color = Colors.blue;
        break;
      case GamePhase.finished:
        message = 'Round finished! Calculating results...';
        icon = Icons.calculate;
        color = Colors.purple;
        break;
      case GamePhase.showResult:
        message = 'Results are in! Check if you won!';
        icon = Icons.celebration;
        color = Colors.orange;
        break;
      default:
        message = 'Waiting for game updates...';
        icon = Icons.info;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _placeBet(String side) {
    widget.wsService.placeBet(side, selectedAmount);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bet placed: ${side.toUpperCase()} - ₹$selectedAmount'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 