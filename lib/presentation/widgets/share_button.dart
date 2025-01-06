import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () async {
        // 공유 버튼 클릭 이벤트 기록
        await FirebaseAnalytics.instance.logEvent(
          name: 'share_button_click',
        );

        await Share.share(
          '2025년엔 어떤일이 기다릴까?!\nhttps://new-year-2025-7cdc8.web.app/',
        );
      },
    );
  }
}
