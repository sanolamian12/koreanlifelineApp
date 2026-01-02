import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://3.26.146.6:3000";

  // 모든 인스턴스가 공유하도록 토큰을 static으로 관리
  static String? _accessToken;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // 생성자에서 Interceptor 추가
  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 토큰이 있다면 모든 요청 헤더에 'Bearer 토큰'을 추가함
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        print("API 에러 발생: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // [수정] 로그인 시 서버로부터 받은 access_token을 메모리에 저장
  Future<UserModel?> login(String accountId, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'accountId': accountId, 'password': password},
      );
      if (response.statusCode == 200) {
        // 서버 응답에서 토큰 추출 및 저장
        _accessToken = response.data['access_token'];

        await saveLoginInfo(accountId, password);
        print("로그인 성공! 토큰 확보됨.");
        print("서버 응답 원본: ${response.data}");

        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("로그인 실패: $e");
      return null;
    }
  }

  // [수정] URL 경로를 baseUrl 기반 상대 경로로 통일
  Future<Map<String, dynamic>?> getMyActivities(String accountId) async {
    try {
      // 절대경로 중복 방지를 위해 상대경로 사용
      final response = await _dio.get('/current/my-activities/$accountId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("활동 데이터 로드 실패: $e");
      return null;
    }
  }

  Future<String?> updatePhoneNumber(String id, String newPhone) async {
    try {
      final response = await _dio.patch('/auth/update-phone', data: {
        'id': id,
        'newPhone': newPhone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['account_phone']?.toString();
      }
      return null;
    } catch (e) {
      print("번호 수정 에러: $e");
      return null;
    }
  }

  // [수정] 이제 Interceptor가 토큰을 자동으로 헤더에 넣어줍니다.
  Future<Map<String, dynamic>?> getHandoverStatus() async {
    try {
      // NestJS의 @Get('status')와 매칭
      final response = await _dio.get('/current/status');
      if (response.statusCode == 200) {
        print("상태 조회 성공: ${response.data}");
        return response.data;
      }
      return null;
    } catch (e) {
      print("상태 조회 실패 (토큰 확인 필요): $e");
      return null;
    }
  }

  Future<bool> doHandover() async {
    try {
      final response = await _dio.post('/current/handover');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("인수인계 실패: $e");
      return false;
    }
  }

  // 자동 로그인을 위한 정보 저장/삭제 로직
  Future<void> saveLoginInfo(String id, String pw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_id', id);
    await prefs.setString('saved_pw', pw);
  }

  Future<void> clearLoginInfo() async {
    _accessToken = null; // 메모리 토큰 초기화
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // 1. 모든 상담원 목록 가져오기 (가나다순 정렬)
  Future<List<dynamic>> getAllCounselors() async {
    try {
      // 서버의 AuthController 내부에 만든 엔드포인트를 호출합니다.
      final response = await _dio.get('/auth/accounts');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print("상담원 목록 로드 실패: $e");
      return [];
    }
  }

// 2. 선택된 상담원 DB 업데이트
  Future<bool> updateSelectedCounselor(String selectedId) async {
    try {
      // 이 경로는 CurrentController에 @Patch('select')가 구현되어 있어야 합니다.
      final response = await _dio.patch('/current/select', data: {'selectedId': selectedId});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("상담원 선택 업데이트 실패: $e");
      return false;
    }
  }
}