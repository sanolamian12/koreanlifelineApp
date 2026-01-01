import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import 'select_counselor.dart';

class UrgentScreen extends StatelessWidget {
  const UrgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity, // 부모 컨테이너가 가로 전체를 차지하게 함
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 모든 요소를 가로축 중앙 정렬
          children: [
            const SizedBox(height: 10),

            // 1. 로고
            Image.asset(
              AppAssets.logoImg,
              width: AppSizes.wPercent(context, AppSizes.wImage),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // 2. 상단 설명 문구 (중앙 정렬 보장)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "현재 상담원을 즉시 변경합니다.",
                  style: TextStyle(
                    fontSize: AppSizes.fontMainButton,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. 현재 상담원 정보 박스 (Red)
            _buildInfoCard(
              context,
              gradient: AppColors.gradTextboxRed,
              data: {
                "현재 차수": "오후 1시 - 오후 5시",
                "현재 상담원": "홍길동 님",
                "전화 번호": "0422 123 132",
              },
            ),
            const SizedBox(height: 15),

            // 4. 변경될 상담원 정보 박스 (Green)
            _buildInfoCard(
              context,
              gradient: AppColors.gradTextboxGreen,
              data: {
                "현재 차수": "오후 1시 - 오후 5시",
                "현재 상담원": "임꺽정 님",
                "전화 번호": "0422 663 534",
              },
            ),
            const SizedBox(height: 25),

            // 5. 버튼 섹션
            _buildActionButton(context, "상담원 선택", AppColors.gradBtnBlue, () {
              // Navigator를 통해 상담원 선택 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SelectCounselor()),
              );
            }),
            const SizedBox(height: 20),
            _buildActionButton(context, "착신 전환", AppColors.gradBtnGreen, () {}),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 중앙 정렬이 적용된 정보 카드 위젯 ---
  Widget _buildInfoCard(BuildContext context, {required Gradient gradient, required Map<String, String> data}) {
    return Container(
      width: AppSizes.wPercent(context, AppSizes.wMainButton),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: data.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            // 라벨과 데이터 사이의 간격을 일정하게 유지하면서 배치
            children: [
              Text(
                  "${entry.key}: ",
                  style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)
              ),
              Expanded(
                child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // --- 버튼 위젯 (배치 유지) ---
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
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}