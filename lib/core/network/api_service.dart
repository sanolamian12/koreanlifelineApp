import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/schedule_model.dart';

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
      // 기존: '/current/my-activities/$accountId' -> 404 에러 발생
      // 수정: 백엔드에서 토큰으로 식별하므로 ID를 붙이지 않습니다.
      final response = await _dio.get('/current/my-activities');
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
      // 1. 기기의 시차(Offset)를 구함 (시드니 AEDT 기준 +660 등)
      int offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

      // 2. queryParameters에 offset을 실어서 보냄
      final response = await _dio.get(
        '/current/status',
        queryParameters: {'offset': offsetMinutes}, // 추가됨!
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("상태 조회 실패: $e");
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

  // ApiService 클래스 내부에 추가
  Future<List<ScheduleModel>> getAllSchedules() async {
    try {
      final response = await _dio.get('/orders/all');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => ScheduleModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("시간표 로드 실패: $e");
      return [];
    }
  }

  // core/network/api_service.dart 내부 예상 코드
  Future<int?> getCurrentOrderNo() async {
    try {
      // 1. 기기의 시차(Offset)를 구함 (시드니면 +660 등)
      int offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

      // 2. 서버에 offset 인자를 태워 보냄
      final response = await _dio.get(
        '/orders/current-no',
        queryParameters: {'offset': offsetMinutes},
      );

      return response.data['currentOrderNo'];
    } catch (e) {
      print("에러 발생: $e");
      return null;
    }
  }

  Future<DateTime?> getLastUpdatedDate() async {
    try {
      final response = await _dio.get('/orders/last-updated');
      if (response.statusCode == 200) {
        return DateTime.parse(response.data['lastUpdated']);
      }
    } catch (e) {
      print("업데이트 날짜 로드 실패: $e");
    }
    return null;
  }

  Future<bool> toggleAdminMode(bool isOn, String userId) async { // userId 추가
    try {
      int offset = DateTime.now().timeZoneOffset.inMinutes;

      final response = await _dio.post(
        '/current/toggle-admin',
        data: {
          'isOn': isOn,
          'offset': offset,
          'accountId': userId, // 서버로 ID 전송
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("운영자 모드 전환 실패: $e");
      return false;
    }
  }
}