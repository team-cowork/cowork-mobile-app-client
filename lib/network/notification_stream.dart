import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/utils/logger.dart';
import '../feature/auth/data/auth_repository.dart';
import 'dio_client.dart';
import 'sse.dart';

/// notification 서비스의 SSE 알림 스트림 (`GET /notifications/stream`).
///
/// 로그인한 동안 앱에 하나만 열어 둔다. 끊기면 점점 길게 기다렸다가 다시 붙고,
/// 서버가 30초마다 보내는 keepalive 가 [idleTimeout] 동안 없으면 끊긴 것으로 보고
/// 다시 붙는다. 연결 확인용 `connected` 이벤트는 넘기지 않는다.
///
/// 서버에 지난 알림을 다시 받는 API 가 없어, 끊긴 동안 온 알림은 받지 못한다.
class NotificationStream {
  NotificationStream(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.notification, auth));

  NotificationStream.withDio(
    this._dio, {
    this.idleTimeout = const Duration(seconds: 75),
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 30),
    ],
  });

  final Dio _dio;

  /// 이만큼 아무것도 오지 않으면 다시 붙는다. keepalive(30초)보다 넉넉히 둔다.
  final Duration idleTimeout;

  /// 연달아 실패할 때 기다리는 시간. 끝 값을 계속 쓴다.
  final List<Duration> retryDelays;

  final _events = StreamController<Map<String, dynamic>>.broadcast();

  bool _running = false;
  CancelToken? _cancelToken;
  Timer? _retryTimer;
  int _failures = 0;

  /// 서버가 보낸 알림 payload. (`{type, title, body, channelId, teamId}`)
  Stream<Map<String, dynamic>> get events => _events.stream;

  /// 연결을 연다. 이미 열려 있으면 그대로 둔다.
  void start() {
    if (_running) return;
    _running = true;
    _failures = 0;
    _connect();
  }

  /// 연결을 끊고 다시 붙지 않는다.
  void stop() {
    _running = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  void dispose() {
    stop();
    _events.close();
  }

  Future<void> _connect() async {
    final cancelToken = _cancelToken = CancelToken();
    Timer? idle;
    void resetIdle() {
      idle?.cancel();
      idle = Timer(idleTimeout, () => cancelToken.cancel('응답 없음'));
    }

    try {
      // 응답 헤더가 오기 전에 멈춰도 다시 붙도록 요청부터 지켜본다.
      resetIdle();
      final response = await _dio.get<ResponseBody>(
        '/notifications/stream',
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
        cancelToken: cancelToken,
      );
      resetIdle();
      final bytes = response.data!.stream.map((chunk) {
        resetIdle();
        return chunk;
      });
      await for (final event in parseSse(bytes)) {
        if (event.event == 'connected') {
          _failures = 0;
          continue;
        }
        _emit(event.data);
      }
    } catch (e, s) {
      // 토큰 갱신까지 실패했다. 다시 붙어도 계속 거절되니 멈추고, 다시 로그인하면
      // start() 로 다시 연다.
      if (e is DioException && e.response?.statusCode == 401) {
        Logger.e('알림 스트림 인증 실패. 다시 붙지 않는다', tag: 'Notification', error: e);
        if (identical(_cancelToken, cancelToken)) stop();
        return;
      }
      // stop() 으로 끊은 것은 오류가 아니다.
      if (_running) {
        Logger.e('알림 스트림 끊김', tag: 'Notification', error: e, stackTrace: s);
      }
    } finally {
      idle?.cancel();
    }

    if (!_running || !identical(_cancelToken, cancelToken)) return;
    final delay = retryDelays[_failures.clamp(0, retryDelays.length - 1)];
    _failures++;
    _retryTimer = Timer(delay, _connect);
  }

  void _emit(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) _events.add(decoded);
    } on FormatException catch (e) {
      Logger.e('알림 payload 해석 실패: $data', tag: 'Notification', error: e);
    }
  }
}
