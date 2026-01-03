import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';
import '../core/network/api_service.dart';
import '../core/models/user_model.dart';

class AdminScreen extends StatefulWidget {
  final UserModel? user;
  const AdminScreen({super.key, this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isAdminModeActive = false; // 현재 서버의 운영자 모드 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentStatus();
  }

  // 현재 운영자 모드 상태를 서버에서 가져옴
  Future<void> _fetchCurrentStatus() async {
    final status = await _apiService.getHandoverStatus();
    if (status != null && mounted) {
      setState(() {
        _isAdminModeActive = status['isAdminMode'] ?? false;
      });
    }
  }

  // 모드 전환 함수
  Future<void> _handleToggleMode(bool targetOn) async {
    // 1. 유저 ID가 있는지 먼저 체크 (방어 코드)
    final String? userId = widget.user?.accountId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. apiService에 targetOn(상태)과 userId(내 ID)를 함께 전달
    final success = await _apiService.toggleAdminMode(targetOn, userId);

    if (success) {
      setState(() => _isAdminModeActive = targetOn);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(targetOn
                ? "운영자 점거 모드가 활성화되었습니다."
                : "운영자 모드가 해제되고 시간표가 복구되었습니다.")
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("요청 처리에 실패했습니다. 권한을 확인하세요.")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 로직 1: 빨간 버튼은 운영자(isChief)만 활성화
    bool canEnableAdmin = widget.user?.isChief ?? false;

    // 로직 2 & 3: 파란 버튼 활성화 조건
    // - 현재 운영자 모드인 경우: 누구나 클릭 가능
    // - 현재 운영자 모드가 아닌 경우: 운영자(isChief)만 클릭 가능
    bool canDisableAdmin = _isAdminModeActive ;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
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
                  const SizedBox(height: 30),

                  // 운영자 모드 켜기 섹션
                  _buildDescription("현재 상담자 및 다음 상담자 착신번호를\n운영자의 전화번호로 지정합니다.\n운영자만 클릭할 수 있습니다."),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    "운영자 모드 켜기",
                    canEnableAdmin && !_isAdminModeActive ? AppColors.gradBtnRed : AppColors.gradBtnGray, // 비활성시 회색
                        () => _handleToggleMode(true),
                    isEnabled: canEnableAdmin && !_isAdminModeActive,
                  ),

                  const SizedBox(height: 40),

                  // 운영자 모드 해제 섹션
                  _buildDescription("주간 시간표로부터, 현재 시간을 기준으로\n 현재 및 다음 상담원을 찾아 배정합니다.\n운영자 모드가 켜져 있는 상태일 때만\n상담원 누구나 클릭할 수 있습니다."),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    "운영자 모드 해제",
                    canDisableAdmin ? AppColors.gradBtnBlue : AppColors.gradBtnGray,
                        () => _handleToggleMode(false),
                    isEnabled: canDisableAdmin,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: AppSizes.fontMid,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback onPressed, {bool isEnabled = true}) {
    return HighlightButton(
      onTap: isEnabled ? onPressed : () {}, // 비활성화 시 작동 안함
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
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
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white60,
            fontSize: AppSizes.fontMainButton,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}