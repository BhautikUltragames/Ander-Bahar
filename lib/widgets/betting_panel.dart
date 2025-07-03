import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'dart:async';

class BettingPanel extends StatefulWidget {
  final int playerBalance;
  final GamePhase gamePhase;
  final List<Bet> currentBets;
  final int totalBetAmount;
  final Function(BetSide, int) onBetPlaced;
  final VoidCallback? onRebet;

  const BettingPanel({
    Key? key,
    required this.playerBalance,
    required this.gamePhase,
    required this.currentBets,
    required this.totalBetAmount,
    required this.onBetPlaced,
    this.onRebet,
  }) : super(key: key);

  @override
  State<BettingPanel> createState() => _BettingPanelState();
}

class _BettingPanelState extends State<BettingPanel> {
  int selectedAmount = 50;
  final List<int> chipValues = [25, 50, 100, 250, 500];
  int countdownSeconds = 5;
  int bettingTimeRemaining = 10;
  Timer? _countdownTimer;
  Timer? _bettingTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(BettingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start betting timer when entering betting phase
    if (oldWidget.gamePhase != GamePhase.betting && 
        widget.gamePhase == GamePhase.betting) {
      _startBettingTimer();
    }
    
    // Start countdown when entering readyToPlay phase
    if (oldWidget.gamePhase != GamePhase.readyToPlay && 
        widget.gamePhase == GamePhase.readyToPlay) {
      _startCountdown();
    }
    
    // Stop timers when leaving their respective phases
    if (oldWidget.gamePhase == GamePhase.betting && 
        widget.gamePhase != GamePhase.betting) {
      _stopBettingTimer();
    }
    
    if (oldWidget.gamePhase == GamePhase.readyToPlay && 
        widget.gamePhase != GamePhase.readyToPlay) {
      _stopCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bettingTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    countdownSeconds = 5;
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdownSeconds--;
      });
      
      if (countdownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _startBettingTimer() {
    bettingTimeRemaining = 10;
    _bettingTimer?.cancel();
    
    _bettingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        bettingTimeRemaining--;
      });
      
      if (bettingTimeRemaining <= 0) {
        timer.cancel();
      }
    });
  }

  void _stopBettingTimer() {
    _bettingTimer?.cancel();
    bettingTimeRemaining = 10;
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    countdownSeconds = 5;
  }

  @override
  Widget build(BuildContext context) {
    final canBet = widget.gamePhase == GamePhase.betting;
    final isCountdown = widget.gamePhase == GamePhase.readyToPlay;
    
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
          _buildBalanceDisplay(),
          const SizedBox(height: 16),
          
          // Current Bets Display
          if (widget.currentBets.isNotEmpty) _buildCurrentBetsDisplay(),
          
          // Game Phase Indicator
          _buildGamePhaseIndicator(),
          const SizedBox(height: 16),
          
          // Chip Selection (only during betting phase)
          if (canBet) _buildChipSelection(),
          if (canBet) const SizedBox(height: 16),
          
          // Betting Buttons or Countdown Display
          if (canBet) _buildBettingButtons(canBet),
          if (isCountdown) _buildCountdownDisplay(),
          
          // Rebet Button
          if (widget.onRebet != null && !canBet && !isCountdown) _buildRebetButton(),
        ],
      ),
    );
  }

  Widget _buildBalanceDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.yellow,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '₹${widget.playerBalance}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBetsDisplay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Bets (Total: ₹${widget.totalBetAmount})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 60), // Limit height to show ~3 bets
            child: widget.currentBets.length > 3
                ? Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.currentBets.length,
                      itemBuilder: (context, index) {
                        final bet = widget.currentBets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• ${bet.side == BetSide.andar ? 'Andar' : 'Bahar'}: ₹${bet.amount}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.currentBets.map((bet) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• ${bet.side == BetSide.andar ? 'Andar' : 'Bahar'}: ₹${bet.amount}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePhaseIndicator() {
    String phaseText;
    Color phaseColor;
    
    switch (widget.gamePhase) {
      case GamePhase.betting:
        phaseText = 'Choose Your Side & Amount (${bettingTimeRemaining}s)';
        phaseColor = Colors.green;
        break;
      case GamePhase.readyToPlay:
        phaseText = 'Starting in ${countdownSeconds}s...';
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
        Wrap(
          spacing: 8,
          children: chipValues.map((value) => _buildChipButton(value)).toList(),
        ),
      ],
    );
  }

  Widget _buildChipButton(int value) {
    final isSelected = value == selectedAmount;
    final canAfford = value <= widget.playerBalance;
    
    return GestureDetector(
      onTap: canAfford ? () => setState(() => selectedAmount = value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Colors.yellow.shade600, Colors.yellow.shade700]
                : canAfford
                    ? [Colors.orange.shade600, Colors.orange.shade700]
                    : [Colors.grey.shade600, Colors.grey.shade700],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.yellow.shade300 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '₹$value',
            style: TextStyle(
              color: canAfford ? Colors.white : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBettingButtons(bool canBet) {
    return Row(
      children: [
        Expanded(
          child: _buildBetButton(
            'ANDAR',
            BetSide.andar,
            Colors.blue.shade700,
            canBet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBetButton(
            'BAHAR',
            BetSide.bahar,
            Colors.yellow.shade700,
            canBet,
          ),
        ),
      ],
    );
  }

  Widget _buildBetButton(String text, BetSide side, Color color, bool enabled) {
    final canAfford = selectedAmount <= widget.playerBalance;
    final isEnabled = enabled && canAfford;
    
    return GestureDetector(
      onTap: isEnabled ? () => widget.onBetPlaced(side, selectedAmount) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isEnabled
                ? [color, color.withOpacity(0.8)]
                : [Colors.grey.shade600, Colors.grey.shade700],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isEnabled)
                Text(
                  '₹$selectedAmount',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.yellow,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Starting in ${countdownSeconds}s...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRebetButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: widget.onRebet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade600,
                Colors.orange.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'REBET',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 