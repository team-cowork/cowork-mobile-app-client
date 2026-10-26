import 'package:cowork_app/feature/chat/data/model/chat_message_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 23, 18);

  test('오늘·어제·올해·그 이전을 다르게 적는다', () {
    expect(chatTimestampOf(DateTime(2026, 10, 23, 9, 5), now: now), '오늘 09:05');
    expect(
      chatTimestampOf(DateTime(2026, 10, 22, 23, 59), now: now),
      '어제 23:59',
    );
    expect(chatTimestampOf(DateTime(2026, 3, 2, 18), now: now), '3월 2일 18:00');
    expect(
      chatTimestampOf(DateTime(2025, 3, 2, 18), now: now),
      '2025년 3월 2일 18:00',
    );
  });

  test('이름이 비어 있으면 알 수 없는 작성자로 본다', () {
    expect(chatAuthorOf(7, '').name, '알 수 없음');
    expect(chatAuthorOf(7, '😀서연').avatarInitial, '😀');
  });
}
