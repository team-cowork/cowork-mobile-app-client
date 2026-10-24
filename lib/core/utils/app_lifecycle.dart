import 'dart:async';

import 'package:flutter/widgets.dart';

/// 앱 생명주기 변화를 스트림으로. 구독을 끊으면 리스너도 정리한다.
///
/// Bloc 이 위젯 없이 포그라운드 여부를 알아야 할 때 쓴다. 테스트에서는 이 대신
/// 직접 만든 스트림을 넘긴다.
Stream<AppLifecycleState> appLifecycleStates() {
  AppLifecycleListener? listener;
  late final StreamController<AppLifecycleState> controller;
  controller = StreamController<AppLifecycleState>(
    onListen: () =>
        listener = AppLifecycleListener(onStateChange: controller.add),
    onCancel: () => listener?.dispose(),
  );
  return controller.stream;
}
