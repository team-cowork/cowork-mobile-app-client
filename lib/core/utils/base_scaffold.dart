import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 앱 전역 다크 배경을 기본값으로 갖는 [Scaffold] 래퍼.
///
/// 화면마다 `backgroundColor: AppColors.neutral850`을 반복 선언하던 것을 모은다.
class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// 기본값은 [AppColors.neutral850].
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.neutral850,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
