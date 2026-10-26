import 'package:cowork_app/shared/utils/initial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('이름의 첫 글자를 준다', () {
    expect(initialOf('코워크'), '코');
    expect(initialOf('cowork'), 'c');
  });

  test('이모지·결합 문자로 시작해도 한 글자를 통째로 준다', () {
    // substring(0, 1) 이면 이모지의 앞 반쪽(서로게이트 하나)만 남는다.
    expect(initialOf('🚀코워크'), '🚀');
    expect(initialOf('👩‍💻팀'), '👩‍💻');
    // e + U+0301(결합 악센트)
    expect(initialOf('équipe'), 'é');
  });

  test('이름이 비면 ? 를 준다', () {
    expect(initialOf(''), '?');
  });
}
