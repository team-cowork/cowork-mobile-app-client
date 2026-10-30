import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting_note_template_request.freezed.dart';
part 'meeting_note_template_request.g.dart';

/// 템플릿 생성(`POST`)·이름 수정(`PATCH`) 요청 본문. 서버는 둘 다 이름만 받는다.
@Freezed(fromJson: false, toJson: true)
abstract class MeetingNoteTemplateRequest with _$MeetingNoteTemplateRequest {
  const factory MeetingNoteTemplateRequest({required String name}) =
      _MeetingNoteTemplateRequest;
}
