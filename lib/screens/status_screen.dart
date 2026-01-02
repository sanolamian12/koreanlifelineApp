import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import 'select_counselor.dart'; // 수정했던 SelectCounselor
import '../core/widgets/highlight_button.dart';
import '../core/models/user_model.dart';
import '../core/network/api_service.dart';

class StatusScreen extends StatefulWidget {
  final UserModel? user;
  const StatusScreen({super.key, this.user});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _status;
  bool _isLoading = true;

  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
    _fetchInitialData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // DB에서 최신 상태 정보 가져오기 (리로드용)
  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = _status == null); // 처음 로딩시에만 인디케이터 표시
    final data = await _apiService.getHandoverStatus();
    if (mounted) {
      setState(() {
        _status = data;
        _isLoading = false;
      });
    }
  }

  // 착신 전환 처리
  Future<void> _handleHandover() async {
    final success = await _apiService.doHandover();
    if (success) {
      await _fetchInitialData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("착신 전환이 완료되었습니다.")),
        );
      }
    }
  }

  // 다른 상담원 선택 화면으로 이동 및 리로드 처리
  Future<void> _onSelectCounselorPressed() async {
    // Navigator.push가 완료될 때까지 await로 대기합니다.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectCounselor()),
    );

    // SelectCounselor에서 Navigator.pop(context, true)가 호출되어 넘어온 경우
    if (result == true) {
      print("상담원이 변경되었습니다. 데이터를 새로고침합니다.");
      await _fetchInitialData(); // DB에서 바뀐 selected_account 정보를 다시 가져옴
    }
  }

  String _getFormattedDate() => DateFormat('yyyy.MM.dd(E)', 'ko_KR').format(_now);
  String _getFormattedTime() => DateFormat('a h시 mm분', 'ko_KR').format(_now);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final bool isAuthorized = _status?['currentCounselor']?['isMe'] ?? false;
    final cur = _status?['currentCounselor'];
    final next = _status?['nextCounselor'];
    final selected = _status?['selectedCounselor'];

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(AppAssets.logoImg, width: AppSizes.wPercent(context, AppSizes.wImage)),
            const SizedBox(height: 20),

            _buildDateRow(_getFormattedDate(), _getFormattedTime()),
            const SizedBox(height: 20),

            // 2. 현재 상담원 박스
            _buildInfoCard(
              context,
              gradient: AppColors.gradTextboxGreen,
              data: {
                "현재": "${cur?['time'] ?? '시간 정보 없음'}",
                "상담원": "${cur?['name'] ?? '미지정'} 님",
                "번호": "${cur?['phone'] ?? '번호 없음'}",
              },
            ),
            const SizedBox(height: 15),

            // 3. 다음 상담원 박스 (타임은 next에서, 이름/번호는 selected가 있으면 최우선 반영)
            _buildInfoCard(
              context,
              gradient: AppColors.gradBtnGray,
              data: {
                // 누가 오든 타임은 고정 (원래 순번인 차기 상담원의 시간표 유지)
                "다음": "${next?['time'] ?? '시간 정보 없음'}",
                "상담원": "${selected?['name'] ?? next?['name'] ?? '미지정'} 님",
                "번호": "${selected?['phone'] ?? next?['phone'] ?? '번호 없음'}",
              },
            ),
            const SizedBox(height: 25),

            // 다른 상담원 선택 버튼
            _buildActionButton(
              context,
              "다른 상담원 선택",
              isAuthorized ? AppColors.gradBtnBlue : AppColors.gradBtnGray,
              isAuthorized ? _onSelectCounselorPressed : null, // 권한 있을 때만 활성화
            ),
            const SizedBox(height: 20),

            // 착신 전환 버튼
            _buildActionButton(
              context,
              "착신 전환",
              isAuthorized ? AppColors.gradBtnGreen : AppColors.gradBtnGray,
              isAuthorized ? _handleHandover : null, // 권한 있을 때만 활성화
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 기존 헬퍼 위젯들 (동일) ---
  Widget _buildDateRow(String date, String time) {
    TextStyle style = const TextStyle(fontSize: 22, color: Color(0xFFE67E22), fontWeight: FontWeight.bold);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("$date ", style: style), Text(time, style: style)]);
  }

  Widget _buildInfoCard(BuildContext context, {required Gradient gradient, required Map<String, String> data}) {
    return Container(
      width: AppSizes.wPercent(context, AppSizes.wMainButton),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppSizes.radiusCard)),
      child: Column(
        children: data.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 60, child: Text("${e.key}: ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback? onTap) {
    return HighlightButton(
      onTap: onTap,
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}