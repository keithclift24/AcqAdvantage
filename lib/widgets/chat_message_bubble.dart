import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import 'briefing_card_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  // --- FIX: Added the required callback parameter ---
  final Function(String) onActionTapped;

  const ChatMessageBubble({
    super.key,
    required this.message,
    // --- FIX: Make it required in the constructor ---
    required this.onActionTapped,
  });

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 720.0;

    if (message.messageType == MessageType.briefingCard &&
        message.structuredData != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          // --- FIX: Pass the callback down to the briefing card ---
          child: BriefingCardBubble(
            data: message.structuredData!,
            onActionTapped: onActionTapped,
          ),
        ),
      );
    }

    // --- The original text bubble ---
    final isUserMessage = message.isFromUser;
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUserMessage
                ? const Color(0xFF00B5D8)
                : const Color(0xFF2D3748),
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
      ),
    );
  }
}
