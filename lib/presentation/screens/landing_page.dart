import 'package:flutter/material.dart';
import 'package:new_year_2025/presentation/screens/fortune_chat_page.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // 랜딩 페이지 진입 이벤트
    FirebaseAnalytics.instance.logEvent(
      name: 'view_landing_page',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // 2025 로고 애니메이션
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/fortune_animation.json',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '2025년 새해 운세',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '당신의 2025년 운세를\n AI 점성술사가 봐드립니다',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // 운세보기 버튼 클릭 이벤트
                    await FirebaseAnalytics.instance.logEvent(
                      name: 'click_fortune_button',
                    );

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FortuneChatPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '운세 보기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
