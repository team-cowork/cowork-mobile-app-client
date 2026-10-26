import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/notification_stream.dart';
import '../model/received_notification.dart';
import '../model/responses/notification_event_response.dart';

/// SSE 로 받은 알림을 메모리에 쌓아 두는 저장소.
///
/// 서버에 알림 목록 API 가 없어, 로그인한 동안 받은 알림만 최신순으로 들고 있다.
/// 앱을 다시 켜거나 로그아웃하면 비워진다.
class NotificationRepository {
  NotificationRepository(this._stream, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final NotificationStream _stream;
  final DateTime Function() _clock;

  /// 들고 있는 알림 수의 상한. 넘치면 오래된 것부터 버린다.
  static const maxItems = 100;

  final _items = <ReceivedNotification>[];
  final _changes = StreamController<void>.broadcast();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  int _nextId = 0;

  /// 받은 알림. 최신순.
  List<ReceivedNotification> get items => List.unmodifiable(_items);

  /// [items] 가 바뀌었다.
  Stream<void> get changes => _changes.stream;

  /// 알림을 받기 시작한다. 로그인했을 때 부른다.
  void start() {
    _subscription ??= _stream.events.listen(_onEvent);
    _stream.start();
  }

  /// 알림 받기를 멈추고 받은 알림을 비운다. 로그아웃했을 때 부른다.
  void stop() {
    _stream.stop();
    _subscription?.cancel();
    _subscription = null;
    if (_items.isEmpty) return;
    _items.clear();
    _changes.add(null);
  }

  void markRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1 || _items[index].read) return;
    _items[index] = _items[index].markRead();
    _changes.add(null);
  }

  void markAllRead() {
    if (_items.every((item) => item.read)) return;
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].markRead();
    }
    _changes.add(null);
  }

  void dispose() {
    stop();
    _stream.dispose();
    _changes.close();
  }

  void _onEvent(Map<String, dynamic> json) {
    final NotificationEventResponse event;
    try {
      event = NotificationEventResponse.fromJson(json);
    } on CheckedFromJsonException {
      return;
    }
    _items.insert(
      0,
      ReceivedNotification(
        id: 'n${_nextId++}',
        event: event,
        receivedAt: _clock(),
      ),
    );
    if (_items.length > maxItems) _items.removeLast();
    _changes.add(null);
  }
}
