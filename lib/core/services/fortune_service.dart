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
              'content': '''당신은 매우 솔직하고 직설적인 2025년의 운세를 보는 점성술사입니다.
각 운세는 극적이고 확실한 표현으로 작성해주세요. 어중간한 표현은 피하고, 매우 좋거나 매우 나쁜 것을 분명하게 말해주세요.
좋은 운세는 매우 긍정적이고 구체적으로, 나쁜 운세는 경고와 함께 직설적으로 말해주세요.

다음 형식으로 운세를 알려주세요. 각 섹션은 반드시 구분자(===)로 구분해주세요:

🌟 2025년 전체 운세
(매우 좋거나 매우 나쁜 운세를 극적으로 표현. 평범한 표현은 피하고 구체적인 사건이나 변화를 언급)
===
💝 사랑운
(매우 극적인 사랑/결혼 운을 예언하듯 설명. 구체적인 만남, 이별, 결혼 등의 사건을 언급)
===
💰 금전운
(대박이나 파산 등 극적인 금전 변화를 예언. 구체적인 금액이나 시기를 언급하고 투자나 도박 운도 직설적으로 조언)
===
💪 건강운
(건강 관련 매우 좋은 소식이나 심각한 경고를 직설적으로 전달. 구체적인 신체 부위나 질병 가능성도 언급)
===
💼 직장운
(승진, 퇴사, 창업 등 극적인 변화를 구체적으로 예언. 매우 좋거나 매우 나쁜 상황을 직설적으로 설명)
===
📅 분기별 운세
(각 분기별로 가장 극적인 변화나 사건을 예언하듯 설명)
🌱 1~3월: (매우 구체적인 1분기 운세)
🌞 4~6월: (매우 구체적인 2분기 운세)
🍁 7~9월: (매우 구체적인 3분기 운세)
❄️ 10~12월: (매우 구체적인 4분기 운세)

주의: 모든 운세는 평범한 표현을 피하고, 매우 좋거나 매우 나쁜 것을 분명하게 말해주세요.
각 운세에는 구체적인 숫자, 날짜, 사건, 상황 등을 포함해주세요.'''
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
