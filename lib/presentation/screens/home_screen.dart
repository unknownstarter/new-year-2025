import 'package:flutter/material.dart';
import 'package:new_year_2025/presentation/widgets/banner_widget.dart';
import 'package:new_year_2025/presentation/widgets/chat_input_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_pattern.png'),
            opacity: 0.1,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: const [
              BannerWidget(),
              Expanded(child: ChatInputForm()),
            ],
          ),
        ),
      ),
    );
  }
}
