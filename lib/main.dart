import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'core/network/api_service.dart';
import 'core/models/user_model.dart';

void main() async {
  // 비동기 데이터 로딩을 위해 Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 기기에 저장된 로그인 정보 가져오기
  final prefs = await SharedPreferences.getInstance();
  final savedId = prefs.getString('saved_id');
  final savedPw = prefs.getString('saved_pw');

  bool initialLoggedIn = false;
  UserModel? initialUser;

  // 2. 저장된 정보가 있다면 자동 로그인 시도
  if (savedId != null && savedPw != null) {
    final apiService = ApiService();
    final user = await apiService.login(savedId, savedPw);

    if (user != null) {
      initialLoggedIn = true;
      initialUser = user;
    }
  }

  runApp(MyApp(
    isLoggedIn: initialLoggedIn,
    user: initialUser,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final UserModel? user;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.user
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korean Lifeline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4662FF)),
        useMaterial3: true,
      ),
      // [수정] MainScreen에 user 데이터를 함께 전달합니다.
      home: MainScreen(
        isLoggedIn: isLoggedIn,
        user: user, // <-- 이 부분이 추가되어야 합니다!
        initialIndex: 0, // 기본값 0 (MyPage)
      ),
    );
  }
}