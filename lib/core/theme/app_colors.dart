import 'package:flutter/material.dart';

class AppColors {
  // --- 그라데이션 (Gradation) ---
  static const Gradient gradBtnBlue = LinearGradient(
    colors: [Color(0xFF4662FF), Color(0xFF001799)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  static const Gradient gradBtnGreen = LinearGradient(
    colors: [Color(0xFF1CA900), Color(0xFF087200)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  static const Gradient gradBtnGray = LinearGradient(
    colors: [Color(0xFFD8DDFD), Color(0xFFCCCFDC)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  static const Gradient gradBtnClick = LinearGradient(
    colors: [Color(0xFFE3FF46), Color(0xFF949900)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );


  static const Gradient gradTextboxGreen = LinearGradient(
    colors: [Color(0xFFDDFFD6), Color(0xFFB2E69E)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const Gradient gradTextboxRed = LinearGradient(
    colors: [Color(0xFFFFDCD6), Color(0xFFE6A59E)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const Gradient gradBtnRed = LinearGradient(
    colors: [Color(0xFFFF8D8D), Color(0xFF990000)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  static const Gradient gradBtnNavi = LinearGradient(
    colors: [Color(0xFFD4D4D4), Color(0xFF444444)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  // --- 단색 (Solid Color) ---
  static const Color textOrange = Color(0xFFDC8113);
  static const Color bodyNavi = Color(0xFF828282);
}