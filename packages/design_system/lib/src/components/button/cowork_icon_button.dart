import 'package:flutter/material.dart';

import '../../constants/app_size.dart';

/// Cowork 디자인 시스템 아이콘 버튼 크기.
enum CoworkIconButtonSize { small, medium, large }

/// Cowork 디자인 시스템 아이콘 버튼 강조 방식.
enum CoworkIconButtonVariant { fill, weak, ghost }

/// Cowork 디자인 시스템 아이콘 버튼 컬러 역할.
enum CoworkIconButtonColor { brand, neutral, danger }

/// 아이콘 단독 액션 버튼.
///
/// 채널 추가, 파일 첨부, 설정 진입 등 텍스트 라벨 없이 아이콘만으로 동작을
/// 표현하는 원형 버튼이다.
class CoworkIconButton extends StatelessWidget {
  const CoworkIconButton({
    required this.icon,
    this.onPressed,
    this.size = CoworkIconButtonSize.medium,
    this.variant = CoworkIconButtonVariant.fill,
    this.color = CoworkIconButtonColor.brand,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final CoworkIconButtonSize size;
  final CoworkIconButtonVariant variant;
  final CoworkIconButtonColor color;
  final bool enabled;
  final String? semanticLabel;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final tokens = _CoworkIconButtonTokens.resolve(
      Theme.of(context).colorScheme,
      size: size,
      variant: variant,
      color: color,
      enabled: _isInteractive,
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticLabel,
      child: Material(
        color: tokens.backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _isInteractive ? onPressed : null,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: tokens.diameter,
            child: Center(
              child: Icon(
                icon,
                size: tokens.iconSize,
                color: tokens.foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoworkIconButtonTokens {
  const _CoworkIconButtonTokens({
    required this.diameter,
    required this.iconSize,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double diameter;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;

  static _CoworkIconButtonTokens resolve(
    ColorScheme colorScheme, {
    required CoworkIconButtonSize size,
    required CoworkIconButtonVariant variant,
    required CoworkIconButtonColor color,
    required bool enabled,
  }) {
    final dimension = switch (size) {
      CoworkIconButtonSize.small => const _CoworkIconButtonDimension(
        diameter: AppSize.componentSmall,
        iconSize: AppSize.iconSmall,
      ),
      CoworkIconButtonSize.medium => const _CoworkIconButtonDimension(
        diameter: AppSize.componentMedium,
        iconSize: AppSize.iconMedium,
      ),
      CoworkIconButtonSize.large => const _CoworkIconButtonDimension(
        diameter: AppSize.componentLarge,
        iconSize: AppSize.iconLarge,
      ),
    };

    if (!enabled) {
      final disabledBackground = variant == CoworkIconButtonVariant.ghost
          ? Colors.transparent
          : colorScheme.surfaceContainerHighest;
      return _CoworkIconButtonTokens(
        diameter: dimension.diameter,
        iconSize: dimension.iconSize,
        backgroundColor: disabledBackground,
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      );
    }

    final (:backgroundColor, :foregroundColor) = switch ((variant, color)) {
      (CoworkIconButtonVariant.fill, CoworkIconButtonColor.brand) => (
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      (CoworkIconButtonVariant.fill, CoworkIconButtonColor.neutral) => (
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onPrimary,
      ),
      (CoworkIconButtonVariant.fill, CoworkIconButtonColor.danger) => (
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
      (CoworkIconButtonVariant.weak, CoworkIconButtonColor.brand) => (
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      (CoworkIconButtonVariant.weak, CoworkIconButtonColor.neutral) => (
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      (CoworkIconButtonVariant.weak, CoworkIconButtonColor.danger) => (
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      ),
      (CoworkIconButtonVariant.ghost, CoworkIconButtonColor.brand) => (
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
      ),
      (CoworkIconButtonVariant.ghost, CoworkIconButtonColor.neutral) => (
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      (CoworkIconButtonVariant.ghost, CoworkIconButtonColor.danger) => (
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.error,
      ),
    };

    return _CoworkIconButtonTokens(
      diameter: dimension.diameter,
      iconSize: dimension.iconSize,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _CoworkIconButtonDimension {
  const _CoworkIconButtonDimension({
    required this.diameter,
    required this.iconSize,
  });

  final double diameter;
  final double iconSize;
}
