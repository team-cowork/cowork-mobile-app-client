import 'package:cowork_app/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('게이트웨이 주소 뒤에 서비스 prefix 를 붙인다', () {
    expect(
      serviceBaseUrl('https://example.test/api', ApiService.authorization),
      'https://example.test/api/authorization',
    );
    expect(
      serviceBaseUrl('https://example.test/api', ApiService.user),
      'https://example.test/api/user',
    );
  });

  test('게이트웨이 주소 끝의 / 는 겹치지 않는다', () {
    expect(
      serviceBaseUrl('https://example.test/api/', ApiService.user),
      'https://example.test/api/user',
    );
  });
}
