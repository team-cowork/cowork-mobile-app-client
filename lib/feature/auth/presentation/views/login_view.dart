import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/base_scaffold.dart';

/// Figma `App / Login` 화면 퍼블리싱.
///
/// 다크 배경 위에 Cowork 로고 + 타이틀/서브타이틀, DataGSM 로그인 버튼을 노출한다.
class LoginView extends StatelessWidget {
  const LoginView({super.key, this.onDataGsmLogin});

  /// DataGSM 로그인 버튼 탭 콜백. 실제 인증 연동 시 주입한다.
  final VoidCallback? onDataGsmLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BaseScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Logo(background: colors.primaryContainer),
                const SizedBox(height: AppSpacing.s24),
                Text(
                  'Cowork',
                  style: AppFont.displayM.copyWith(color: AppColors.neutral100),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  '팀 협업을 위한 올인원 워크스페이스',
                  style: AppFont.subtextL.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),
                _DataGsmLoginButton(onPressed: onDataGsmLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.background});

  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: AppIcon.logo(),
    );
  }
}

class _DataGsmLoginButton extends StatelessWidget {
  const _DataGsmLoginButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'DataGSM으로 로그인',
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.r14),
          child: SizedBox(
            width: 256,
            height: 51,
            child: ExcludeSemantics(
              child: Row(
                // SizedBox 가 폭 256 을 강제해서 MainAxisSize.min 은 먹지 않는다.
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon.dataGsm(),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'DataGSM으로 로그인',
                    style: AppFont.labelS.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
