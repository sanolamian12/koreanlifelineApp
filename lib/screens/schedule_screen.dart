import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/network/api_service.dart';
import '../core/models/user_model.dart';
import '../core/models/schedule_model.dart'; // 모델 임포트

String _updatedDateText = "Update: -";

class ScheduleScreen extends StatefulWidget {
  final UserModel? user;
  const ScheduleScreen({super.key, this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<ScheduleModel> _allSchedules = [];
  int? _currentOrderNo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 서버에서 데이터 가져오기
  Future<void> _loadData() async {
    try {
      // 세 가지 API를 병렬로 호출하여 효율성 극대화
      final results = await Future.wait([
        _apiService.getAllSchedules(),
        _apiService.getCurrentOrderNo(),
        _apiService.getLastUpdatedDate(), // 새로 추가한 날짜 API
      ]);

      setState(() {
        _allSchedules = results[0] as List<ScheduleModel>;
        _currentOrderNo = results[1] as int?;

        // 날짜 데이터 처리
        final DateTime? updatedDate = results[2] as DateTime?;
        if (updatedDate != null) {
          // 현지 시간 기준으로 포맷팅 (YYYY.MM.DD)
          _updatedDateText = "Update: ${updatedDate.year}.${updatedDate.month.toString().padLeft(2, '0')}.${updatedDate.day.toString().padLeft(2, '0')}";
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("데이터 로딩 에러: $e");
    }
  }

  // 요일별로 그룹화하는 헬퍼 함수
  Map<String, List<ScheduleModel>> _groupSchedulesByDay() {
    Map<String, List<ScheduleModel>> grouped = {};
    for (var schedule in _allSchedules) {
      grouped.putIfAbsent(schedule.day, () => []).add(schedule);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupSchedulesByDay();
    // 요일 순서 정렬을 원할 경우 리스트 생성
    final daysOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
            : RefreshIndicator( // 당겨서 새로고침 추가
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    AppAssets.logoImg,
                    width: AppSizes.wPercent(context, AppSizes.wImage),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(_updatedDateText,
                      style: TextStyle(fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 12),
                  const Text(
                    "모든 생명의 전화 상담자 선생님들의\n봉사와 희생에 언제나 감사드립니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AppSizes.fontMid, color: Colors.black, height: 1.4),
                  ),
                  const SizedBox(height: 30),

                  // 데이터 기반으로 화면 빌드
                  ...daysOrder.where((day) => groupedData.containsKey(day)).map((day) {
                    return _buildDaySection(context, day, groupedData[day]!);
                  }).toList(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, String day, List<ScheduleModel> slots) {
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
            child: Text(day, style: const TextStyle(fontSize: AppSizes.fontMainButton, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),
        ...slots.map((slot) {
          // 핵심: 서버에서 준 currentOrderNo와 슬롯의 order가 일치하는지 확인
          bool isCurrent = slot.order == _currentOrderNo;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildScheduleBox(
                      context,
                      slot.time,
                      isCurrent ? AppColors.gradTextboxGreen : AppColors.gradBtnGray // 하이라이트 적용
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildScheduleBox(
                      context,
                      slot.accountName,
                      isCurrent ? AppColors.gradTextboxGreen : AppColors.gradBtnGray // 하이라이트 적용
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