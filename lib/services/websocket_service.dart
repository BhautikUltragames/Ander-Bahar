import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import 'dart:html' as html; // for web offline detection

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _playerId;
  // Heartbeat timers for connectivity check
  Timer? _pingTimer;
  Timer? _pongTimeoutTimer;
  final Duration _pingInterval = const Duration(seconds: 5);
  final Duration _pongTimeout = const Duration(seconds: 3);
  
  // Game state from server
  Map<String, dynamic>? _serverGameState;
  List<Map<String, dynamic>> _players = [];
  
  // Connection callbacks
  Function(String message)? onError;
  Function()? onJoinedGlobal;
  Function(Map<String, dynamic> gameState, List<Map<String, dynamic>> players)? onGameStateUpdate;
  
  // Getters
  bool get isConnected => _isConnected;
  String? get playerId => _playerId;
  Map<String, dynamic>? get serverGameState => _serverGameState;
  List<Map<String, dynamic>> get players => _players;
  
  // Get current player data
  Map<String, dynamic>? getCurrentPlayer() {
    if (_playerId == null) return null;
    return _players.firstWhere(
      (player) => player['id'] == _playerId,
      orElse: () => <String, dynamic>{},
    );
  }
  
  // Get current player balance
  int getPlayerBalance() {
    final player = getCurrentPlayer();
    return player?['balance'] ?? 0;
  }
  
  // Get betting time remaining
  int getBettingTimeLeft() {
    return _serverGameState?['bettingTimeLeft'] ?? 0;
  }
  
  // Connect to WebSocket server and auto-join global room
  Future<void> connectAndJoinGlobal(String playerName) async {
    // Register browser offline/online events (web only)
    html.window.onOffline.listen((_) {
      _handleConnectionLost();
      onError?.call('Internet connection lost');
    });
    html.window.onOnline.listen((_) {
      onError?.call('Internet connection restored');
    });

    try {
      // Determine WebSocket URL dynamically from current host (supports localhost or ngrok public URL)
      final host = html.window.location.host;  // e.g., 'localhost:8080' or 'abcd1234.ngrok-free.app'
      final scheme = html.window.location.protocol == 'https:' ? 'wss' : 'ws';
      final wsUrl = '$scheme://$host';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          onError?.call('Connection error: $error');
          Future.microtask(() => notifyListeners());
        },
        onDone: () {
          print('WebSocket connection closed');
          // Stop heartbeat timers
          _pingTimer?.cancel();
          _pongTimeoutTimer?.cancel();
          // Notify connection lost
          _handleConnectionLost();
        },
      );
      
      _isConnected = true;
      print('Connected to WebSocket server');
      
      // Start heartbeat ping
      _pingTimer = Timer.periodic(_pingInterval, (_) {
        if (_isConnected) {
          _sendMessage({'type': 'ping'});
          // Expect a pong within timeout
          _pongTimeoutTimer?.cancel();
          _pongTimeoutTimer = Timer(_pongTimeout, () {
            _handleConnectionLost();
          });
        }
      });

      // Auto-join global room
      _sendMessage({
        'type': 'joinGlobal',
        'playerName': playerName,
      });
      
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Failed to connect: $e');
      onError?.call('Failed to connect: $e');
    }
  }
  
  // Handle connection lost due to missing pong
  void _handleConnectionLost() {
    _isConnected = false;
    onError?.call('Connection lost: no response from server');
    notifyListeners();
  }

  // Disconnect from server
  void disconnect() {
    // Stop heartbeat timers
    _pingTimer?.cancel();
    _pongTimeoutTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _playerId = null;
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
        case 'joinedGlobal':
          _playerId = data['playerId'];
          print('Successfully joined global room as ${_playerId}');
          onJoinedGlobal?.call();
          break;
          
        case 'gameState':
          _serverGameState = data['gameState'];
          _players = List<Map<String, dynamic>>.from(data['players'] ?? []);
          
          // If we don't have a playerId yet, try to find ourselves in the players list
          if (_playerId == null && _players.isNotEmpty) {
            // Find our player based on the most recent connection (last in list)
            final lastPlayer = _players.last;
            _playerId = lastPlayer['id'];
            print('Auto-detected player ID: ${_playerId}');
            // Trigger the join callback since we've successfully joined
            onJoinedGlobal?.call();
          }
          
          final phase = _serverGameState?['phase'];
          final round = _serverGameState?['roundNumber'] ?? 0;
          final timeLeft = _serverGameState?['bettingTimeLeft'] ?? 0;
          print('DEBUG: Game state - Phase: $phase, Round: $round, Time: ${timeLeft}s, Players: ${_players.length}');
          
          onGameStateUpdate?.call(_serverGameState!, _players);
          break;
          
        case 'pong':
          // Received heartbeat response
          _pongTimeoutTimer?.cancel();
          break;
          
        case 'error':
          print('Server error: ${data['message']}');
          onError?.call(data['message']);
          break;
          
        default:
          print('Unknown message type: ${data['type']}');
      }
      
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Error parsing message: $e');
    }
  }
  
  // Place a bet
  void placeBet(String side, int amount) {
    if (_playerId != null && _isConnected) {
      print('DEBUG: Placing bet - Side: $side, Amount: ₹$amount');
      _sendMessage({
        'type': 'placeBet',
        'side': side,
        'amount': amount,
      });
    }
  }
} 