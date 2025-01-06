import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_year_2025/core/models/chat_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.type == 'link') {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () async {
            await FirebaseAnalytics.instance.logEvent(
              name: 'feedback_link_click',
            );

            final url = Uri.parse(message.text);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            '피드백 남기기',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('텍스트가 복사되었습니다'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: EdgeInsets.only(
            left: message.isUser ? 64 : 0,
            right: message.isUser ? 0 : 64,
          ),
          decoration: BoxDecoration(
            color: message.isUser
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
