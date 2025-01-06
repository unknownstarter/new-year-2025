import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_year_2025/core/providers/fortune_provider.dart';
import 'package:new_year_2025/core/providers/user_provider.dart';
import 'package:new_year_2025/presentation/app.dart';
import 'package:new_year_2025/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FortuneProvider()),
      ],
      child: const App(),
    ),
  );
}
