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
            {'role': 'system', 'content': '당신은 점성술사입니다. 사용자의 운세를 봐주세요.'},
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
