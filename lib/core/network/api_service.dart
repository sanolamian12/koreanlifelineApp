import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart'; // 방금 만든 모델 추가
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. 서버 주소를 상수로 정의 (포트 3000번 필수!)
  static const String baseUrl = "http://3.26.146.6:3000"; // 실제 사용 중인 EC2 IP로 교체하세요

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // [추가] 자동 로그인을 위한 정보 저장
  Future<void> saveLoginInfo(String id, String pw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_id', id);
    await prefs.setString('saved_pw', pw);
  }

  // [추가] 로그아웃 시 정보 삭제
  Future<void> clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 로그인 시 성공하면 저장 로직 호출
  Future<UserModel?> login(String accountId, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'accountId': accountId, 'password': password},
      );
      if (response.statusCode == 200) {
        await saveLoginInfo(accountId, password); // 기기에 저장
        print("서버 응답 원본: ${response.data}");
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) { return null; }
  }

  Future<Map<String, dynamic>?> getMyActivities(String accountId) async {
    try {
      // 서버 경로가 /current/my-activities/:accountId 인지 확인하세요.
      final response = await _dio.get('${ApiConstants.baseUrl}/current/my-activities/$accountId');
      if (response.statusCode == 200) {
        return response.data; // totalHours, historyCount 등이 포함됨
      }
      return null;
    } catch (e) {
      print("활동 데이터 로드 실패: $e");
      return null;
    }
  }
  Future<String?> updatePhoneNumber(String id, String newPhone) async {
    try {
      // 1. 경로 수정: 'my-phone' -> 'update-phone'
      final response = await _dio.patch('/auth/update-phone', data: {
        'id': id,          // 서버 Body 스펙과 일치
        'newPhone': newPhone, // 서버가 'newPhone'이라는 키를 기다리고 있습니다!
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("서버 응답: ${response.data}");
        // 2. 서버 service 로직상 account 객체를 통째로 반환하므로
        // 'account_phone' 키로 데이터를 가져옵니다.
        return response.data['account_phone']?.toString();
      }
      return null;
    } catch (e) {
      print("번호 수정 에러: $e");
      return null;
    }
  }
}