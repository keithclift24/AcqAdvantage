import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_bubble.dart';

class CiteScreen extends StatefulWidget {
  const CiteScreen({super.key});

  @override
  State<CiteScreen> createState() => _CiteScreenState();
}

class _CiteScreenState extends State<CiteScreen> {
  final TextEditingController _textController = TextEditingController();

  // Listener for the text controller to update state
  void _onTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged); // Correctly add listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ChatProvider>(context, listen: false)
          .initializeChat(authProvider.currentUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A202C),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: chatProvider.scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    // --- FIX: Pass the onActionTapped parameter ---
                    return ChatMessageBubble(
                      message: message,
                      onActionTapped: (text) {
                        _sendMessage(context, text);
                      },
                    );
                  },
                ),
              ),
              if (chatProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('AcqAdvantage is typing...',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, color: Colors.grey, size: 16.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'For your security, do not submit sensitive information. This includes, but is not limited to: Personally Identifiable Information (PII), corporate proprietary data, trade secrets, or any government-classified or Controlled Unclassified Information (CUI).',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              _buildInputArea(context, chatProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context, ChatProvider chatProvider) {
    final bool isLoading = chatProvider.isLoading;

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF2D3748),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isLoading,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A202C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty && !isLoading) {
                    _sendMessage(context, text);
                  }
                },
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: isLoading || _textController.text.trim().isEmpty
                  ? null
                  : () => _sendMessage(context, _textController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    context
        .read<ChatProvider>()
        .sendMessage(text, authProvider.currentUser, authProvider);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged); // Correctly remove listener
    _textController.dispose();
    super.dispose();
  }
}
