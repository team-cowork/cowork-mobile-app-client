import 'package:cowork_app/core/network/http_error_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('상태 코드를 코드 접두사가 붙은 문구로 바꾼다', () {
    expect(httpErrorMessage(404), '(404) 페이지를 찾을 수 없습니다.');
    expect(httpErrorMessage(401), '(401) 로그인이 필요합니다.');
  });

  test('서버가 준 사유가 있으면 기본 문구 대신 쓴다', () {
    expect(httpErrorMessage(400, '만료됨'), '(400) 만료됨');
  });

  test('모르는 코드는 4xx/5xx 로 갈라 기본 문구를 준다', () {
    expect(httpErrorMessage(418), '(418) 요청을 처리하지 못했습니다.');
    expect(httpErrorMessage(504), '(504) 서버에 문제가 발생했습니다.');
  });

  test('오류 본문에서 사용자 메시지를 뽑는다', () {
    expect(
      errorMessageOf('{"error":"invalid_grant","error_description":"만료됨"}'),
      '만료됨',
    );
    expect(
      errorMessageOf('{"status":"UNAUTHORIZED","message":"Unauthorized"}'),
      'Unauthorized',
    );
    expect(errorMessageOf('<html>502</html>'), isNull);
  });

  group('failureMessageOf', () {
    final requestOptions = RequestOptions(path: '/x');

    test('응답이 있는 DioException 은 상태 코드가 붙은 문구로 바꾼다', () {
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 503),
      );

      expect(failureMessageOf(error, '기본'), '(503) 서비스를 잠시 사용할 수 없습니다.');
    });

    test('응답이 없는 DioException 은 연결 실패 문구로 바꾼다', () {
      final error = DioException(requestOptions: requestOptions);

      expect(failureMessageOf(error, '기본'), '네트워크에 연결할 수 없습니다.');
    });

    test('DioException 이 아니면 fallback 을 그대로 돌려준다', () {
      expect(failureMessageOf(StateError('x'), '저장하지 못했어요.'), '저장하지 못했어요.');
      expect(failureMessageOf(StateError('x')), isNull);
    });
  });
}
