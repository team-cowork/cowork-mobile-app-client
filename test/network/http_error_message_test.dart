import 'package:cowork_app/network/http_error_message.dart';
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
}
