import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/note.dart';
import '../meeting_note_content.dart';

part 'meeting_note_response.freezed.dart';
part 'meeting_note_response.g.dart';

/// `/channels/{channelId}/meeting-notes` 응답 본문.
///
/// 게이트웨이 envelope 을 벗긴 `data` 를 받는다(`unwrapPayload`).
@freezed
abstract class MeetingNoteResponse with _$MeetingNoteResponse {
  const MeetingNoteResponse._();

  const factory MeetingNoteResponse({
    @Default(0) int id,

    /// 회의록이 속한 채널. 수정·삭제 경로에 필요해 같이 들고 다닌다.
    @Default(0) int channelId,

    /// 회의록을 쓸 때 고른 템플릿. 편집 화면이 섹션 형식을 여기서 읽는다.
    @Default(0) int templateId,
    @Default('') String title,

    /// 섹션 이름 → 내용. 예: `{'안건': '1. ...', '결정 사항': '· ...'}`.
    @JsonKey(name: 'content', fromJson: parseNoteContent)
    @Default({})
    Map<String, String> sections,

    /// 작성자 사용자 id. 이름·사진은 `/users/{id}` 에서 따로 읽는다.
    @Default(0) int createdBy,

    /// 정렬에만 쓰므로 못 읽으면 맨 뒤로 보낸다.
    @JsonKey(fromJson: _createdAtOf) required DateTime createdAt,
  }) = _MeetingNoteResponse;

  factory MeetingNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$MeetingNoteResponseFromJson(json);

  /// 화면 모델로 옮긴다. 태그·참여자는 서버에 없어 비운다.
  Note toNote(NoteAuthor author) => Note(
    id: id,
    channelId: channelId,
    templateId: templateId,
    title: title,
    tags: const [],
    author: author,
    sections: sections,
  );
}

DateTime _createdAtOf(String? raw) =>
    DateTime.tryParse(raw ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
