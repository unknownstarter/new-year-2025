import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;
import 'package:intl/intl.dart';
import 'package:new_year_2025/core/models/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FortuneService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static String get _apiKey {
    final key = js.context['env']?['OPENAI_API_KEY'];
    if (key == null) {
      throw Exception('OPENAI_API_KEY not found in environment');
    }
    return key as String;
  }

  Future<Map<String, dynamic>> getFortune(User user) async {
    try {
      // 운세 요청 시작 이벤트 기록
      await _analytics.logEvent(
        name: 'fortune_request',
        parameters: {
          'user_name': user.name,
          'user_gender': user.gender,
          'user_birth_year': user.birthDateTime.year.toString(),
        },
      );

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
운세는 긍정적인 것과 부정적인 것을 모두 포함하여 현실적으로 작성해주세요.
각 운세는 주의할 점과 조언을 함께 포함해야 합니다.

다음 형식으로 운세를 알려주세요. 각 섹션은 반드시 구분자(===)로 구분해주세요:

🌟 2025년 전체 운세
(전반적인 2025년의 운세를 긍정적/부정적 요소를 모두 포함하여 요약)
===
💝 사랑운
(연애/결혼 운을 현실적으로 설명하고, 주의점과 조언 포함)
===
💰 금전운
(재물/투자/복권 운을 긍정적/부정적 요소를 포함하여 설명하고 위험 요소도 언급)
===
💪 건강운
(건강 관련 운을 솔직하게 설명하고 주의해야 할 점 포함)
===
💼 직장운
(직장/사업/승진 운을 현실적으로 설명하고 도전과 기회 모두 언급)
===
📅 분기별 운세
(각 분기별로 긍정적/부정적 요소를 모두 포함하여 설명)
🌱 1~3월: (1분기 운세)
🌞 4~6월: (2분기 운세)
🍁 7~9월: (3분기 운세)
❄️ 10~12월: (4분기 운세)'''
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
        // 운세 요청 성공 이벤트 기록
        await _analytics.logEvent(
          name: 'fortune_success',
          parameters: {
            'user_name': user.name,
          },
        );

        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];

        // === 구분자로 섹션을 나눔
        final sections = content.split('===').map((s) => s.trim()).toList();

        return {
          'overall': sections[0], // 전체 운세
          'love': sections[1], // 사랑운
          'money': sections[2], // 금전운
          'health': sections[3], // 건강운
          'career': sections[4], // 직장운
          'quarterly': sections[5], // 분기별 운세
        };
      } else {
        // 운세 요청 실패 이벤트 기록
        await _analytics.logEvent(
          name: 'fortune_error',
          parameters: {
            'error_code': response.statusCode.toString(),
            'error_body': response.body,
          },
        );

        print('Error response: ${response.body}');
        throw Exception('Failed to get fortune: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 발생 시 이벤트 기록
      await _analytics.logEvent(
        name: 'fortune_exception',
        parameters: {
          'error_message': e.toString(),
        },
      );
      rethrow;
    }
  }
}
