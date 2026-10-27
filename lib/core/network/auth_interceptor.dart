import 'package:dio/dio.dart';

/// 인증이 필요한 요청에 Bearer 를 붙이고, 401 이면 토큰을 갱신해 한 번만 재시도한다.
///
/// `/auth/*` 를 부르는 dio 에는 달지 않는다. 갱신 요청 자체가 401 을 받으면 다시
/// 갱신을 부르는 고리가 생긴다. `AuthRepository` 가 인터셉터 없는 [createDio] 를
/// 쓰는 이유가 이것이다.
///
/// ponytail: `QueuedInterceptor` 를 쓰지 않았다. 그쪽은 콜백을 한 큐에서 직렬화해서,
/// `onError` 안에서 같은 dio 로 재시도를 보내면 그 재시도의 `onRequest` 가 앞의
/// `onError` 뒤에 줄을 서서 서로를 기다린다. 동시성은 아래 단일 비행(single-flight)
/// 갱신으로 직접 막는 편이 안전하다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio client,
    required String? Function() accessToken,
    required Future<bool> Function() refresh,
  }) : _client = client,
       _accessToken = accessToken,
       _refresh = refresh;

  /// 재시도를 다시 태울 클라이언트. 보통 이 인터셉터가 붙은 dio 자신이다.
  final Dio _client;

  /// 지금 붙일 access token. 로그아웃 상태면 null.
  final String? Function() _accessToken;

  /// 갱신에 성공하면 true, 만료돼서 로그아웃됐으면 false.
  final Future<bool> Function() _refresh;

  /// 재시도한 요청 표시. 재시도가 또 401 이어도 여기서 멈춘다.
  static const _retriedKey = 'auth.retried';

  /// 진행 중인 갱신. 동시에 401 을 받은 요청들이 갱신을 각자 부르지 않게 묶는다.
  Future<bool>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _accessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    // 보낸 사이에 다른 요청이 이미 갱신해 놨다면 갱신을 건너뛰고 새 토큰으로 바로
    // 재시도한다. 이게 없으면 같은 토큰으로 나갔던 요청 수만큼 갱신이 더 돈다.
    final sentWithCurrentToken =
        request.headers['Authorization'] == 'Bearer ${_accessToken()}';
    if (sentWithCurrentToken && !await _refreshOnce()) {
      return handler.next(err);
    }

    final token = _accessToken();
    if (token == null) return handler.next(err);

    request.extra[_retriedKey] = true;
    request.headers['Authorization'] = 'Bearer $token';
    try {
      handler.resolve(await _client.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// 갱신이 이미 돌고 있으면 그 결과를 같이 기다린다.
  ///
  /// 갱신이 예외로 끝나도 인터셉터 밖으로 새면 안 된다. 실패는 false 로 눕히고
  /// 호출부가 원래 401 을 그대로 돌려주게 한다.
  Future<bool> _refreshOnce() => _refreshing ??= _refresh()
      .catchError((_) => false)
      .whenComplete(() => _refreshing = null);
}
