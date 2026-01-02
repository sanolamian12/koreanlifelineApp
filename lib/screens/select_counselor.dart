import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import '../core/widgets/highlight_button.dart';
import '../core/network/api_service.dart';

class SelectCounselor extends StatefulWidget {
  const SelectCounselor({super.key});

  @override
  State<SelectCounselor> createState() => _SelectCounselorState();
}

class _SelectCounselorState extends State<SelectCounselor> {
  final ApiService _apiService = ApiService();
  List<dynamic> _counselors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  // DB에서 상담원 목록 로드
  Future<void> _loadCounselors() async {
    final list = await _apiService.getAllCounselors();
    setState(() {
      _counselors = list;
      _isLoading = false;
    });
  }

  // 상담원 선택 시 처리
  Future<void> _onSelect(Map<String, dynamic> counselor) async {
    final success = await _apiService.updateSelectedCounselor(counselor['account_id']);
    if (success && mounted) {
      // 성공 시 true를 가지고 이전 화면으로 복귀
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상담원 변경에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                  child: Padding(
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
                        // 서버에서 받아온 리스트 렌더링
                        ..._counselors.map((c) => _buildCounselorCard(context, c)).toList(),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: HighlightButton(
        // 수동으로 팝할 때는 리로드할 필요가 없으므로 null 또는 false 반환
        onTap: () => Navigator.pop(context, false),
        defaultGradient: AppColors.gradBtnBlue,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBackButton),
          height: AppSizes.hPercent(context, AppSizes.hBackButton),
          alignment: Alignment.center,
          child: const Text("뒤 로", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCounselorCard(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: HighlightButton(
        onTap: () => _onSelect(data), // 선택 로직 실행
        defaultGradient: AppColors.gradBtnGray,
        highlightGradient: AppColors.gradBtnClick,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusCard)),
        child: Container(
          width: AppSizes.wPercent(context, AppSizes.wBigCard),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          constraints: BoxConstraints(minHeight: AppSizes.hPercent(context, AppSizes.hBigCard)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data["account_name"]} 님",
                style: const TextStyle(fontSize: AppSizes.fontBig, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "${data["account_phone"]}",
                style: const TextStyle(fontSize: AppSizes.fontBig, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}