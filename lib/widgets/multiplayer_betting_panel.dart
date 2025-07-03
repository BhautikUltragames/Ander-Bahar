import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

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
    final gameState = widget.wsService.serverGameState;
    final gamePhase = gameState?['phase'] ?? 'betting';
    final playerBalance = widget.wsService.getPlayerBalance();
    final canBet = (gamePhase == 'betting' || gamePhase == 'waitingForPlayers') && widget.bettingTimeRemaining > 0;

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
          
          // Current Round Bets Display
          _buildCurrentBetDisplay(),
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

  Widget _buildCurrentBetDisplay() {
    final gameState = widget.wsService.serverGameState;
    if (gameState == null) return Container();
    
    final allBets = gameState['bets'] as List<dynamic>? ?? [];
    final playerId = widget.wsService.playerId;
    if (playerId == null) return Container();
    
    // Get current player's bets for this round
    final myBets = allBets.where((bet) => bet['playerId'] == playerId).toList();
    
    if (myBets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Text(
              'No bets placed this round',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    // Calculate totals for each side
    int andarTotal = 0;
    int baharTotal = 0;
    
    for (final bet in myBets) {
      final side = bet['side'] as String;
      final amount = bet['amount'] as int;
      
      if (side == 'andar') {
        andarTotal += amount;
      } else if (side == 'bahar') {
        baharTotal += amount;
      }
    }
    
    final totalAmount = andarTotal + baharTotal;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'Your Bets This Round (₹$totalAmount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (andarTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Andar: ₹$andarTotal',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              if (andarTotal > 0 && baharTotal > 0) const SizedBox(width: 8),
              if (baharTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Bahar: ₹$baharTotal',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamePhaseIndicator(String gamePhase) {
    String phaseText = 'Unknown Phase';
    Color phaseColor = Colors.grey;
    IconData phaseIcon = Icons.help;

    switch (gamePhase) {
      case 'betting':
        phaseText = 'Betting Phase (${widget.bettingTimeRemaining}s left)';
        phaseColor = widget.bettingTimeRemaining <= 3 ? Colors.red : Colors.green;
        phaseIcon = Icons.timer;
        break;
      case 'dealing':
        phaseText = 'Cards Being Dealt...';
        phaseColor = Colors.blue;
        phaseIcon = Icons.style;
        break;
      case 'finished':
        phaseText = 'Round Finished';
        phaseColor = Colors.purple;
        phaseIcon = Icons.check_circle;
        break;
      case 'showResult':
        phaseText = 'Showing Results';
        phaseColor = Colors.orange;
        phaseIcon = Icons.emoji_events;
        break;
      case 'waitingForPlayers':
        phaseText = 'Waiting for Players (${widget.bettingTimeRemaining}s)';
        phaseColor = Colors.amber;
        phaseIcon = Icons.people_outline;
        break;
      default:
        phaseText = 'Waiting for Next Round...';
        phaseColor = Colors.orange;
        phaseIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(phaseIcon, color: phaseColor, size: 16),
          const SizedBox(width: 8),
          Text(
            phaseText,
            style: TextStyle(
              color: phaseColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Bet Amount:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: chipValues.map((value) {
            final isSelected = selectedAmount == value;
            final canAfford = widget.wsService.getPlayerBalance() >= value;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: canAfford ? () {
                    setState(() {
                      selectedAmount = value;
                    });
                  } : null,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.orange 
                          : canAfford 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.orange 
                            : canAfford 
                                ? Colors.white30
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '₹$value',
                        style: TextStyle(
                          color: canAfford ? Colors.white : Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBettingButtons() {
    final canAfford = widget.wsService.getPlayerBalance() >= selectedAmount;
    
    return Row(
      children: [
        // Andar button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: canAfford ? () => _placeBet('andar') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ANDAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹$selectedAmount',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Bahar button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: canAfford ? () => _placeBet('bahar') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BAHAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹$selectedAmount',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(String gamePhase) {
    String message = 'Waiting...';
    Color messageColor = Colors.white70;
    IconData messageIcon = Icons.hourglass_empty;

    switch (gamePhase) {
      case 'dealing':
        message = 'Cards are being dealt. Watch the game!';
        messageColor = Colors.blue;
        messageIcon = Icons.style;
        break;
      case 'finished':
        message = 'Round finished. Results coming up...';
        messageColor = Colors.purple;
        messageIcon = Icons.check_circle;
        break;
      case 'showResult':
        message = 'Viewing results. Next round starts soon!';
        messageColor = Colors.orange;
        messageIcon = Icons.emoji_events;
        break;
      case 'waitingForPlayers':
        message = 'No bets placed last round. Next round starts in ${widget.bettingTimeRemaining}s...';
        messageColor = Colors.amber;
        messageIcon = Icons.people_outline;
        break;
      default:
        message = 'Get ready for the next betting round!';
        messageColor = Colors.white70;
        messageIcon = Icons.refresh;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: messageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: messageColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(messageIcon, color: messageColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _placeBet(String side) {
    if (widget.wsService.getPlayerBalance() >= selectedAmount) {
      widget.wsService.placeBet(side, selectedAmount);
    }
  }
} 