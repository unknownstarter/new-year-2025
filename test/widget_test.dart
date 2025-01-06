// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:new_year_2025/presentation/app.dart';
import 'package:new_year_2025/core/providers/fortune_provider.dart';
import 'package:new_year_2025/core/providers/user_provider.dart';

void main() {
  group('Fortune App Tests', () {
    testWidgets('Initial app test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => FortuneProvider()),
          ],
          child: const App(),
        ),
      );

      // 랜딩 페이지 테스트
      expect(find.text('2025년 새해 운세'), findsOneWidget);
      expect(find.text('운세 보기'), findsOneWidget);

      // 채팅 시작
      await tester.tap(find.text('운세 보기'));
      await tester.pumpAndSettle();

      // 채팅 입력 테스트
      await tester.enterText(find.byType(TextField), '홍길동');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('홍길동'), findsOneWidget);
    });
  });
}
