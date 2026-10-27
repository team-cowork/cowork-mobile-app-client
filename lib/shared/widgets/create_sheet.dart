import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 팀·채널·프로젝트 생성 바텀시트의 공통 껍데기.
///
/// 핸들, 제목 + 닫기 버튼, 키보드 회피, 스크롤을 맡는다. 시트마다 다른 입력
/// 항목과 CTA 는 [children] 으로 받는다.
class CreateSheet extends StatelessWidget {
  const CreateSheet({
    super.key,
    required this.title,
    required this.children,
    this.dismissible = true,
  });

  final String title;

  /// 입력 항목과 CTA. 세로로 [AppSpacing.s16] 간격을 두고 쌓인다.
  final List<Widget> children;

  /// false 면 닫기 버튼·뒤로 가기·바깥 탭으로 닫히지 않는다. 서버에 요청을 보내는
  /// 중에 닫혀 결과를 놓치지 않게 할 때 쓴다.
  final bool dismissible;

  static const double _radius = 22;

  /// 시트를 띄우고 시트가 [Navigator.pop] 으로 돌려준 값을 넘겨준다.
  static Future<T?> show<T>(BuildContext context, WidgetBuilder builder) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final sheet = SafeArea(
      child: Padding(
        // 키보드가 올라오면 시트 전체를 밀어 올린다.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s12,
            AppSpacing.s20,
            AppSpacing.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s16,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppFont.titleS.copyWith(color: colors.onSurface),
                  ),
                  CoworkIconButton(
                    icon: AppIcon.close,
                    size: CoworkIconButtonSize.small,
                    variant: CoworkIconButtonVariant.weak,
                    color: CoworkIconButtonColor.neutral,
                    semanticLabel: '닫기',
                    onPressed: dismissible
                        ? () => Navigator.of(context).pop()
                        : null,
                  ),
                ],
              ),
              ...children,
            ],
          ),
        ),
      ),
    );

    return PopScope(canPop: dismissible, child: sheet);
  }
}

/// 제출이 실패했을 때 CTA 위에 띄우는 제목 + 사유.
///
/// 시트가 화면을 덮고 있어 스낵바는 시트 뒤에 깔려 안 보이므로 시트 안에 그린다.
class CreateSheetError extends StatelessWidget {
  const CreateSheetError({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final error = context.colors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s4,
      children: [
        Text(
          title,
          style: AppFont.labelXs.copyWith(height: null, color: error),
        ),
        Text(
          message,
          style: AppFont.subtextS.copyWith(height: null, color: error),
        ),
      ],
    );
  }
}
