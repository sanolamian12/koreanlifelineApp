class ScheduleModel {
  final String day;
  final String time;
  final int order;
  final String accountName;

  ScheduleModel({
    required this.day,
    required this.time,
    required this.order,
    required this.accountName,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      order: json['order'] ?? 0,
      accountName: json['account']?['account_name'] ?? '미지정',
    );
  }
}