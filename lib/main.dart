import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/login_screen.dart';

void main() {
  runApp(const BayanSenseApp());
}

class BayanSenseApp extends StatelessWidget {
  const BayanSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BayanSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppTheme.paper,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.navy),
      ),
      home: const LoginScreen(),
    );
  }
}