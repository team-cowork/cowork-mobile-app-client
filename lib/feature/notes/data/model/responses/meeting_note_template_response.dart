import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/note_template.dart';
import 'template_section_response.dart';

part 'meeting_note_template_response.freezed.dart';
part 'meeting_note_template_response.g.dart';

/// `/channels/{channelId}/meeting-note-templates` 계열 응답의 템플릿 하나.
///
/// 목록·상세·생성·수정·활성화가 모두 섹션까지 담은 같은 표현을 돌려준다.
@freezed
abstract class MeetingNoteTemplateResponse with _$MeetingNoteTemplateResponse {
  const MeetingNoteTemplateResponse._();

  const factory MeetingNoteTemplateResponse({
    /// 없으면 fromJson 이 던진다.
    required int id,
    required int channelId,
    @Default('') String name,

    /// 채널에서 켜져 있는 템플릿인지. 채널마다 하나다.
    @Default(false) bool isActive,
    @Default([]) List<TemplateSectionResponse> sections,
  }) = _MeetingNoteTemplateResponse;

  factory MeetingNoteTemplateResponse.fromJson(Map<String, dynamic> json) =>
      _$MeetingNoteTemplateResponseFromJson(json);

  NoteTemplate toTemplate() => NoteTemplate(
    id: id,
    channelId: channelId,
    name: name,
    isDefault: isActive,
    sections: [for (final section in sections) section.toSection()],
  );
}
