class ApiConstants {
  // 실제 EC2 공인 IP 주소를 입력하세요.
  static const String baseUrl = 'http://3.26.146.6:3000';

  // Auth 관련 경로
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';

  // Current 관련 경로
  static const String status = '$baseUrl/current/status';

  static const String contactUsUrl = 'https://your-notion-page-url';
}