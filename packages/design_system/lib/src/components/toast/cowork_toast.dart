import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_radius.dart';
import '../../constants/app_size.dart';
import '../../constants/app_spacing.dart';
import '../../theme/color/app_colors.dart';
import '../../theme/color/app_colors_theme.dart';
import '../../theme/text_style/app_font.dart';

/// Toast 상태. 상태 아이콘과 색상을 결정한다.
enum CoworkToastStatus {
  /// 저장 완료 등 성공 피드백. (초록 체크)
  success(Icons.check_circle_rounded, AppColors.green500),

  /// 오류 알림 등 실패 피드백. (빨강)
  error(Icons.error_rounded, AppColors.red500),

  /// 업로드 제한 안내 등 일반 정보. (파랑)
  info(Icons.info_rounded, AppColors.blue500);

  const CoworkToastStatus(this.icon, this.iconColor);

  final IconData icon;
  final Color iconColor;
}

/// 일시적 피드백을 표시하는 Toast pill.
///
/// 업로드 제한, 저장 완료, 오류 알림 등 짧은 안내에 사용한다.
/// Inverse surface 배경 위에 상태 아이콘과 메시지를 가로로 표시한다.
class CoworkToast extends StatelessWidget {
  const CoworkToast({
    required this.message,
    this.status = CoworkToastStatus.success,
    super.key,
  });

  /// 토스트에 표시할 메시지 문구.
  final String message;

  /// 토스트 상태. 아이콘과 색상을 결정한다. 기본값은 [CoworkToastStatus.success].
  final CoworkToastStatus status;

  /// 화면 오른쪽 위에 토스트를 띄운다. [Overlay] 위에 표시되므로
  /// [context]는 `MaterialApp`(또는 [Overlay]) 하위이면 된다.
  ///
  /// 슬라이드 + 페이드로 나타났다가 [duration] 후 사라진다.
  ///
  /// ```dart
  /// CoworkToast.show(context, message: '저장되었습니다.');
  /// CoworkToast.show(context, message: '실패했습니다.', status: CoworkToastStatus.error);
  /// ```
  static void show(
    BuildContext context, {
    required String message,
    CoworkToastStatus status = CoworkToastStatus.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoworkToastOverlay(
        message: message,
        status: status,
        duration: duration,
        onDismissed: entry.remove,
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: _minHeight),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      child: Row(
        children: [
          Icon(status.icon, size: AppSize.iconSmall, color: status.iconColor),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              message,
              style: AppFont.labelS.copyWith(color: colors.onInverseSurface),
            ),
          ),
        ],
      ),
    );
  }

  static const double _minHeight = 64;
}

/// [CoworkToast.show]가 오버레이에 삽입하는 애니메이션 래퍼.
///
/// 오른쪽 위에 고정되어 슬라이드+페이드로 등장하고, [duration] 후 역재생 뒤
/// [onDismissed]로 스스로 제거를 요청한다.
class _CoworkToastOverlay extends StatefulWidget {
  const _CoworkToastOverlay({
    required this.message,
    required this.status,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final CoworkToastStatus status;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_CoworkToastOverlay> createState() => _CoworkToastOverlayState();

  static const double _maxWidth = 420;
}

class _CoworkToastOverlayState extends State<_CoworkToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.4),
    end: Offset.zero,
  ).animate(_fade);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = math.min(
      _CoworkToastOverlay._maxWidth,
      media.size.width - AppSpacing.s16 * 2,
    );

    return Positioned(
      top: media.padding.top + AppSpacing.s16,
      right: AppSpacing.s16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CoworkToast(message: widget.message, status: widget.status),
          ),
        ),
      ),
    );
  }
}
