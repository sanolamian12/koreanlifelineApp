import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget { // 각 파일명에 맞게 MyPage, StatusScreen 등으로 클래스명 변경
  const StatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("화면 준비 중", style: TextStyle(fontSize: 20)));
  }
}