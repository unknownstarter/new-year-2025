import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;
import 'package:intl/intl.dart';
import 'package:new_year_2025/core/models/user.dart';

class FortuneService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static String get _apiKey {
    final key = js.context['env']?['OPENAI_API_KEY'];
    if (key == null) {
      throw Exception('OPENAI_API_KEY not found in environment');
    }
    return key as String;
  }

  Future<Map<String, dynamic>> getFortune(User user) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''당신은 2025년의 운세를 보는 점성술사입니다. 
다음 형식으로 운세를 알려주세요:

🌟 2025년 전체 운세
(전반적인 2025년의 운세를 요약해서 알려주세요)

💝 사랑운
(2025년의 연애/결혼 운을 알려주세요)

💰 금전운
(2025년의 재물/투자/복권 운을 알려주세요)

💪 건강운
(2025년의 건강 관련 운을 알려주세요)

💼 직장운
(2025년의 직장/사업/승진 운을 알려주세요)

📅 분기별 운세
🌱 1~3월: (1분기 운세)
🌞 4~6월: (2분기 운세)
🍁 7~9월: (3분기 운세)
❄️ 10~12월: (4분기 운세)

각 섹션은 반드시 2025년의 운세만 다뤄주세요.'''
            },
            {
              'role': 'user',
              'content':
                  '이름: ${user.name}\n성별: ${user.gender}\n생년월일: ${DateFormat('yyyy-MM-dd').format(user.birthDateTime)}'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];

        return {
          'overall': content.split('\n\n')[0],
          'love': content.split('\n\n')[1],
          'money': content.split('\n\n')[2],
          'health': content.split('\n\n')[3],
          'career': content.split('\n\n')[4],
          'quarterly': content.split('\n\n')[5],
        };
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to get fortune: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting fortune: $e');
      rethrow;
    }
  }
}
