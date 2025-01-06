class ChatMessage {
  final String text;
  final bool isUser;
  final String? userInput;
  final bool needsValidation;
  final String type; // 'name', 'gender', 'birthDateTime'

  ChatMessage({
    required this.text,
    this.isUser = false,
    this.userInput,
    this.needsValidation = false,
    this.type = '',
  });
}
