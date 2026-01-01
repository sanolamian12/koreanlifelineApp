import 'package:flutter/material.dart';
import 'package:korean_lifeline/screens/main_screen.dart'; // 패키지명은 환경에 맞게 유지

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korean Lifeline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4662FF)),
        useMaterial3: true,
      ),
      // MainScreen 생성자에서 showBackButton 인자를 제거했으므로 아래와 같이 호출합니다.
      home: const MainScreen(),
    );
  }
}