import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';
import '../core/network/api_service.dart';
import '../core/models/user_model.dart';

class AdminScreen extends StatelessWidget {
  // 2. user 변수 추가 및 생성자 수정
  final UserModel? user;
  const AdminScreen({super.key, this.user}); // {super.key} 뒤에 this.user 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 배경 투명 처리
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // 1. 로고 (MyPage와 크기/배치 통일)
              Image.asset(
                AppAssets.logoImg,
                width: AppSizes.wPercent(context, AppSizes.wImage),
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // 2. 운영자 모드 켜기 설명 (검정색, fontMid 적용)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "현재 상담자 및 다음 상담자 착신번호를\n운영자의 전화번호로 지정합니다.\n운영자만 클릭할 수 있습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontMid,
                    color: Colors.black, // 주황색에서 검정색으로 변경
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. 운영자 모드 켜기 버튼 (gradBtnRed 적용)
              _buildActionButton(
                  context,
                  "운영자 모드 켜기",
                  AppColors.gradBtnRed,
                      () => print("운영자 모드 켜기 클릭")
              ),
              const SizedBox(height: 40),

              // 4. 운영자 모드 해제 설명 (fontMid 적용)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "주간 시간표로부터, 현재 시간을 기준으로\n 현재 및 다음 상담원을 찾아 배정합니다.\n운영자 모드가 켜져 있는 상태일 때만\n상담원 누구나 클릭할 수 있습니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontMid,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. 운영자 모드 해제 버튼 (MyPage와 동일한 gradBtnBlue 적용)
              _buildActionButton(
                  context,
                  "운영자 모드 해제",
                  AppColors.gradBtnBlue,
                      () => print("운영자 모드 해제 클릭")
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // MyPage의 버튼 스타일과 100% 동일한 버튼 빌더
  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback onPressed) {
    return HighlightButton(
      onTap: onPressed,
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
      // 기존에 사용하던 그림자 효과 복구
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
        // 여기에 Container 자체 decoration을 넣으면 중복되어 에러가 날 수 있으니 비워둡니다.
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
}