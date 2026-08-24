import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cowork_app/feature/profile/data/profile_repository.dart';
import 'package:cowork_app/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 나간 요청을 순서대로 받아 적고 정해진 본문을 돌려주는 어댑터.
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter([this.body = '']);

  /// 어떤 요청에든 돌려줄 응답 본문.
  final String body;

  final requests = <RequestOptions>[];
  final payloads = <List<int>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      payloads.add((await requestStream.toList()).expand((c) => c).toList());
    }
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(HttpClientAdapter adapter) => Dio(
  BaseOptions(
    baseUrl: 'https://example.test/api',
    contentType: Headers.jsonContentType,
    responseType: ResponseType.plain,
  ),
)..httpClientAdapter = adapter;

void main() {
  test('사진 업로드는 presigned → 스토리지 PUT → confirm 순서로 나간다', () async {
    final file = File(
      '${Directory.systemTemp.createTempSync().path}/avatar.png',
    )..writeAsBytesSync([1, 2, 3]);
    addTearDown(() => file.parent.deleteSync(recursive: true));

    final api = _RecordingAdapter(
      jsonEncode({
        'object_key': 'users/7/avatar.png',
        'upload_url': 'https://storage.test/bucket/users/7/avatar.png?sig=abc',
      }),
    );
    final storage = _RecordingAdapter();

    // API 쪽 dio 에만 인증 인터셉터를 단다. 업로드가 이 dio 를 타면 Authorization
    // 이 섞여 스토리지가 요청을 거부하는데, 그 회귀를 아래에서 잡는다.
    final apiDio = _dio(api)
      ..interceptors.add(
        AuthInterceptor(
          client: _dio(api),
          accessToken: () => 'token',
          refresh: () async => false,
        ),
      );

    await ProfileRepository.withDio(
      apiDio,
      _dio(storage),
    ).uploadProfileImage(file.path);

    expect(api.requests.map((r) => r.path), [
      '/users/me/profile-image/presigned',
      '/users/me/profile-image/confirm',
    ]);
    expect(api.requests.first.data, {
      'content_type': 'image/png',
    }, reason: '확장자에서 뽑은 MIME 이 서명에 들어간다');
    expect(api.requests.last.data, {'object_key': 'users/7/avatar.png'});

    final upload = storage.requests.single;
    expect(upload.method, 'PUT');
    expect(
      upload.uri.toString(),
      'https://storage.test/bucket/users/7/avatar.png?sig=abc',
      reason: 'baseUrl 이 아니라 발급받은 절대 URL 로 나가야 한다',
    );
    expect(upload.contentType, 'image/png', reason: 'presigned 와 같은 값이어야 한다');
    expect(
      upload.headers.keys.map((k) => k.toLowerCase()),
      isNot(contains('authorization')),
      reason: '서명에 없는 헤더가 붙으면 스토리지가 거부한다',
    );
    expect(storage.payloads.single, [1, 2, 3], reason: '파일 바이트가 그대로 올라간다');
  });

  test('presigned 응답에 URL 이 없으면 올리지 않고 던진다', () async {
    final file = File('${Directory.systemTemp.createTempSync().path}/a.png')
      ..writeAsBytesSync([1]);
    addTearDown(() => file.parent.deleteSync(recursive: true));

    final storage = _RecordingAdapter();
    await expectLater(
      ProfileRepository.withDio(
        _dio(_RecordingAdapter(jsonEncode({'object_key': 'k'}))),
        _dio(storage),
      ).uploadProfileImage(file.path),
      throwsA(isA<FormatException>()),
    );
    expect(storage.requests, isEmpty, reason: '빈 URL 은 API 게이트웨이로 날아간다');
  });

  test('모르는 확장자는 jpeg 로 올린다', () async {
    final file = File('${Directory.systemTemp.createTempSync().path}/IMG_0001')
      ..writeAsBytesSync([1]);
    addTearDown(() => file.parent.deleteSync(recursive: true));

    final api = _RecordingAdapter(
      jsonEncode({'object_key': 'k', 'upload_url': 'https://storage.test/k'}),
    );
    await ProfileRepository.withDio(
      _dio(api),
      _dio(_RecordingAdapter()),
    ).uploadProfileImage(file.path);

    expect(api.requests.first.data, {'content_type': 'image/jpeg'});
  });
}
