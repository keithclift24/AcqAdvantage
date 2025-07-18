import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import 'briefing_card_bubble.dart'; // Import the new widget

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Check the message type to decide which widget to render
    if (message.messageType == MessageType.briefingCard &&
        message.structuredData != null) {
      // If it's a briefing card with data, show our new widget
      return BriefingCardBubble(data: message.structuredData!);
    }

    // --- Otherwise, show the original text bubble ---
    final isUserMessage = message.isFromUser;
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
              isUserMessage ? const Color(0xFF00B5D8) : const Color(0xFF2D3748),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isUserMessage ? 16.0 : 0),
            bottomRight: Radius.circular(isUserMessage ? 0 : 16.0),
          ),
        ),
        child: isUserMessage
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(p: const TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
