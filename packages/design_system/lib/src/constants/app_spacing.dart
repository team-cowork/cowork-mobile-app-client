import 'package:cowork_design_tokens/cowork_design_tokens.dart';

/// 앱 공통 간격 토큰
///
/// 패딩, 마진 등 자주 쓰이는 수치를 숫자 기반으로 정의한다.
class AppSpacing {
  AppSpacing._();

  static const double s4 = CoworkSpacing.s4;
  static const double s6 = CoworkSpacing.s6;
  static const double s8 = CoworkSpacing.s8;
  static const double s10 = CoworkSpacing.s10;
  static const double s12 = CoworkSpacing.s12;
  static const double s14 = CoworkSpacing.s14;
  static const double s16 = CoworkSpacing.s16;
  static const double s18 = CoworkSpacing.s18;
  static const double s20 = CoworkSpacing.s20;
  static const double s24 = CoworkSpacing.s24;
  static const double s32 = CoworkSpacing.s32;

  /// 기본 페이지 수평 패딩
  static const double pagePaddingH = s16;

  /// 기본 페이지 수직 패딩
  static const double pagePaddingV = s24;
}
