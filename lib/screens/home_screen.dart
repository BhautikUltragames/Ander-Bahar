import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'multiplayer_lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _button1SlideAnimation;
  late Animation<Offset> _button2SlideAnimation;
  late Animation<Offset> _button3SlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    // Button 1 - Slide from left
    _button1SlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    ));

    // Button 2 - Slide from right
    _button2SlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
    ));

    // Button 3 - Slide from bottom
    _button3SlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.orange.shade600,
              Colors.red.shade700,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildMainContent(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // App logo/title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.yellow.shade400,
                  Colors.orange.shade500,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.casino,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'अंदर बाहर',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'ANDAR BAHAR',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Traditional Indian Card Game',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game mode selection text
                     const Text(
             'Choose Your Game Mode',
             textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.w600,
               color: Colors.white,
             ),
           ),
          
          const SizedBox(height: 40),
          
          // Human vs AI button - Slide from left
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _button1SlideAnimation,
                child: _buildGameModeButton(
            title: 'HUMAN vs AI',
            subtitle: 'Play against computer',
            icon: Icons.smart_toy,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade800,
              ],
            ),
            onTap: () => _navigateToGame(true),
          ),
              );
            },
          ),
          
          const SizedBox(height: 30),
          
          // Multiplayer button - Slide from right
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _button2SlideAnimation,
                child: _buildGameModeButton(
            title: 'MULTIPLAYER',
            subtitle: 'Play with other players',
            icon: Icons.group,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade600,
                Colors.green.shade800,
              ],
            ),
            onTap: () => _navigateToGame(false),
          ),
              );
            },
          ),
          
          const SizedBox(height: 50),
          
          // How to play button - Slide from bottom
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _button3SlideAnimation,
                child: _buildSecondaryButton(
            title: 'HOW TO PLAY',
            icon: Icons.help_outline,
            onTap: _showHowToPlay,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                
                // Text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                          subtitle,
                          style: const TextStyle(
                              fontSize: 16,
                            color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Arrow
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                  title,
                    style: TextStyle(
                      fontSize: 18,
                    fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Free to Play • No Real Money',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.yellow,
              ),
              const SizedBox(width: 4),
              const Text(
                'Authentic Indian Gaming Experience',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToGame(bool isAIGame) {
    if (isAIGame) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(isAIGame: isAIGame),
        ),
      );
    } else {
      // Navigate to multiplayer lobby
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MultiplayerLobbyScreen(),
        ),
      );
    }
  }

  void _showHowToPlay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play Andar Bahar'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. Game Setup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• A single deck of 52 cards is used\n• Two betting areas: Andar (Left) and Bahar (Right)\n'),
              
              Text(
                '2. How to Play',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Place your bet on either Andar or Bahar\n• A Joker card is revealed in the center\n• Cards are dealt alternately to both sides\n'),
              
              Text(
                '3. Starting Rule',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• If Joker is BLACK (♣♠): First card goes to Andar\n• If Joker is RED (♥♦): First card goes to Bahar\n'),
              
              Text(
                '4. Winning',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• The side that gets a card matching the Joker\'s rank wins\n• Andar pays 0.9:1, Bahar pays 1:1'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It!'),
          ),
        ],
      ),
    );
  }
} 