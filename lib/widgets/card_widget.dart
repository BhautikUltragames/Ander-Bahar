import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/card.dart';

class CardWidget extends StatefulWidget {
  final PlayingCard? card;
  final double width;
  final double height;
  final bool isFlipped;
  final bool showAnimation;
  final VoidCallback? onTap;
  final bool isJoker;
  final bool isWinningCard;
  const CardWidget({
    Key? key,
    this.card,
    this.width = 60,
    this.height = 90,
    this.isFlipped = false,
    this.showAnimation = false,
    this.onTap,
    this.isJoker = false,
    this.isWinningCard = false,
  }) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _winningController;
  
  late Animation<double> _flipAnimation;
  late Animation<double> _winningScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Flip animation controller
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Winning card controller
    _winningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _setupAnimations();

    // Start winning animation if needed
    if (widget.isWinningCard) {
      _startWinningAnimation();
    }

    // Start flip animation if needed
    if (widget.showAnimation && widget.card?.isVisible == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _flipController.forward();
      });
    }
  }

  void _setupAnimations() {
    // Smooth flip animation
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // Subtle winning card animation
    _winningScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _winningController,
      curve: Curves.easeInOut,
    ));
  }

  void _startWinningAnimation() {
    _winningController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isWinningCard && !oldWidget.isWinningCard) {
      _startWinningAnimation();
    } else if (!widget.isWinningCard && oldWidget.isWinningCard) {
      _winningController.stop();
      _winningController.reset();
    }

    if (widget.showAnimation && !oldWidget.showAnimation) {
      _flipController.forward();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _winningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          const double scale = 1.0;
          return Transform.scale(
            scale: scale,
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Material(
      elevation: widget.isWinningCard ? 8.0 : 3.0,
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(widget.isFlipped ? _flipAnimation.value * math.pi : 0),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isWinningCard 
                  ? Colors.yellow.shade400 
                  : widget.isJoker 
                      ? Colors.amber 
                      : Colors.grey.shade400,
              width: widget.isWinningCard ? 4 : widget.isJoker ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isWinningCard) ...[
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ] else
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: widget.card == null
                ? _buildEmptyCard()
                : widget.card!.isVisible
                    ? _buildCardFront()
                    : _buildCardBack(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade700,
            Colors.blue.shade800,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: widget.width * 0.6,
          height: widget.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.casino,
            color: Colors.white70,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    final card = widget.card!;
    final isRed = card.isRed;
    final color = isRed ? Colors.red.shade700 : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Top-left rank and suit
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.rankDisplay,
                  style: TextStyle(
                    color: color,
                    fontSize: widget.width * 0.2,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    color: color,
                    fontSize: widget.width * 0.18,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Center large suit symbol
          Center(
            child: Text(
              card.suitSymbol,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: widget.width * 0.5,
                height: 1.0,
              ),
            ),
          ),
          
          // Bottom-right rank and suit (rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: math.pi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.rankDisplay,
                    style: TextStyle(
                      color: color,
                      fontSize: widget.width * 0.2,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card.suitSymbol,
                    style: TextStyle(
                      color: color,
                      fontSize: widget.width * 0.18,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Joker indicator
          if (widget.isJoker)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'J',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: widget.width * 0.15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 