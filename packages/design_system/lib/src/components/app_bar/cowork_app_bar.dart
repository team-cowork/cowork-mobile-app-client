import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/icon/app_icon.dart';
import '../../theme/text_style/app_font.dart';

/// Cowork 상단 앱바.
///
/// Figma `cowork mobile app` 페이지의 화면별 헤더를 4개 유형으로 정리한 공통
/// 위젯이다. 유형은 factory 생성자로 구분한다.
///
/// - [CoworkAppBar.root] : 루트 탭 화면. 좌측 제목 + 우측 액션, 뒤로가기 없음. (홈, 프로필)
/// - [CoworkAppBar.section] : 섹션 화면. 제목 + 부제목(옵션) + 뒤로가기(옵션) + 액션. (회의록, 채널, 멤버)
/// - [CoworkAppBar.detail] : 상세/설정 화면. 뒤로가기 + 단일 제목 + 액션. (설정, 이슈 상세)
/// - [CoworkAppBar.form] : 편집 모달. 좌측 취소 + 중앙 제목 + 우측 저장. (프로필 편집, 노트 편집)
///
/// [Scaffold.appBar] 슬롯에 그대로 넣을 수 있도록 [PreferredSizeWidget]을 구현한다.
/// 상태바 인셋은 Scaffold가 더해 주고, 내부 [SafeArea]가 이를 소비한다.
class CoworkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CoworkAppBar._({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.titleStyle = AppFont.titleM,
    this.centerTitle = false,
  });

  /// ① 루트 탭 화면: 좌측 제목 + 우측 액션. 뒤로가기 없음.
  factory CoworkAppBar.root({
    required String title,
    List<Widget> actions = const [],
  }) => CoworkAppBar._(title: title, actions: actions);

  /// ② 섹션 화면: 제목 + 부제목(옵션) + 뒤로가기(옵션) + 액션.
  factory CoworkAppBar.section({
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    List<Widget> actions = const [],
  }) => CoworkAppBar._(
    title: title,
    subtitle: subtitle,
    leading: onBack == null ? null : _BackButton(onBack: onBack),
    actions: actions,
  );

  /// ③ 상세/설정 화면: 뒤로가기 + 단일 제목 + 액션.
  factory CoworkAppBar.detail({
    required String title,
    VoidCallback? onBack,
    List<Widget> actions = const [],
  }) => CoworkAppBar._(
    title: title,
    leading: onBack == null ? null : _BackButton(onBack: onBack),
    actions: actions,
    titleStyle: AppFont.titleS,
  );

  /// ④ 편집 모달: 좌측 취소 + 중앙 제목 + 우측 저장.
  factory CoworkAppBar.form({
    required String title,
    required String leadingLabel,
    required String actionLabel,
    VoidCallback? onLeading,
    VoidCallback? onAction,
  }) => CoworkAppBar._(
    title: title,
    leading: _TextAction(
      label: leadingLabel,
      color: AppColors.neutral300,
      onTap: onLeading,
    ),
    actions: [
      _TextAction(label: actionLabel, color: AppColors.red400, onTap: onAction),
    ],
    titleStyle: AppFont.titleS,
    centerTitle: true,
  );

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final TextStyle titleStyle;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 56 : 64);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final Widget? leadingWidget =
        leading ??
        (canPop
            ? _BackButton(onBack: () => Navigator.of(context).maybePop())
            : null);

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle.copyWith(color: AppColors.darkOnSurface),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.subtextM.copyWith(color: AppColors.neutral300),
          ),
        ],
      ],
    );

    return Material(
      color: AppColors.neutral850,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: NavigationToolbar(
              leading: leadingWidget,
              middle: titleBlock,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
              centerMiddle: centerTitle,
              middleSpacing: AppSpacing.s4,
            ),
          ),
        ),
      ),
    );
  }
}

/// 앱바 좌측 뒤로가기 버튼.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onBack,
      child: const SizedBox(
        width: 32,
        height: 44,
        child: Icon(AppIcon.back, size: 20, color: AppColors.darkOnSurface),
      ),
    );
  }
}

/// 편집 모달 앱바의 취소/저장 텍스트 버튼.
class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(label, style: AppFont.labelS.copyWith(color: color)),
    );
  }
}
