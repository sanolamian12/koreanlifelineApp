import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import 'select_counselor.dart';
import '../core/widgets/highlight_button.dart';
import '../core/network/api_service.dart';
import '../core/models/user_model.dart';

class UrgentScreen extends StatefulWidget {
  final UserModel? user;
  const UrgentScreen({super.key, this.user});

  @override
  State<UrgentScreen> createState() => _UrgentScreenState();
}

class _UrgentScreenState extends State<UrgentScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _currentData;
  Map<String, dynamic>? _tempSelectedCounselor;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // 1. 초기 데이터 로드: 화면 진입 시 항상 '현재 상담원' 정보로 상/하 박스 통일
  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getHandoverStatus();
      if (mounted && data != null) {
        setState(() {
          _currentData = data['currentCounselor'];
          // 가이드대로 진입 시에는 상단(현재)과 하단(변경될) 박스 정보를 동일하게 세팅 (Temp 개념)
          _tempSelectedCounselor = _currentData;

          // 권한 체크
          final bool isChief = widget.user?.isChief ?? false;
          final String? myId = widget.user?.accountId;
          final String? currentCounselorId = _currentData?['id'];
          _isAuthorized = isChief || (myId != null && myId == currentCounselorId);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // 2. 상담원 선택: 서버 통신 없이 Front에서 이름과 번호만 Temp로 교체
  Future<void> _onSelectCounselorPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectCounselor(isDirectUpdate: false)), // false 전달
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _tempSelectedCounselor = {
          'id': result['account_id'],
          'name': result['account_name'],
          'phone': result['account_phone'],
          'time': _currentData?['time'],
        };
      });
    }
  }

  // 3. 착신 전환: 2단계 연속 작업 (Patch -> Post)
  Future<void> _handleUrgentHandover() async {
    if (_tempSelectedCounselor == null || _currentData == null) return;

    // 만약 선택된 사람이 현재 사람과 같다면 실행 방지
    if (_tempSelectedCounselor!['id'] == _currentData!['id']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("현재 상담원과 동일합니다. 다른 분을 선택해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: 다음 대기자를 내가 고른 사람으로 업데이트 (PATCH)
      final patchSuccess = await _apiService.updateSelectedCounselor(_tempSelectedCounselor!['id']);

      if (patchSuccess) {
        // Step 2: 업데이트된 대기자를 현재 상담원으로 즉시 밀어넣기 (POST)
        final postSuccess = await _apiService.doHandover();

        if (postSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("상담원 착신 전환이 완료되었습니다.")),
          );
          // 완료 후 서버 정보를 다시 불러와 UI 갱신 (다시 상/하 박스 같아짐)
          await _fetchInitialData();
        }
      } else {
        throw Exception("상담원 예약 업데이트 실패");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("전환 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
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
              const Text(
                "현재 상담원을 즉시 변경합니다.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // 현재 상담원 (Red)
              _buildInfoCard(
                context,
                gradient: AppColors.gradTextboxRed,
                data: {
                  "현재": "${_currentData?['time'] ?? '정보 없음'}",
                  "상담원": "${_currentData?['name'] ?? '미지정'} 님",
                  "번호": "${_currentData?['phone'] ?? '번호 없음'}", // 추가됨
                },
              ),
              const SizedBox(height: 15),

              // 변경될 상담원 (Green)
              _buildInfoCard(
                context,
                gradient: AppColors.gradTextboxGreen,
                data: {
                  "변경": "${_tempSelectedCounselor?['time'] ?? '정보 없음'}",
                  "상담원": "${_tempSelectedCounselor?['name'] ?? '미지정'} 님",
                  "번호": "${_tempSelectedCounselor?['phone'] ?? '번호 없음'}",
                },
              ),
              const SizedBox(height: 25),

              // 버튼 섹션: 권한 없으면 null 전달하여 비활성화
              _buildActionButton(
                  context,
                  "상담원 선택",
                  _isAuthorized ? AppColors.gradBtnBlue : AppColors.gradBtnGray,
                  _isAuthorized ? _onSelectCounselorPressed : null
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                  context,
                  "착신 전환",
                  _isAuthorized ? AppColors.gradBtnGreen : AppColors.gradBtnGray,
                  _isAuthorized ? _handleUrgentHandover : null
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

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
            children: [
              Text("${entry.key}: ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback? onPressed) {
    return HighlightButton(
      onTap: onPressed,
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
      shadows: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 4))
      ],
      child: Container(
        width: AppSizes.wPercent(context, AppSizes.wMainButton),
        height: AppSizes.hMainButton,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}