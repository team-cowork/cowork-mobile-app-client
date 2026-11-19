import 'package:cowork_app/feature/chat/data/model/dm_preview_mapping.dart';
import 'package:cowork_app/feature/chat/data/model/responses/dm_conversation_response.dart';
import 'package:cowork_app/feature/chat/domain/enums/dm_presence.dart';
import 'package:cowork_app/shared/domain/profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dm_test_server.dart';

void main() {
  const other = ProfileEntity(id: 2, name: '서연', avatarInitial: '서');
  // 2026-11-12(목) 12:00. 목록 시각은 기기 시간대라 한낮으로 날짜가 흔들리지 않게 한다.
  final now = DateTime(2026, 11, 12, 12);

  DmConversationResponse conversation(Map<String, dynamic> json) =>
      DmConversationResponse.fromJson(json);

  group('목록 시각', () {
    test('오늘은 시각, 어제는 어제, 일주일 안은 요일이다', () {
      expect(dmTimestampOf(DateTime(2026, 11, 12, 9, 5), now: now), '09:05');
      expect(dmTimestampOf(DateTime(2026, 11, 11, 23), now: now), '어제');
      expect(dmTimestampOf(DateTime(2026, 11, 9, 8), now: now), '월요일');
    });

    test('일주일보다 오래되면 날짜, 해가 다르면 연도까지 적는다', () {
      expect(dmTimestampOf(DateTime(2026, 11, 5), now: now), '11월 5일');
      expect(dmTimestampOf(DateTime(2025, 3, 2), now: now), '2025년 3월 2일');
    });
  });

  group('미리보기', () {
    test('내가 보낸 마지막 메시지는 나: 를 붙인다', () {
      final preview = directMessagePreviewOf(
        conversation(dmJson(11, 2, content: '확인했어요', authorId: 1)),
        other,
        myId: 1,
        now: now,
      );

      expect(preview.lastMessage, '나: 확인했어요');
    });

    test('상대가 보낸 마지막 메시지는 그대로, 내 id 를 모르면 붙이지 않는다', () {
      final response = conversation(dmJson(11, 2, content: '안녕', authorId: 2));

      expect(
        directMessagePreviewOf(response, other, myId: 1, now: now).lastMessage,
        '안녕',
      );
      expect(
        directMessagePreviewOf(response, other, now: now).lastMessage,
        '안녕',
      );
    });

    test('파일만 있는 메시지는 안내 문구로, 메시지가 없으면 빈 시각이다', () {
      final file = directMessagePreviewOf(
        conversation(dmJson(11, 2, content: '', type: 'FILE')),
        other,
        now: now,
      );
      final empty = directMessagePreviewOf(
        conversation(dmJson(12, 2, content: null)),
        other,
        now: now,
      );

      expect(file.lastMessage, '파일을 보냈어요');
      expect(empty.lastMessage, '아직 메시지가 없어요');
      expect(empty.timestamp, '');
    });

    test('글과 함께 보낸 파일은 글을, 빈 글 메시지는 빈 미리보기를 보인다', () {
      final caption = directMessagePreviewOf(
        conversation(dmJson(11, 2, content: '시안 보내요', type: 'FILE')),
        other,
        now: now,
      );
      final blank = directMessagePreviewOf(
        conversation(dmJson(12, 2, content: '')),
        other,
        now: now,
      );

      expect(caption.lastMessage, '시안 보내요');
      expect(blank.lastMessage, '');
    });

    test('서버에 없는 접속 상태·고정·음소거·입력 중은 기본값으로 둔다', () {
      final preview = directMessagePreviewOf(
        conversation(dmJson(11, 2)),
        other,
        now: now,
      );

      expect(preview.presence, DmPresence.offline);
      expect(preview.isPinned, isFalse);
      expect(preview.isMuted, isFalse);
      expect(preview.isTyping, isFalse);
    });

    test('채널 id, 읽지 않은 수, 상대를 그대로 옮긴다', () {
      final preview = directMessagePreviewOf(
        conversation(dmJson(11, 2, unreadCount: 4)),
        other,
        now: now,
      );

      expect(preview.channelId, 11);
      expect(preview.unreadCount, 4);
      expect(preview.profile, other);
    });
  });
}
