import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'multiplayer_lobby_screen.dart';
import 'package:andar_bahar_game/services/audio_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/connectivity_listener.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _HoverButton({
    required this.child,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                AudioService.playClick();
                widget.onTap();
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double width;
  final double height;

  const _SecondaryHoverButton({
    required this.child,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  State<_SecondaryHoverButton> createState() => _SecondaryHoverButtonState();
}

class _SecondaryHoverButtonState extends State<_SecondaryHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                AudioService.playClick();
                widget.onTap();
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _button1SlideAnimation;
  late Animation<Offset> _button2SlideAnimation;

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

    // Button 1 - Multiplayer - Slide from left
    _button1SlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutBack),
    ));

    // Button 2 - How to Play - Slide from right
    _button2SlideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
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
    return ConnectivityListener(
      child: Scaffold(
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
                

              ],
            ),
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
          // User Profile Section
          _buildUserProfile(),
          
          const SizedBox(height: 20),
          
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

  Widget _buildUserProfile() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // User Profile Picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: authProvider.userPhotoUrl.isNotEmpty
                      ? Image.network(
                          authProvider.userPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.userDisplayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Logout Button
              _SecondaryHoverButton(
                width: 90,
                height: 40,
                onTap: () async {
                  await _showLogoutDialog(authProvider);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(AuthProvider authProvider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome text
          const Text(
            'Welcome to Multiplayer Andar Bahar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'Join the global room to play with players from around the world',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Multiplayer button - Slide from left
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _button1SlideAnimation,
                child: _buildGameModeButton(
                  title: 'PLAY',
                  subtitle: 'Play with other players worldwide',
                  icon: Icons.play_arrow,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade600,
                      Colors.green.shade800,
                    ],
                  ),
                  onTap: () => _navigateToMultiplayer(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // How to play button - Slide from right
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _button2SlideAnimation,
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
    return Center(
      child: _HoverButton(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 120,
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 40,
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
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                  size: 28,
                ),
              ),
            ],
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
    return Center(
      child: _SecondaryHoverButton(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 70,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
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
    );
  }



  void _navigateToMultiplayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MultiplayerLobbyScreen(),
      ),
    );
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
                '1. Join the Game',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Enter your name to join the global room\n• Connect with players from around the world\n'),
              
              Text(
                '2. Game Setup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• A single deck of 52 cards is used\n• Two betting areas: Andar (Left) and Bahar (Right)\n'),
              
              Text(
                '3. How to Play',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Each round lasts 10 seconds for betting\n• Place your bet on either Andar or Bahar\n• A Joker card is revealed in the center\n• Cards are dealt alternately to both sides\n'),
              
              Text(
                '4. Starting Rule',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• If Joker is BLACK (♣♠): First card goes to Andar\n• If Joker is RED (♥♦): First card goes to Bahar\n'),
              
              Text(
                '5. Winning',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• The side that gets a card matching the Joker\'s rank wins\n• Winners get 95% return on their bet (5% house edge)\n• New rounds start automatically every 10 seconds'),
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