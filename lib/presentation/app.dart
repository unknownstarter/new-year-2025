import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_year_2025/presentation/screens/landing_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2025 새해 운세',
      builder: (context, child) {
        // 모바일 사이즈로 고정 (최대 너비 428px)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 428),
              child: child!,
            ),
          ),
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4B6BFF),
          secondary: Colors.white,
          surface: const Color(0xFF1A1A1A),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.notoSansKrTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.notoSansKr(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.notoSansKr(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
