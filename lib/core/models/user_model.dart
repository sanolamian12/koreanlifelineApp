class UserModel {
  final String accountId;
  final String accountName;
  final String phone;
  final bool isChief;
  final DateTime registeredAt;

  UserModel({
    required this.accountId,
    required this.accountName,
    required this.phone,
    required this.isChief,
    required this.registeredAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 서버 로그를 보면 데이터가 'user'라는 키 안에 들어있습니다.
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    return UserModel(
      accountId: userData['id']?.toString() ?? '',
      accountName: userData['name']?.toString() ?? '상담원', // 'name' 키와 매칭
      phone: userData['phone']?.toString() ?? '번호 없음',   // 'phone' 키와 매칭
      isChief: userData['isChief'] ?? false,
      registeredAt: userData['joinedAt'] != null
          ? DateTime.parse(userData['joinedAt'].toString())
          : DateTime.now(), // 'joinedAt' 키와 매칭
    );
  }
}