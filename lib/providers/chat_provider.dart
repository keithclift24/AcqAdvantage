import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! How can I help you today?", isFromUser: false),
  ];
  bool _isLoading = false;
  String? _threadId;
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  ScrollController get scrollController => _scrollController;

  void update(AuthProvider auth) {
    // This method is called when AuthProvider changes.
    // You can add logic here to react to auth changes if needed.
  }

  Future<void> initializeChat(BackendlessUser? user) async {
    if (user == null) return;

    final url = Uri.parse('https://acqadvantage-api.onrender.com/start_chat');
    final userToken = await Backendless.userService.getUserToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'user-token': userToken!,
        },
        body: json.encode({'objectId': user.getProperty('objectId')}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _threadId = responseBody['thread_id'];
        debugPrint('Chat initialized with thread ID: $_threadId');
      } else {
        debugPrint('Failed to initialize chat: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
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
    if (user == null || _threadId == null) return;

    _messages.add(ChatMessage(text: text, isFromUser: true));
    _isLoading = true;
    notifyListeners();
    _scrollToBottom();

    // Add a placeholder for the assistant's response. We will update this object later.
    _messages.add(ChatMessage(text: '', isFromUser: false));
    notifyListeners();
    _scrollToBottom();

    final url = Uri.parse('https://acqadvantage-api.onrender.com/ask');
    final userToken = await Backendless.userService.getUserToken();
    final request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'user-token': userToken!,
      })
      ..body = json.encode({
        'prompt': text,
        'thread_id': _threadId,
        'objectId': user.getProperty('objectId'),
      });

    try {
      final streamedResponse = await request.send();

      // Use a StringBuffer to efficiently collect the chunks of the response
      final buffer = StringBuffer();

      streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
        buffer.write(chunk);
      }, onDone: () {
        _isLoading = false;
        try {
          // 1. Get the complete string from the buffer.
          final fullResponse = buffer.toString();

          // 2. IMPORTANT: Parse the string into a JSON Map.
          final Map<String, dynamic> jsonData = json.decode(fullResponse);

          // 3. Find the placeholder message we added earlier.
          final lastMessageIndex = _messages.length - 1;

          // 4. Replace the placeholder with a NEW ChatMessage that has the correct type and data.
          _messages[lastMessageIndex] = ChatMessage(
            text: 'Briefing Card received', // This text won't be displayed.
            isFromUser: false,
            messageType:
                MessageType.briefingCard, // <-- This tells the UI what to do.
            structuredData: jsonData, // <-- This passes the data to the widget.
          );
        } catch (e) {
          // This is a fallback if the response ISN'T valid JSON.
          _messages.last.text = buffer.toString().isNotEmpty
              ? buffer.toString()
              : 'Error: Failed to get a valid response.';
          debugPrint('JSON parsing failed: $e');
        }
        // 5. Update the UI.
        notifyListeners();
      }, onError: (error) {
        _isLoading = false;
        _messages.last.text = 'Error: $error';
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _messages.last.text = 'Error: $e';
      notifyListeners();
    }
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
}
