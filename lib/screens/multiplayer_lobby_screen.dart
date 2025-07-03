import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import 'multiplayer_game_screen.dart';

class _LobbyHoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isEnabled;

  const _LobbyHoverButton({
    required this.child,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  State<_LobbyHoverButton> createState() => _LobbyHoverButtonState();
}

class _LobbyHoverButtonState extends State<_LobbyHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: (_isHovered && widget.isEnabled) ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                if (_isHovered && widget.isEnabled)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isConnecting = false;
  
  @override
  void initState() {
    super.initState();
    _nameController.text = 'Player${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  Future<void> _joinGlobalRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    final wsService = Provider.of<WebSocketService>(context, listen: false);
    
    // Set up callbacks
    wsService.onJoinedGlobal = () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MultiplayerGameScreen(),
          ),
        );
      }
    };
    
    wsService.onError = (message) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    };

    try {
      await wsService.connectAndJoinGlobal(_nameController.text.trim());
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Failed to connect to multiplayer server'),
                const Text('Please make sure the server is running'),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          'Join Multiplayer Game',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Text(
                          'Enter your name to join the global room\nRounds start every 10 seconds!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Player Name Input
                        _buildPlayerNameInput(),
                        const SizedBox(height: 32),
                        
                        // Join Button
                        _buildJoinButton(),
                        
                        if (_isConnecting) ...[
                          const SizedBox(height: 24),
                          _buildConnectingIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Text(
              'Andar Bahar - Multiplayer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance back button
        ],
      ),
    );
  }

  Widget _buildPlayerNameInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            enabled: !_isConnecting,
            decoration: InputDecoration(
              hintText: 'Enter your player name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 16),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _joinGlobalRoom(),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return _LobbyHoverButton(
      isEnabled: !_isConnecting,
      onPressed: _joinGlobalRoom,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isConnecting ? Colors.grey : Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _isConnecting ? 'Connecting...' : 'Join Global Room',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildConnectingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Connecting to server...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 