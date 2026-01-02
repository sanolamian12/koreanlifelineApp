import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';

class SelectCounselor extends StatelessWidget {
  const SelectCounselor({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 상담원 데이터 리스트 (스크롤 확인용)
    final List<Map<String, String>> counselors = [
      {"name": "헬로우 님", "phone": "0432 123 421"},
      {"name": "홍길동 님", "phone": "0432 123 421"},
      {"name": "임꺽정 님", "phone": "0432 123 421"},
      {"name": "이몽룡 님", "phone": "0432 123 421"},
      {"name": "가나다 님", "phone": "0432 123 421"},
      {"name": "라마바 님", "phone": "0432 123 421"},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.mainBackground), // 배경 이미지 적용
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. 상단 고정 [뒤로] 버튼 (MyActivity와 통일)
              _buildTopBar(context),

              // 2. 스크롤 가능한 콘텐츠 영역
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // 로고 이미지
                        Image.asset(
                          AppAssets.logoImg,
                          width: AppSizes.wPercent(context, AppSizes.wImage),
                          height: AppSizes.hPercent(context, AppSizes.hImage),
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 25),

                        // 타이틀 및 설명 (MyActivity와 폰트 규격 통일)
                        Text(
                          "상담원을 교체합니다",
                          style: TextStyle(
                            fontSize: AppSizes.fontBiggest,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "목록에서 상담원을 선택해 주세요.",
                          style: TextStyle(
                            fontSize: AppSizes.fontBig,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 3. 상담원 카드 리스트
                        ...counselors.map((counselor) => _buildCounselorCard(context, counselor)).toList(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 바 및 [뒤로] 버튼 빌더 (MyActivity와 동일)
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: HighlightButton(
        onTap: () => Navigator.pop(context),
        defaultGradient: AppColors.gradBtnBlue,
        highlightGradient: AppColors.gradBtnClick, // 클릭 시 노란색
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
        shadows: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))
        ],
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBackButton),
          height: AppSizes.hPercent(context, AppSizes.hBackButton),
          alignment: Alignment.center,
          child: const Text(
            "뒤 로",
            style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontBig,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  // 상담원 선택 카드 빌더 (여백 및 하이라이트 최적화 버전)
  Widget _buildCounselorCard(BuildContext context, Map<String, String> data) {
    return Padding(
      // 1. 카드의 하단 여백을 위해 HighlightButton 자체를 Padding으로 감쌉니다.
      padding: const EdgeInsets.only(bottom: 15),
      child: HighlightButton(
        onTap: () => print("${data['name']} 선택됨"),
        defaultGradient: AppColors.gradBtnGray,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBigCard),
          // 2. 내부 Container의 margin은 제거하여 하이라이트가 카드 영역을 꽉 채우게 합니다.
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          constraints: BoxConstraints(
            minHeight: AppSizes.hPercent(context, AppSizes.hBigCard),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 첫 번째 줄: 성명
              Text(
                data["name"]!,
                style: const TextStyle(
                  fontSize: AppSizes.fontBig,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              // 두 번째 줄: 연락처
              Text(
                data["phone"]!,
                style: const TextStyle(
                  fontSize: AppSizes.fontBig,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}