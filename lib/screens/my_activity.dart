import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';
import '../core/models/user_model.dart';
import '../core/network/api_service.dart';
import 'package:intl/intl.dart'; //

class MyActivity extends StatefulWidget {
  final UserModel? user;
  const MyActivity({super.key, this.user});

  @override
  State<MyActivity> createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  // 서버에서 받아올 데이터 변수
  List<dynamic> _historyList = [];
  String _totalHours = "0";
  String _historyCount = "0";

  @override
  void initState() {
    super.initState();
    _fetchActivityData();
  }

  Future<void> _fetchActivityData() async {
    if (widget.user == null) {
      print("에러: 유저 정보가 없습니다.");
      if (mounted) {
        setState(() {
          _isLoading = false; // 정보가 없어도 일단 로딩 바는 멈춰야 함
        });
      }
      return;
    }

    try {
      print("데이터 로딩 시작: ID ${widget.user!.accountId}");
      final data = await _apiService.getMyActivities(widget.user!.accountId);
      print("서버 응답 데이터: $data"); // 이 로그가 찍히는지 확인

      if (mounted) {
        setState(() {
          if (data != null) {
            _totalHours = data['totalHours']?.toString() ?? "0";
            _historyCount = data['historyCount']?.toString() ?? "0";
            _historyList = data['history'] ?? [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("데이터 로드 에러: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 활동 기간 계산 함수 (MyPage와 동일 로직)
  String _getActivityPeriod() {
    if (widget.user == null) return "-";
    final fromDate = widget.user!.registeredAt;
    final now = DateTime.now();
    return "${fromDate.year}.${fromDate.month.toString().padLeft(2, '0')} - ${now.year}.${now.month.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.mainBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          AppAssets.logoImg,
                          width: AppSizes.wPercent(context, AppSizes.wImage),
                          height: AppSizes.hPercent(context, AppSizes.hImage),
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "${widget.user?.accountName ?? '상담원'} 님",
                          style: TextStyle(fontSize: AppSizes.fontBiggest, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "상담 활동 상세 이력입니다.",
                          style: TextStyle(fontSize: AppSizes.fontBig, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 30),

                        _buildSummarySection(),
                        const SizedBox(height: 30),

                        // 데이터가 없을 때 처리
                        if (_historyList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text("상세 활동 내역이 없습니다."),
                          ),

                        // 실제 DB 데이터 리스트 렌더링
                        ..._historyList.map((data) => _buildActivityCard(context, data)).toList(),

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

  // ... (상단 바 _buildTopBar 생략 - 기존 코드와 동일)

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _buildInfoRow("활동 기간:", _getActivityPeriod()),
          _buildInfoRow("상담 횟수:", "$_historyCount 회"),
          _buildInfoRow("상담 시간:", "$_totalHours 시간"),
        ],
      ),
    );
  }

  // 카드 위젯: DB 필드명(start_time, end_time 등)에 맞춰 수정
  Widget _buildActivityCard(BuildContext context, dynamic data) {
    // 날짜 포맷팅 함수
    String formatDateTime(dynamic date) {
      if (date == null) return "-";
      try {
        DateTime dt = date is String ? DateTime.parse(date) : date;
        return DateFormat('yyyy.MM.dd HH:mm').format(dt.toLocal());
      } catch (e) { return "-"; }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: HighlightButton(
        onTap: () {},
        defaultGradient: AppColors.gradBtnGray,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusCard)),
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBigCard),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 백엔드 필드명 'start', 'end', 'duration'에 맞춤
              _buildCardRow("시작:", formatDateTime(data['start'])),
              const SizedBox(height: 6),
              _buildCardRow("종료:", formatDateTime(data['end'])),
              const SizedBox(height: 6),
              _buildCardRow("시간:", data['duration']?.toString() ?? "-"),
            ],
          ),
        ),
      ),
    );
  }

// _buildInfoRow, _buildCardRow 등 헬퍼 위젯은 기존 코드 유지
  // [오류 해결] 상단 바 및 [뒤로] 버튼 정의
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: HighlightButton(
        onTap: () => Navigator.pop(context),
        defaultGradient: AppColors.gradBtnBlue,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
        shadows: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
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

  // 활동 요약 로우 (라벨 : 값)
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

  // 카드 내부 데이터 로우
  Widget _buildCardRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: AppSizes.fontMid, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: AppSizes.fontMid)),
        ),
      ],
    );
  }
}