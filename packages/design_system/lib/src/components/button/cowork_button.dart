import 'package:flutter/material.dart';

import '../../theme/text_style/app_font.dart';

/// Cowork 디자인 시스템 버튼 크기.
enum CoworkButtonSize { small, medium, large }

/// Cowork 디자인 시스템 버튼 강조 방식.
enum CoworkButtonVariant { fill, weak }

/// Cowork 디자인 시스템 버튼 컬러 역할.
enum CoworkButtonColor { brand, neutral, danger }

/// Size, Variant, Color, State 축을 가진 Cowork 기본 CTA/보조 버튼.
class CoworkButton extends StatelessWidget {
  const CoworkButton({
    required this.label,
    this.onPressed,
    this.size = CoworkButtonSize.small,
    this.variant = CoworkButtonVariant.fill,
    this.color = CoworkButtonColor.brand,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final CoworkButtonSize size;
  final CoworkButtonVariant variant;
  final CoworkButtonColor color;
  final bool enabled;

  bool get _isInteractive => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final tokens = _CoworkButtonTokens.resolve(
      Theme.of(context).colorScheme,
      size: size,
      variant: variant,
      color: color,
    );

    return Semantics(
      button: true,
      enabled: _isInteractive,
      child: Material(
        color: tokens.backgroundColor,
        borderRadius: BorderRadius.circular(tokens.radius),
        child: InkWell(
          onTap: _isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(tokens.radius),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.height),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.horizontalPadding,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.textStyle.copyWith(
                    color: tokens.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoworkButtonTokens {
  const _CoworkButtonTokens({
    required this.height,
    required this.horizontalPadding,
    required this.radius,
    required this.textStyle,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double height;
  final double horizontalPadding;
  final double radius;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color foregroundColor;

  static _CoworkButtonTokens resolve(
    ColorScheme colorScheme, {
    required CoworkButtonSize size,
    required CoworkButtonVariant variant,
    required CoworkButtonColor color,
  }) {
    final dimension = switch (size) {
      CoworkButtonSize.small => const _CoworkButtonDimension(
        height: 36,
        horizontalPadding: 14,
        radius: 10,
        textStyle: AppFont.labelS,
      ),
      CoworkButtonSize.medium => const _CoworkButtonDimension(
        height: 44,
        horizontalPadding: 18,
        radius: 12,
        textStyle: AppFont.labelM,
      ),
      CoworkButtonSize.large => const _CoworkButtonDimension(
        height: 52,
        horizontalPadding: 22,
        radius: 14,
        textStyle: AppFont.labelM,
      ),
    };

    final (:backgroundColor, :foregroundColor) = switch ((variant, color)) {
      (CoworkButtonVariant.fill, CoworkButtonColor.brand) => (
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      (CoworkButtonVariant.fill, CoworkButtonColor.neutral) => (
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onPrimary,
      ),
      (CoworkButtonVariant.fill, CoworkButtonColor.danger) => (
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
      (CoworkButtonVariant.weak, CoworkButtonColor.brand) => (
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      (CoworkButtonVariant.weak, CoworkButtonColor.neutral) => (
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      (CoworkButtonVariant.weak, CoworkButtonColor.danger) => (
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      ),
    };

    return _CoworkButtonTokens(
      height: dimension.height,
      horizontalPadding: dimension.horizontalPadding,
      radius: dimension.radius,
      textStyle: dimension.textStyle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _CoworkButtonDimension {
  const _CoworkButtonDimension({
    required this.height,
    required this.horizontalPadding,
    required this.radius,
    required this.textStyle,
  });

  final double height;
  final double horizontalPadding;
  final double radius;
  final TextStyle textStyle;
}
