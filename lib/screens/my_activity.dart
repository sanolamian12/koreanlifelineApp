import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';

class MyActivity extends StatelessWidget {
  const MyActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> historyData = List.generate(
      6,
          (index) => {
        "start": "2025.12.01. 10:00",
        "end": "2025.12.01. 11:0${index + 1}",
        "duration": "1.${index + 1} 시간",
      },
    );

    return Scaffold(
      // 1. 전체 배경에 이미지 적용을 위해 Stack 사용
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.mainBackground), // 배경 이미지 소스 연동
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 [뒤로] 버튼 (고정 영역)
              _buildTopBar(context),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.transparent, // 스크롤 영역 투명 유지
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

                        Text(
                          "홍길동 님",
                          style: TextStyle(fontSize: AppSizes.fontBiggest, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "상담 활동 상세 이력입니다.",
                          style: TextStyle(fontSize: AppSizes.fontBig, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),

                        // 활동 요약 섹션
                        _buildSummarySection(),
                        const SizedBox(height: 30),

                        // 상세 이력 카드 리스트 (Overflow 해결 버전)
                        ...historyData.map((data) => _buildActivityCard(context, data)).toList(),

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

  // 상단 바 및 [뒤로] 버튼
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

  // 활동 요약 섹션
  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _buildInfoRow("활동 기간:", "2020.01 - 2025.12"),
          _buildInfoRow("상담 횟수:", "30 회"),
          _buildInfoRow("상담 시간:", "000 시간"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: AppSizes.fontMid, fontWeight: FontWeight.bold)),
          ),
          Text(value, style: const TextStyle(fontSize: AppSizes.fontMid)),
        ],
      ),
    );
  }

  // 상세 활동 카드 (Overflow 문제 수정)
  Widget _buildActivityCard(BuildContext context, Map<String, String> data) {
    // 1. HighlightButton 자체를 Padding으로 감싸서 아이템 간 간격을 확보합니다.
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), // 기존의 margin: 15 효과와 동일
      child: HighlightButton(
        onTap: () => print("${data["start"]} 기록 클릭됨"),
        defaultGradient: AppColors.gradBtnGray,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ],
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBigCard),
          constraints: BoxConstraints(
            minHeight: AppSizes.hPercent(context, AppSizes.hBigCard),
          ),
          // 2. 내부 Container의 margin은 제거합니다. (HighlightButton이 꽉 차게 함)
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardRow("시작:", data["start"]!),
              const SizedBox(height: 6),
              _buildCardRow("종료:", data["end"]!),
              const SizedBox(height: 6),
              _buildCardRow("시간:", data["duration"]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: AppSizes.fontMid, fontWeight: FontWeight.bold)),
        ),
        // 텍스트가 길어질 경우를 대비해 Expanded 처리
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: AppSizes.fontMid)),
        ),
      ],
    );
  }
}