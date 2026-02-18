import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/constants/app_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/network/api_service.dart';
import 'main_screen.dart';
import 'my_activity.dart';
import '../core/widgets/highlight_button.dart';


class MyPage extends StatefulWidget {
  final UserModel? user;
  const MyPage({super.key, this.user});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ApiService _apiService = ApiService();
  String _totalHours = "0";
  String _historyCount = "0";
  String? _displayPhone; // 화면에 표시할 전화번호 (수정 즉시 반영용)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _displayPhone = widget.user?.phone; // 초기값 설정
    _fetchActivity();
  }
  @override
  void didUpdateWidget(MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // MainScreen에서 새 유저 정보를 주면, 마이페이지 내부 변수들도 갱신
    if (widget.user != oldWidget.user) {
      setState(() {
        _displayPhone = widget.user?.phone;
        // 필요한 다른 변수들도 여기서 업데이트
      });
    }
  }
  // 데이터 로딩 (통계 및 최신 정보)
  Future<void> _fetchActivity() async {
    if (widget.user == null) return;
    final data = await _apiService.getMyActivities(widget.user!.accountId);
    if (data != null && mounted) {
      setState(() {
        _totalHours = data['totalHours'].toString();
        _historyCount = data['historyCount'].toString();
        _isLoading = false;
      });
    }
  }
  // 활동 기간 계산 (From registeredAt - To Now)
  // String _getActivityPeriod() {
  //   if (widget.user == null) return "-";
  //   final fromDate = widget.user!.registeredAt; // 서버에서 받아온 가입일
  //   final now = DateTime.now();
  //   return "${fromDate.year}.${fromDate.month.toString().padLeft(2, '0')} - ${now.year}.${now.month.toString().padLeft(2, '0')}";
  // }
  // 전화번호 수정 다이얼로그
  void _showUpdatePhoneDialog() {
    // [수정] 화면에 표시된 +61 번호를 다이얼로그에서는 0으로 바꿔서 보여줌
    String initialText = _displayPhone ?? "";
    if (initialText.startsWith('+61')) {
      initialText = initialText.replaceFirst('+61', '0');
    }

    final TextEditingController _phoneController = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("전화번호 수정"),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "새로운 전화번호 입력",
            helperText: "예: 0412345678",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
            onPressed: () async {
              // [수정] 사용자가 입력한 0... 번호를 그대로 서버에 보냄 (서버에서 +61로 변환)
              final newPhone = _phoneController.text.trim();

              final serverFormattedPhone = await _apiService.updatePhoneNumber(
                  widget.user!.accountId,
                  newPhone
              );

              if (serverFormattedPhone != null && mounted) {
                setState(() {
                  // 서버가 저장 후 반환한 +61... 형태의 번호를 다시 화면 변수에 반영
                  _displayPhone = serverFormattedPhone;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("번호가 수정되었습니다."))
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("번호 수정에 실패했습니다."))
                );
              }
            },
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }

  // 로그아웃 로직 (SharedPreferences 삭제 및 메인 이동)
  Future<void> _logout() async {
    // ApiService 내부의 토큰 및 SharedPreferences 일괄 삭제
    await _apiService.clearLoginInfo();

    // 2. 만약 ApiService의 clearLoginInfo를 믿지 못하거나,
    // 다른 플러그인이 저장한 데이터까지 싹 지우고 싶다면 추가 (선택사항)
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    if (mounted) {
      // Navigator를 통해 이동할 때 UniqueKey를 가진 MainScreen을 새로 생성합니다.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(
              key: UniqueKey(), // <--- 핵심: 새로운 키를 부여하여 상태를 완전히 초기화
              isLoggedIn: false,
              user: null
          ),
        ),
            (route) => false,
      );
    }
  }

  // [수정 및 완성] 계정 삭제 요청 로직
  Future<void> _requestAccountDeletion() async {
    if (widget.user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("계정 삭제 요청", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "정말로 계정 삭제를 요청하시겠습니까?\n삭제된 계정 데이터는 복구가 불가능하며, 즉시 로그아웃됩니다.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. 서버에 삭제 요청 (Soft Delete API 호출)
              final bool isSuccess = await _apiService.withdraw(widget.user!.accountId);

              if (!mounted) return;

              if (isSuccess) {
                // 2. 다이얼로그 닫기
                Navigator.pop(context);

                // 3. 안내 메시지 출력
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("계정 삭제가 접수되어 로그아웃됩니다.")),
                );

                // 4. 즉시 로그아웃 실행 (저장된 정보 삭제 및 메인 초기화 이동)
                await _logout();
              } else {
                // 실패 시 안내
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("삭제 요청 실패. 관리자에게 문의해주세요.")),
                );
              }
            },
            child: const Text("삭제 및 로그아웃", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentName = widget.user?.accountName ?? "상담원";
    final currentPhone = widget.user?.phone ?? "번호 없음";

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
          const SizedBox(height: 30),

          // 2. 사용자 정보
          Text(
            "$currentName 님",
            style: TextStyle(
              fontSize: AppSizes.fontBiggest,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentPhone,
            style: TextStyle(
              fontSize: AppSizes.fontBiggest,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // 3. 내 번호 업데이트 버튼
          _buildActionButton(context, "내 번호 업데이트", AppColors.gradBtnBlue, _showUpdatePhoneDialog),
          const SizedBox(height: 30),

          // 4. 활동 정보 요약
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildInfoRow("활동 기간:", _getActivityPeriod()),
                // _buildInfoRow("상담 횟수:", "$_historyCount회"),
                // _buildInfoRow("상담 시간:", "$_totalHours시간"),
                _buildInfoRow("",""),
              ],
            ),
          ),
          //const SizedBox(height: 30),

          // 5. 내 활동 상세보기 버튼 (클릭 시 화면 이동 로직 추가)
          _buildActionButton(context, "내 활동 상세보기", AppColors.gradBtnBlue, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // 여기서 widget.user를 반드시 넘겨줘야 MyActivity에서 인식합니다.
                builder: (context) => MyActivity(user: widget.user),
              ),
            );
          }),
          const SizedBox(height: 20),

          // 6. 로그아웃 버튼
        _buildActionButton(context, "로 그 아 웃", AppColors.gradBtnGreen, () => _logout()),
          const SizedBox(height: 30),

          // 7. 계정삭제 요청하기 (빨간색 그라데이션 적용)
          _buildActionButton(
              context,
              "계정삭제 요청하기",
              AppColors.gradBtnRed, // theme에서 정의한 빨간 그라데이션
                  () => _requestAccountDeletion()
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Gradient gradient, VoidCallback onPressed) {
    return HighlightButton(
      onTap: onPressed,
      defaultGradient: gradient,
      highlightGradient: AppColors.gradBtnClick,
      shape: const StadiumBorder(),
      // 기존에 사용하던 그림자 효과 복구
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
        // 여기에 Container 자체 decoration을 넣으면 중복되어 에러가 날 수 있으니 비워둡니다.
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontMainButton,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontMid,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.fontMid,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}