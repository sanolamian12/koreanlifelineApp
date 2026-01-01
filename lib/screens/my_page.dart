import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
// MyActivity 클래스가 정의된 파일을 import 하세요.
import 'my_activity.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 1. 로고
          Image.asset(
            AppAssets.logoImg,
            width: AppSizes.wPercent(context, AppSizes.wImage),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 30),

          // 2. 사용자 정보
          Text(
            "홍길동 님",
            style: TextStyle(
              fontSize: AppSizes.fontBiggest,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "0432 123 456",
            style: TextStyle(
              fontSize: AppSizes.fontBiggest,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // 3. 내 번호 업데이트 버튼
          _buildActionButton(context, "내 번호 업데이트", AppColors.gradBtnBlue, () {
            print("내 번호 업데이트 클릭");
          }),
          const SizedBox(height: 30),

          // 4. 활동 정보 요약
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("활동 기간:", "2020.01 - 2025.12"),
                _buildInfoRow("상담 횟수:", "30회"),
                _buildInfoRow("상담 시간:", "99시간"),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 5. 내 활동 상세보기 버튼 (클릭 시 화면 이동 로직 추가)
          _buildActionButton(context, "내 활동 상세보기", AppColors.gradBtnBlue, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyActivity()),
            );
          }),
          const SizedBox(height: 20),

          // 6. 로그아웃 버튼
          _buildActionButton(context, "로 그 아 웃", AppColors.gradBtnGreen, () {
            print("로그아웃 클릭");
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        decoration: ShapeDecoration(
          gradient: gradient,
          shape: const StadiumBorder(),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontMainButton,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontMid,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.fontMid,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}