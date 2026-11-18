import 'package:cowork_app/shared/utils/chat_author.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('이름이 비어 있으면 알 수 없는 작성자로 본다', () {
    expect(chatAuthorOf(7, '').name, '알 수 없음');
    expect(chatAuthorOf(7, '😀서연').avatarInitial, '😀');
  });
}
