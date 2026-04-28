import 'package:flutter/material.dart';

/// 앱 텍스트 스타일
class AppFont {
  AppFont._();

  static const String _fontFamily = 'Pretendard';

  // Display
  static const TextStyle displayL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  // Headline
  static const TextStyle headlineL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle headlineM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle headlineS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodyM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodyS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Label
  static const TextStyle labelL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle labelM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle labelS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
