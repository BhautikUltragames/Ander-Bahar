import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import 'multiplayer_game_screen.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  bool _isConnecting = false;
  List<Map<String, dynamic>> _availableRooms = [];
  
  @override
  void initState() {
    super.initState();
    _nameController.text = 'Player${DateTime.now().millisecondsSinceEpoch % 1000}';
    // Delay connection to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToServer();
    });
  }

  Future<void> _connectToServer() async {
    setState(() {
      _isConnecting = true;
    });

    final wsService = Provider.of<WebSocketService>(context, listen: false);
    
    // Set up callbacks
    wsService.onRoomCreated = (roomId, playerId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MultiplayerGameScreen(),
        ),
      );
    };
    
    wsService.onRoomJoined = (roomId, playerId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MultiplayerGameScreen(),
        ),
      );
    };
    
    wsService.onError = (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    };
    
    wsService.onRoomListUpdate = (rooms) {
      setState(() {
        _availableRooms = rooms;
      });
    };

    try {
      await wsService.connect();
      // Get initial room list
      wsService.getRooms();
    } catch (e) {
      // Show error message with instructions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Multiplayer server not available'),
              Text('Please start the WebSocket server first'),
              Text('See README.md for instructions'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }

    setState(() {
      _isConnecting = false;
    });
  }

  void _createRoom() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.createRoom(_nameController.text.trim());
  }

  void _joinRoom(String roomId) {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.joinRoom(roomId, _nameController.text.trim());
  }

  void _joinRoomById() {
    if (_roomIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter room ID')),
      );
      return;
    }

    _joinRoom(_roomIdController.text.trim());
  }

  void _refreshRooms() {
    final wsService = Provider.of<WebSocketService>(context, listen: false);
    wsService.getRooms();
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
              
              // Connection Status
              if (_isConnecting) _buildConnectingIndicator(),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Player Name Input
                      _buildPlayerNameInput(),
                      const SizedBox(height: 24),
                      
                      // Create Room Button
                      _buildCreateRoomButton(),
                      const SizedBox(height: 16),
                      
                      // Join Room by ID
                      _buildJoinRoomByIdSection(),
                      const SizedBox(height: 32),
                      
                      // Available Rooms
                      _buildAvailableRoomsSection(),
                    ],
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Multiplayer Lobby',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _refreshRooms,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Connecting to server...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNameInput() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              maxLength: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRoomButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isConnecting ? null : _createRoom,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 24),
            const SizedBox(width: 8),
            const Text(
              'CREATE NEW ROOM',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinRoomByIdSection() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join Room by ID',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Room ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnecting ? null : _joinRoomById,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('JOIN'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRoomsSection() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Available Rooms',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_availableRooms.length} rooms',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_availableRooms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.meeting_room_outlined, 
                           size: 64, 
                           color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No rooms available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new room to start playing!',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableRooms.length,
                itemBuilder: (context, index) {
                  final room = _availableRooms[index];
                  return _buildRoomCard(room);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final roomId = room['roomId'] ?? '';
    final playerCount = room['playerCount'] ?? 0;
    final maxPlayers = room['maxPlayers'] ?? 6;
    final gamePhase = room['gamePhase'] ?? 'waiting';
    
    final isJoinable = playerCount < maxPlayers && gamePhase == 'waiting';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isJoinable ? Colors.green : Colors.grey,
          child: Icon(
            Icons.meeting_room,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Room $roomId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$playerCount/$maxPlayers players • ${_getGamePhaseText(gamePhase)}',
        ),
        trailing: ElevatedButton(
          onPressed: isJoinable ? () => _joinRoom(roomId) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isJoinable ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: Text(isJoinable ? 'JOIN' : 'FULL'),
        ),
      ),
    );
  }

  String _getGamePhaseText(String phase) {
    switch (phase) {
      case 'waiting':
        return 'Waiting for players';
      case 'betting':
        return 'Betting in progress';
      case 'dealing':
        return 'Game in progress';
      default:
        return 'In game';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }
} 