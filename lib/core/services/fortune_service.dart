import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:new_year_2025/core/models/user.dart';

class FortuneService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static final String _apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  Future<Map<String, dynamic>> getFortune(User user) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''당신은 2025년 운세를 봐주는 점성술사입니다. 
                다음 JSON 형식으로만 운세를 알려주세요. 각 운세는 3-4문장으로 자세하게 설명해주세요:
                {
                  "overall": "✨ 전체운: 구체적인 전체운 내용",
                  "love": "💝 사랑운: 구체적인 사랑운 내용",
                  "money": "💰 금전운: 구체적인 금전운 내용",
                  "health": "🏃 건강운: 구체적인 건강운 내용"
                }
                
                각 운세는 긍정적이고 희망적으로 작성해주세요.
                응답은 반드시 UTF-8 인코딩으로 해주세요.
                ''',
            },
            {
              'role': 'user',
              'content': '이름: ${user.name}\n'
                  '성별: ${user.gender}\n'
                  '생년월일시: ${DateFormat('yyyy년 MM월 dd일 HH시').format(user.birthDateTime)}\n'
                  '2025년 운세를 봐주세요.',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        try {
          final result = jsonDecode(content) as Map<String, dynamic>;
          return result;
        } catch (e) {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get fortune: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
