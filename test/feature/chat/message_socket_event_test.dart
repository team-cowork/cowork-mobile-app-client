import 'package:cowork_app/feature/chat/data/model/message_socket_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('수정 이벤트에 고친 내용이 없거나 글이 아니면 버린다', () {
    for (final data in [
      {'messageId': 'm1'},
      {'messageId': 'm1', 'content': 3},
      {'content': '고친 내용'},
    ]) {
      expect(
        MessageSocketEvent.from((name: 'message:edited', data: data)),
        isNull,
        reason: '$data',
      );
    }
  });
}
