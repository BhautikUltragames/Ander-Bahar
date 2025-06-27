import 'package:flutter/material.dart';
import '../models/card.dart';

class CardWidget extends StatefulWidget {
  final PlayingCard? card;
  final double width;
  final double height;
  final bool isFlipped;
  final bool showAnimation;
  final VoidCallback? onTap;
  final bool isJoker;

  const CardWidget({
    Key? key,
    this.card,
    this.width = 60,
    this.height = 90,
    this.isFlipped = false,
    this.showAnimation = false,
    this.onTap,
    this.isJoker = false,
  }) : super(key: key);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation && !oldWidget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.showAnimation ? _scaleAnimation.value : 1.0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(widget.isFlipped ? _flipAnimation.value * 3.14159 : 0),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isJoker ? Colors.amber : Colors.grey.shade400,
                    width: widget.isJoker ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
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
        },
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
            Colors.blue.shade800,
            Colors.blue.shade900,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: widget.width * 0.6,
          height: widget.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.casino_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    final card = widget.card!;
    final isRed = card.isRed;
    
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
          // Top left corner
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.rankDisplay,
                  style: TextStyle(
                    color: isRed ? Colors.red.shade700 : Colors.black,
                    fontSize: widget.width * 0.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    color: isRed ? Colors.red.shade700 : Colors.black,
                    fontSize: widget.width * 0.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Center suit symbol
          Center(
            child: Text(
              card.suitSymbol,
              style: TextStyle(
                color: isRed ? Colors.red.shade700 : Colors.black,
                fontSize: widget.width * 0.4,
              ),
            ),
          ),
          
          // Bottom right corner (rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.rankDisplay,
                    style: TextStyle(
                      color: isRed ? Colors.red.shade700 : Colors.black,
                      fontSize: widget.width * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    card.suitSymbol,
                    style: TextStyle(
                      color: isRed ? Colors.red.shade700 : Colors.black,
                      fontSize: widget.width * 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Joker indicator
          if (widget.isJoker)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 