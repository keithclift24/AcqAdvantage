// An enum to identify the type of content in the message
enum MessageType { text, briefingCard }

class ChatMessage {
  String text;
  final bool isFromUser;
  // The type of this message, defaults to text
  final MessageType messageType;
  // A map to hold our structured JSON data
  final Map<String, dynamic>? structuredData;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    this.messageType = MessageType.text, // Default to plain text
    this.structuredData,
  });
}
