import 'dart:async';

import 'package:cowork_app/network/notification_stream.dart';

/// 가짜 알림 스트림. 켜고 끈 것을 기록하고, 테스트가 알림을 [push] 한다.
class FakeNotificationStream implements NotificationStream {
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  bool running = false;

  void push(Map<String, dynamic> payload) => _events.add(payload);

  @override
  Stream<Map<String, dynamic>> get events => _events.stream;

  @override
  void start() => running = true;

  @override
  void stop() => running = false;

  @override
  void dispose() => _events.close();

  @override
  Duration get idleTimeout => Duration.zero;

  @override
  List<Duration> get retryDelays => const [];
}
