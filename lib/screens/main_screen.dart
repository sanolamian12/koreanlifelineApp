import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // launchUrl 사용을 위해 추가
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';

// 추가된 임포트 (경로를 프로젝트 구조에 맞게 확인해주세요)
import '../core/constants/api_constants.dart';
import '../core/network/api_service.dart';
import '../core/models/user_model.dart';

// 페이지들 임포트
import 'my_page.dart';
import 'status_screen.dart';
import 'urgent_screen.dart';
import 'schedule_screen.dart';
import 'admin_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel? user; // 로그인 시 넘겨받은 유저 정보
  final bool isLoggedIn;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.user,
    this.isLoggedIn = false,
    this.initialIndex = 0
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _isLoggedIn;
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService(); // ApiService 인스턴스 추가

  late List<Widget> _pages; // 변수 선언만 해둡니다.

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _selectedIndex = widget.initialIndex;
    _initPages();
  }
  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 전달받은 user 정보가 바뀌었다면 페이지 리스트를 다시 생성
    if (widget.user != oldWidget.user) {
      _initPages();
    }
  }

    // 2. initState에서 widget.user를 각 페이지에 전달하며 초기화합니다.
  void _initPages() {
    _pages = [
      MyPage(user: widget.user),
      StatusScreen(user: widget.user),
      UrgentScreen(user: widget.user),    // <-- 수정됨: widget.user 추가
      ScheduleScreen(user: widget.user),  // <-- 향후 권한 체크를 위해 추가
      AdminScreen(user: widget.user),
    ];
  }

  // 2.1 이용 문의 클릭 시 노션 이동 (수정됨)
  Future<void> _launchContactUrl() async {
    final Uri url = Uri.parse(ApiConstants.contactUsUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // 2.2 로그인 성공 후 로직 (UserModel 인식됨)
  void _onLoginSuccess(UserModel newUser) {
    setState(() {
      _isLoggedIn = true;

      _pages = [
        MyPage(user: newUser),
        StatusScreen(user: newUser),
        UrgentScreen(user: newUser),    // <-- 수정됨: newUser 추가
        ScheduleScreen(user: newUser),  // <-- 추가
        const AdminScreen(),            // (AdminScreen 생성자에 user가 있다면 같이 추가해주세요)
      ];
      _selectedIndex = 0;
    });
  }

  // [추가] 로그인 팝업 다이얼로그 메서드
  void _showLoginDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController pwController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("상담원 로그인"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "아이디")
            ),
            TextField(
                controller: pwController,
                decoration: const InputDecoration(labelText: "비밀번호"),
                obscureText: true
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소")
          ),
          ElevatedButton(
            onPressed: () async {
              final user = await _apiService.login(idController.text, pwController.text);
              if (user != null) {
                Navigator.pop(context); // 팝업 닫기
                _onLoginSuccess(user);  // 성공 로직 실행
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("로그인 실패: 아이디 또는 비밀번호를 확인하세요."))
                );
              }
            },
            child: const Text("로그인"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.mainBackground, fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildTopAppBar(context),
                      Expanded(
                        child: _isLoggedIn
                            ? IndexedStack(index: _selectedIndex, children: _pages)
                            : _buildLoggedOutContent(),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child:_buildBottomNavigationBar(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Image.asset(
              AppAssets.logoImg,
              width: AppSizes.wPercent(context, AppSizes.wImage),
              fit: BoxFit.contain
          ),
          const SizedBox(height: 40),
          Text(
              "대표번호\n02 9598 5900",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontBiggest, fontWeight: FontWeight.bold, height: 1.2)
          ),
          const SizedBox(height: 24),
          Text(
              "생명의 전화 상담봉사\n노고에 감사드립니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontBig, color: Colors.black87)
          ),
          const SizedBox(height: 16),
          Text(
              "상담자 지원을 원하시면\n이용 문의 주시기 바랍니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontMid, color: Colors.black54)
          ),
          const SizedBox(height: 50),
          _buildActionButton("이용 문의", AppColors.gradBtnBlue, () {
            _launchContactUrl();
          }),
          const SizedBox(height: 20),
          _buildActionButton("로그인", AppColors.gradBtnGreen, () {
            _showLoginDialog();
          }),
          const SizedBox(height: 30),
          _buildCopyright(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final navItems = ["마이\n페이지", "상담\n현황", "긴급\n전환", "주간\n시간표", "운영자\n모드"];
    return Container(
      width: double.infinity,
      color: AppColors.bodyNavi,
      child: SafeArea(
        top: false,
        child: Container(
          height: AppSizes.hNaviArea,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              bool isSelected = _selectedIndex == index && _isLoggedIn;
              return GestureDetector(
                onTap: _isLoggedIn ? () {
                  setState(() => _selectedIndex = index);
                } : null,
                child: Opacity(
                  opacity: _isLoggedIn ? 1.0 : 0.4,
                  child: Container(
                    width: AppSizes.wPercent(context, AppSizes.wNaviButton),
                    height: AppSizes.hNaviButton,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.gradBtnBlue : AppColors.gradBtnNavi,
                      borderRadius: BorderRadius.circular(AppSizes.radiusNavi),
                    ),
                    child: Center(
                      child: Text(
                        navItems[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontSmall,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return SizedBox(height: AppSizes.hBackButton + 16);
  }

  Widget _buildActionButton(String text, Gradient gradient, VoidCallback onPressed) {
    return HighlightButton(
      onTap: onPressed,
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 4),
        )
      ],
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontMainButton,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      "koreanlifeline@gmail.com, 02 9622 1047\n0402 140 905\n5 South St. Rydalmere NSW 2116\nⓒ Copyright 2017. All Rights Reserved.",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color: Colors.grey[700],
          height: 1.5
      ),
    );
  }
}