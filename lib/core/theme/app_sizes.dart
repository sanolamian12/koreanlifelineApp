import 'package:flutter/material.dart';

class AppSizes {
  // --- 1. Figma 기준 정보 (계산의 근거) ---
  static const double figmaWidth = 393.0; // iPhone 14/15 Pro 기준

  // --- 2. Radius (곡률 - 고정값) ---
  static const double radiusButton = 9999.0;
  static const double radiusCard = 16.0;
  static const double radiusNavi = 8.0;

  // --- 3. Font Size (글꼴 크기 - 고정값) ---
  static const double fontBiggest = 32.0;
  static const double fontMainButton = 24.0;
  static const double fontBig = 20.0;
  static const double fontMid = 16.0;
  static const double fontSmall = 12.0;

  // --- 4. 객체별 Figma 기준 사이즈 (비율 계산용 상수) ---
  // 이 수치들은 직접 쓰지 않고 wPercent 함수에 넣어서 사용할 것입니다.
  static const double wMainButton = 300.0;
  static const double hMainButton = 65.0;

  static const double wNaviButton = 70.0;
  static const double hNaviButton = 56.0;

  static const double wBackButton = 96.0;
  static const double hBackButton = 40.0;

  static const double wBigCard = 330.0;
  static const double hBigCard = 100.0;

  static const double wSmallCard = 330.0;
  static const double hSmallCard = 50.0;

  static const double wScheduleTime = 190.0;
  static const double wScheduleName = 120.0;
  static const double hSchedule = 50.0;

  static const double wImage = 209.0;
  static const double hImage = 132.0;

  static const double hNaviArea = 70.0;

  // --- 5. Responsive Helper Methods (반응형 계산 도구) ---

  /// Figma상의 픽셀값을 현재 기기의 화면 너비 비율에 맞춰 변환합니다.
  static double wPercent(BuildContext context, double figmaPixel) {
    return MediaQuery.of(context).size.width * (figmaPixel / figmaWidth);
  }

  /// (선택사항) 높이도 비율로 조절하고 싶을 때 사용합니다.
  /// 하지만 보통 높이는 스크롤 방향이라 고정값을 쓰거나 너비에 맞춘 AspectRatio를 더 권장합니다.
  static double hPercent(BuildContext context, double figmaPixel) {
    return MediaQuery.of(context).size.height * (figmaPixel / 852.0); // 852는 일반적인 Figma 높이 기준
  }
}