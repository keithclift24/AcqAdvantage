import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_message.dart';
import 'auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! How can I help you today?", isFromUser: false),
  ];
  bool _isLoading = false;
  String? _threadId;
  final ScrollController _scrollController = ScrollController();
  io.Socket? _socket;
  bool _isConnected = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  ScrollController get scrollController => _scrollController;

  void update(AuthProvider auth) {
    // This method is called when AuthProvider changes.
    // You can add logic here to react to auth changes if needed.
  }

  void _connectToSocket() {
    // Disconnect any existing socket
    _socket?.dispose();

    // Connect to your WebSocket server
    _socket = io.io('https://acqadvantage-api.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      debugPrint('Connected to WebSocket server');
      _isConnected = true;
    });
    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from WebSocket server');
      _isConnected = false;
    });

    // --- Listen for the final response from the server ---
    _socket!.on('assistant_response', (data) {
      _isLoading = false;
      final status = data['status'];

      if (status == 'completed') {
        final lastMessageIndex = _messages.length - 1;
        _messages[lastMessageIndex] = ChatMessage(
          text: 'Briefing Card received',
          isFromUser: false,
          messageType: MessageType.briefingCard,
          structuredData: data['response'],
        );
      } else {
        _messages.last.text = 'Error: ${data['error']}';
      }
      notifyListeners();
      _scrollToBottom();
    });
  }

  Future<void> initializeChat(BackendlessUser? user) async {
    if (user == null) return;
    final url = Uri.parse('https://acqadvantage-api.onrender.com/start_chat');
    final userToken = await Backendless.userService.getUserToken();
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'user-token': userToken!},
        body: json.encode({'objectId': user.getProperty('objectId')}),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _threadId = responseBody['thread_id'];
        _connectToSocket(); // Connect to WebSocket after getting thread ID
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }
  }

  Future<void> resetChat(BackendlessUser? user) async {
    if (user == null) return;

    final url = Uri.parse('https://acqadvantage-api.onrender.com/reset_thread');
    final userToken = await Backendless.userService.getUserToken();

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'user-token': userToken!,
        },
        body: json.encode({'objectId': user.getProperty('objectId')}),
      );
    } catch (e) {
      debugPrint('Error resetting chat: $e');
    }

    _messages.clear();
    _messages.add(ChatMessage(
        text: "Hello! How can I help you today?", isFromUser: false));
    await initializeChat(user);
    notifyListeners();
  }

  Future<void> sendMessage(
      String text, BackendlessUser? user, AuthProvider authProvider) async {
    if (user == null || _threadId == null || _socket == null || !_isConnected) {
      _messages.add(ChatMessage(
          text: "Error: Not connected to the server. Please restart the app.",
          isFromUser: false));
      notifyListeners();
      return;
    }

    _messages.add(ChatMessage(text: text, isFromUser: true));
    _isLoading = true;
    notifyListeners();
    _scrollToBottom();

    _messages.add(ChatMessage(text: '...', isFromUser: false)); // Placeholder
    notifyListeners();
    _scrollToBottom();

    // --- Send message via WebSocket instead of HTTP ---
    _socket!.emit('send_message', {
      'prompt': text,
      'thread_id': _threadId,
      'objectId': user.getProperty('objectId'),
      // You may need to pass the user-token if your backend socket handler requires it
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _socket?.dispose(); // Important: clean up the socket connection
    _scrollController.dispose();
    super.dispose();
  }
}
