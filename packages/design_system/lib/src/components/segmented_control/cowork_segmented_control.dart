import 'package:flutter/material.dart';

import '../../theme/color/app_colors.dart';
import '../../theme/text_style/app_font.dart';

/// Cowork 디자인 시스템 세그먼티드 컨트롤 크기.
enum CoworkSegmentedControlSize { medium, large }

/// [CoworkSegmentedControl]의 개별 세그먼트.
class CoworkSegment<T> {
  const CoworkSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// 채팅/파일/이슈 같은 탭성 전환에 사용하는 세그먼티드 컨트롤.
class CoworkSegmentedControl<T> extends StatelessWidget {
  const CoworkSegmentedControl({
    required this.segments,
    required this.groupValue,
    this.onChanged,
    this.size = CoworkSegmentedControlSize.medium,
    this.enabled = true,
    super.key,
  }) : assert(segments.length >= 2, 'segments must contain at least 2 items');

  final List<CoworkSegment<T>> segments;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final CoworkSegmentedControlSize size;
  final bool enabled;

  bool get _isInteractive => enabled && onChanged != null;

  static const Duration _duration = Duration(milliseconds: 200);
  static const Curve _curve = Curves.easeOut;
  static const double _trackPadding = 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimension = _dimensionFor(size);
    final selectedIndex = segments.indexWhere((s) => s.value == groupValue);
    final trackRadius = dimension.height / 2;
    final innerHeight = dimension.height - _trackPadding * 2;
    final innerRadius = innerHeight / 2;
    final indicatorAlignmentX = -1.0 + 2.0 * selectedIndex / (segments.length - 1);

    return SizedBox(
      height: dimension.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(trackRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_trackPadding),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (selectedIndex >= 0)
                AnimatedAlign(
                  duration: _duration,
                  curve: _curve,
                  alignment: Alignment(indicatorAlignmentX, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / segments.length,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: enabled
                            ? colorScheme.surface
                            : colorScheme.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(innerRadius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < segments.length; i++)
                    Expanded(
                      child: _Segment(
                        label: segments[i].label,
                        selected: i == selectedIndex,
                        enabled: _isInteractive,
                        textStyle: dimension.textStyle,
                        colorScheme: colorScheme,
                        onTap: _isInteractive && i != selectedIndex
                            ? () => onChanged!(segments[i].value)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CoworkSegmentedControlDimension _dimensionFor(
    CoworkSegmentedControlSize size,
  ) {
    return switch (size) {
      CoworkSegmentedControlSize.medium =>
        const _CoworkSegmentedControlDimension(
          height: 44,
          textStyle: AppFont.labelS,
        ),
      CoworkSegmentedControlSize.large =>
        const _CoworkSegmentedControlDimension(
          height: 52,
          textStyle: AppFont.labelM,
        ),
    };
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.textStyle,
    required this.colorScheme,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final TextStyle textStyle;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    if (!enabled) {
      foreground = colorScheme.onSurface.withValues(alpha: 0.38);
    } else if (selected) {
      foreground = colorScheme.onSurface;
    } else {
      foreground = colorScheme.onSurfaceVariant;
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(
              color: foreground,
              fontWeight: selected ? AppFont.semiBold : AppFont.medium,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoworkSegmentedControlDimension {
  const _CoworkSegmentedControlDimension({
    required this.height,
    required this.textStyle,
  });

  final double height;
  final TextStyle textStyle;
}
