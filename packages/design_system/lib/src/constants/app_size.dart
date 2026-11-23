import 'package:cowork_design_tokens/cowork_design_tokens.dart';

/// 앱 공통 컴포넌트 사이즈 토큰
///
/// 버튼, 아이콘 버튼, 세그먼티드 컨트롤 등 small/medium/large 스케일을
/// 공유하는 컴포넌트의 높이 및 아이콘 크기를 정의한다.
class AppSize {
  AppSize._();

  /// 컴포넌트 높이/지름 (small)
  static const double componentSmall = CoworkSize.componentSmall;

  /// 컴포넌트 높이/지름 (medium)
  static const double componentMedium = CoworkSize.componentMedium;

  /// 컴포넌트 높이/지름 (large)
  static const double componentLarge = CoworkSize.componentLarge;

  /// 아이콘 크기 (Xsmall)
  static const double iconXSmall = CoworkSize.iconXSmall;

  /// 아이콘 크기 (small)
  static const double iconSmall = CoworkSize.iconSmall;

  /// 아이콘 크기 (medium)
  static const double iconMedium = CoworkSize.iconMedium;

  /// 아이콘 크기 (large)
  static const double iconLarge = CoworkSize.iconLarge;

  /// 아이콘을 감싸는 컨테이너(섬네일) 크기
  static const double iconContainer = CoworkSize.iconContainer;
}
