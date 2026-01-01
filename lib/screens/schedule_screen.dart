import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (하이라이트 포함)
    final List<Map<String, dynamic>> weeklySchedule = [
      {
        "day": "Monday",
        "slots": [
          {"time": "9AM - 1PM", "name": "홍길동", "isCurrent": true},
          {"time": "1PM - 5PM", "name": "임꺽정", "isCurrent": false},
          {"time": "5PM - 9PM", "name": "이몽룡", "isCurrent": false},
          {"time": "9PM - 9AM", "name": "성춘향", "isCurrent": false},
        ]
      },
      {
        "day": "Saturday",
        "slots": [
          {"time": "9AM - 1PM", "name": "홍길동", "isCurrent": true},
          {"time": "1PM - 5PM", "name": "임꺽정", "isCurrent": false},
          {"time": "5PM - 9PM", "name": "이몽룡", "isCurrent": false},
          {"time": "9PM - 9AM", "name": "성춘향", "isCurrent": false},
        ]
      },

      // ... 나머지 요일 데이터
    ];

    return Scaffold(
      // 1. Scaffold 자체 배경을 투명하게 설정하여 기저의 배경이미지가 보이게 함
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            // 2. 내부 컨테이너 배경색 제거 (투명 유지)
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // 로고
                Image.asset(
                  AppAssets.logoImg,
                  width: AppSizes.wPercent(context, AppSizes.wImage),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // 업데이트 정보 및 감사 문구
                Text("Update: 2025.08",
                    style: TextStyle(fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                Text(
                  "모든 생명의 전화 상담자 선생님들의\n봉사와 희생에 언제나 감사드립니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppSizes.fontMid, color: Colors.black, height: 1.4),
                ),
                const SizedBox(height: 30),

                // 요일별 섹션 빌드
                ...weeklySchedule.map((dayData) => _buildDaySection(context, dayData)).toList(),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 요일 섹션 빌더 (기존의 해결된 width 로직 유지)
  Widget _buildDaySection(BuildContext context, Map<String, dynamic> dayData) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: AppColors.gradBtnGray,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          ),
          child: Center(
            child: Text(dayData["day"],
                style: const TextStyle(fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),

        ...dayData["slots"].map<Widget>((slot) {
          bool isCurrent = slot["isCurrent"] ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildScheduleBox(
                      context,
                      slot["time"],
                      isCurrent ? AppColors.gradTextboxGreen : AppColors.gradBtnGray
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildScheduleBox(
                      context,
                      slot["name"],
                      isCurrent ? AppColors.gradTextboxGreen : AppColors.gradBtnGray
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 25),
      ],
    );
  }

  // 텍스트 박스 위젯
  Widget _buildScheduleBox(BuildContext context, String text, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: AppSizes.fontBig, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}