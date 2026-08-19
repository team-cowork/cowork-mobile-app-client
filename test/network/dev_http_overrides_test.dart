import 'package:cowork_app/network/dev_http_overrides.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final overrides = DevHttpOverrides(allowedHost: 'dev.example.com');

  test('개발 서버 호스트의 자체 서명 인증서만 통과시킨다', () {
    expect(overrides.allowsBadCertificateFor('dev.example.com'), isTrue);
  });

  test('다른 호스트는 평소대로 검증에 실패시킨다', () {
    expect(overrides.allowsBadCertificateFor('attacker.example.com'), isFalse);
    // 서브도메인/접미사를 붙여 우회하는 것도 막힌다.
    expect(overrides.allowsBadCertificateFor('dev.example.com.evil.io'), isFalse);
    expect(overrides.allowsBadCertificateFor('notdev.example.com'), isFalse);
  });

  test('호스트를 못 읽으면(설정 누락) 아무것도 통과시키지 않는다', () {
    final blank = DevHttpOverrides(allowedHost: '');
    expect(blank.allowsBadCertificateFor(''), isFalse);
    expect(blank.allowsBadCertificateFor('dev.example.com'), isFalse);
  });
}
