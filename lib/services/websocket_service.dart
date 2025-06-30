import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _playerId;
  String? _roomId;
  
  // Game state from server
  Map<String, dynamic>? _serverGameState;
  List<Map<String, dynamic>> _players = [];
  
  // Connection callbacks
  Function(String message)? onError;
  Function(String roomId, String playerId)? onRoomCreated;
  Function(String roomId, String playerId)? onRoomJoined;
  Function()? onRoomLeft;
  Function(Map<String, dynamic> gameState, List<Map<String, dynamic>> players)? onGameStateUpdate;
  Function(List<Map<String, dynamic>> rooms)? onRoomListUpdate;
  
  // Getters
  bool get isConnected => _isConnected;
  String? get playerId => _playerId;
  String? get roomId => _roomId;
  Map<String, dynamic>? get serverGameState => _serverGameState;
  List<Map<String, dynamic>> get players => _players;
  
  // Connect to WebSocket server
  Future<void> connect({String serverUrl = 'ws://localhost:8080'}) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      
      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          onError?.call('Connection error: $error');
          // Delay notifyListeners to avoid setState during build
          Future.microtask(() => notifyListeners());
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          // Delay notifyListeners to avoid setState during build
          Future.microtask(() => notifyListeners());
        },
      );
      
      _isConnected = true;
      // Delay notifyListeners to avoid setState during build
      Future.microtask(() => notifyListeners());
      print('Connected to WebSocket server');
    } catch (e) {
      print('Failed to connect: $e');
      onError?.call('Failed to connect: $e');
    }
  }
  
  // Disconnect from server
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _playerId = null;
    _roomId = null;
    _serverGameState = null;
    _players.clear();
    notifyListeners();
  }
  
  // Send message to server
  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      print('DEBUG: Received message: ${data['type']}');
      
      switch (data['type']) {
        case 'roomCreated':
          _playerId = data['playerId'];
          _roomId = data['roomId'];
          onRoomCreated?.call(data['roomId'], data['playerId']);
          break;
          
        case 'roomJoined':
          _playerId = data['playerId'];
          _roomId = data['roomId'];
          onRoomJoined?.call(data['roomId'], data['playerId']);
          break;
          
        case 'leftRoom':
          _playerId = null;
          _roomId = null;
          _serverGameState = null;
          _players.clear();
          onRoomLeft?.call();
          break;
          
        case 'gameState':
          final newPhase = data['gameState']?['phase'];
          _serverGameState = data['gameState'];
          _players = List<Map<String, dynamic>>.from(data['players'] ?? []);
          final connectedCount = _players.where((p) => p['isConnected'] == true).length;
          print('DEBUG: Game state phase: $newPhase, Connected players: $connectedCount');
          onGameStateUpdate?.call(_serverGameState!, _players);
          break;
          
        case 'roomList':
          final rooms = List<Map<String, dynamic>>.from(data['rooms'] ?? []);
          onRoomListUpdate?.call(rooms);
          break;
          
        case 'ping':
          // Respond to server ping with pong
          _sendMessage({
            'type': 'pong',
            'pingId': data['pingId'],
            'roomId': data['roomId'],
          });
          print('DEBUG: Received ping, sent pong response');
          break;
          
        case 'error':
          print('Server error: ${data['message']}');
          onError?.call(data['message']);
          break;
          
        default:
          print('Unknown message type: ${data['type']}');
      }
      
      // Delay notifyListeners to avoid setState during build
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Error parsing message: $e');
    }
  }
  
  // Create a new room
  void createRoom(String playerName) {
    _sendMessage({
      'type': 'createRoom',
      'playerName': playerName,
    });
  }
  
  // Join an existing room
  void joinRoom(String roomId, String playerName) {
    _sendMessage({
      'type': 'joinRoom',
      'roomId': roomId,
      'playerName': playerName,
    });
  }
  
  // Leave current room
  void leaveRoom() {
    if (_roomId != null) {
      _sendMessage({
        'type': 'leaveRoom',
        'roomId': _roomId,
      });
    }
  }
  
  // Start game (host only)
  void startGame() {
    print('DEBUG: startGame() called');
    print('DEBUG: _roomId = $_roomId');
    print('DEBUG: _isConnected = $_isConnected');
    print('DEBUG: isHost() = ${isHost()}');
    
    if (_roomId != null) {
      print('DEBUG: Sending startGame message to server');
      _sendMessage({
        'type': 'startGame',
        'roomId': _roomId,
      });
    } else {
      print('DEBUG: Cannot start game - no room ID');
    }
  }
  
  // Place a bet
  void placeBet(String side, int amount) {
    if (_roomId != null) {
      _sendMessage({
        'type': 'placeBet',
        'roomId': _roomId,
        'side': side,
        'amount': amount,
      });
    }
  }
  
  // Get list of available rooms
  void getRooms() {
    _sendMessage({
      'type': 'getRooms',
    });
  }
  
  // Get current player info
  Map<String, dynamic>? getCurrentPlayer() {
    if (_playerId == null) return null;
    
    try {
      return _players.firstWhere((player) => player['id'] == _playerId);
    } catch (e) {
      return null;
    }
  }
  
  // Check if current player is host
  bool isHost() {
    final player = getCurrentPlayer();
    return player?['isHost'] ?? false;
  }
  
  // Get player balance
  int getPlayerBalance() {
    final player = getCurrentPlayer();
    return player?['balance'] ?? 0;
  }
  
  // Get current bet for player
  Map<String, dynamic>? getCurrentBet() {
    final player = getCurrentPlayer();
    return player?['currentBet'];
  }
  
  // Convert server game state to local GamePhase
  GamePhase getGamePhase() {
    if (_serverGameState == null) return GamePhase.waiting;
    
    switch (_serverGameState!['phase']) {
      case 'waiting':
        return GamePhase.waiting;
      case 'betting':
        return GamePhase.betting;
      case 'readyToPlay':
        return GamePhase.readyToPlay;
      case 'dealing':
        return GamePhase.dealing;
      case 'finished':
        return GamePhase.finished;
      case 'showResult':
        return GamePhase.showResult;
      default:
        return GamePhase.waiting;
    }
  }
  
  // Get connected player count
  int getConnectedPlayerCount() {
    return _players.where((player) => player['isConnected'] == true).length;
  }
  
  // Get betting timer remaining time (estimated)
  int getBettingTimeRemaining() {
    // This would need to be calculated based on server timing
    // For now, return a default value
    return 5;
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
} 