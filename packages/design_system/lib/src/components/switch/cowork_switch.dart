import 'package:flutter/material.dart';

import '../../theme/color/app_colors.dart';

/// 보안 모드, 공개/비공개, 알림 등 Boolean 설정 변경에 사용하는 토글 스위치.
class CoworkSwitch extends StatelessWidget {
  const CoworkSwitch({
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final String? semanticLabel;

  bool get _isInteractive => enabled && onChanged != null;

  static const double _width = 48;
  static const double _height = 28;
  static const double _thumbDiameter = 22;
  static const double _trackPadding = 3;
  static const Duration _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final tokens = _CoworkSwitchTokens.resolve(
      Theme.of(context).colorScheme,
      value: value,
      enabled: _isInteractive,
    );

    return Semantics(
      toggled: value,
      enabled: _isInteractive,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isInteractive ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          width: _width,
          height: _height,
          padding: const EdgeInsets.all(_trackPadding),
          decoration: BoxDecoration(
            color: tokens.trackColor,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: SizedBox.square(
              dimension: _thumbDiameter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.thumbColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoworkSwitchTokens {
  const _CoworkSwitchTokens({
    required this.trackColor,
    required this.thumbColor,
  });

  final Color trackColor;
  final Color thumbColor;

  static _CoworkSwitchTokens resolve(
    ColorScheme colorScheme, {
    required bool value,
    required bool enabled,
  }) {
    final activeTrack = value ? AppColors.green500 : colorScheme.outline;

    if (!enabled) {
      return _CoworkSwitchTokens(
        trackColor: activeTrack.withValues(alpha: 0.38),
        thumbColor: AppColors.white,
      );
    }

    return _CoworkSwitchTokens(
      trackColor: activeTrack,
      thumbColor: AppColors.white,
    );
  }
}
