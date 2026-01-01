import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import 'select_counselor.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

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
          const SizedBox(height: 20),

          // 2. 일시 정보 (함수 호출 결과값을 넣기 좋게 라벨과 데이터 분리)
          Column(
            children: [
              _buildDateRow("12.30(화) ", "오후 1시 01분"),
            ],
          ),
          const SizedBox(height: 20),

          // 3. 현재 상담원 정보 박스
          _buildInfoCard(
            context,
            gradient: AppColors.gradTextboxGreen,
            data: {
              "현재": "오전 9시 - 오후 1시",
              "상담원": "홍길동 님",
            },
          ),
          const SizedBox(height: 15),

          // 4. 다음 상담원 정보 박스
          _buildInfoCard(
            context,
            gradient: AppColors.gradBtnGray,
            data: {
              "다음": "오후 1시 - 오후 5시",
              "상담원": "임꺽정 님",
            },
          ),
          const SizedBox(height: 25),

          // 5. 버튼 섹션 수정
          _buildActionButton(context, "다른 상담원 선택", AppColors.gradBtnBlue, () {
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
    );
  }

  // --- 도움 위젯들 ---

  // 일시 정보 Row: 라벨과 값을 쪼개서 구성
  Widget _buildDateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$label: ", style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 정보 카드 위젯: Map 자료구조를 사용하여 라벨과 데이터를 분리
  Widget _buildInfoCard(BuildContext context, {required Gradient gradient, required Map<String, String> data}) {
    return Container(
      width: AppSizes.wPercent(context, AppSizes.wMainButton),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // 라벨 영역 (고정폭을 주면 콜론(:) 위치가 세로로 정렬되어 더 깔끔합니다)
              Text("${entry.key}: ", style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)),
              // 실제 데이터 값 영역
              Expanded(
                child: Text(entry.value, style: const TextStyle(fontSize: AppSizes.fontBig, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // 기존 버튼 스타일
  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        decoration: ShapeDecoration(gradient: gradient, shape: const StadiumBorder(), shadows: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 4))]),
        child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold))),
      ),
    );
  }
}