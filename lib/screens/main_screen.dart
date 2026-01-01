import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';

// 페이지들 임포트
import 'my_page.dart';
import 'status_screen.dart';
import 'urgent_screen.dart';
import 'schedule_screen.dart';
import 'admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false; // 로그인 상태 중앙 관리
  int _selectedIndex = 0;   // 현재 선택된 탭 인덱스

  // 1. 단순하게 페이지들을 정의합니다. (인자 전달 없음)
  final List<Widget> _pages = [
    const MyPage(),
    const StatusScreen(),
    const UrgentScreen(),
    const ScheduleScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 공통 배경
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
              // 하단 내비게이션 바 (로그인 여부에 따라 동작이 달라짐)
              _buildBottomNavigationBar(context),
            ],
          ),
        ],
      ),
    );
  }

  // --- [복구 완료] 로그인 전 화면 콘텐츠 ---
  Widget _buildLoggedOutContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // 로고
          Image.asset(
              AppAssets.logoImg,
              width: AppSizes.wPercent(context, AppSizes.wImage),
              fit: BoxFit.contain
          ),
          const SizedBox(height: 40),

          // 대표번호
          Text(
              "대표번호\n02 9598 5900",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontBiggest, fontWeight: FontWeight.bold, height: 1.2)
          ),
          const SizedBox(height: 24),

          // 감사 인사
          Text(
              "생명의 전화 상담봉사\n노고에 감사드립니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontBig, color: Colors.black87)
          ),
          const SizedBox(height: 16),

          // 이용 문의 안내 (복구됨)
          Text(
              "상담자 지원을 원하시면\n이용 문의 주시기 바랍니다.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontMid, color: Colors.black54)
          ),
          const SizedBox(height: 50),

          // 이용 문의 버튼 (복구됨)
          _buildActionButton("이용 문의", AppColors.gradBtnBlue, () {
            print("이용 문의 클릭");
          }),
          const SizedBox(height: 20),

          // 로그인 버튼
          _buildActionButton("로그인", AppColors.gradBtnGreen, () {
            setState(() => _isLoggedIn = true);
          }),
          const SizedBox(height: 30),

          // 하단 카피라이트 (복구됨)
          _buildCopyright(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- 하단 내비게이션 바 (핵심 로직) ---
  Widget _buildBottomNavigationBar(BuildContext context) {
    final navItems = ["마이\n페이지", "상담\n현황", "긴급\n전환", "주간\n시간표", "운영자\n모드"];

    return Container(
      width: double.infinity,
      height: AppSizes.hNaviArea,
      color: AppColors.bodyNavi,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItems.length, (index) {
          bool isSelected = _selectedIndex == index && _isLoggedIn;

          return GestureDetector(
            // 로그인 상태일 때만 탭 전환이 가능 (Enable/Disable)
            onTap: _isLoggedIn ? () {
              setState(() => _selectedIndex = index);
            } : null,

            child: Opacity(
              // 로그인 안되어 있으면 버튼을 반투명하게 (Disable 시각화)
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
    );
  }

  // 공통 위젯들
  Widget _buildTopAppBar(BuildContext context) {
    return SizedBox(height: AppSizes.hBackButton + 16);
  }

  Widget _buildActionButton(String text, Gradient gradient, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        decoration: ShapeDecoration(gradient: gradient, shape: const StadiumBorder()),
        child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold))),
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