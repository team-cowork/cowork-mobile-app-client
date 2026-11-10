import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/enums/note_section_type.dart';
import '../section_type_value.dart';

part 'template_section_request.freezed.dart';
part 'template_section_request.g.dart';

/// 섹션 추가(`POST`)·수정(`PATCH`) 요청 본문.
///
/// 수정은 서버가 보낸 필드만 반영하지만, 시트가 늘 모든 칸을 보여주므로 추가와 같은
/// 모양으로 전부 보낸다. 화면에서는 [TemplateSectionRequest.of] 로 만든다.
@Freezed(fromJson: false, toJson: true)
abstract class TemplateSectionRequest with _$TemplateSectionRequest {
  const factory TemplateSectionRequest({
    required String title,

    /// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
    required String type,

    /// 안내 문구. 없으면 null.
    ///
    /// 서버는 추가에서 null 을 "문구 없음"으로, 수정에서는 "바꾸지 않음"으로 읽는다.
    /// 그래서 수정에서 문구를 지울 때만 빈 문자열을 보낸다. [TemplateSectionRequest.of]
    /// 가 고른다.
    required String? placeholder,
    required bool isRequired,
  }) = _TemplateSectionRequest;

  /// 앱 형식 [type] 을 서버 값으로 바꿔 담는다.
  ///
  /// [previousPlaceholder] 는 고치는 섹션의 원래 문구다. 새 섹션이면 null 이다.
  factory TemplateSectionRequest.of({
    required String title,
    required NoteSectionType type,
    required String placeholder,
    required bool isRequired,
    String? previousPlaceholder,
  }) => TemplateSectionRequest(
    title: title,
    type: sectionTypeValueOf(type),
    placeholder: placeholder.isNotEmpty
        ? placeholder
        // 있던 문구를 비웠을 때만 빈 문자열로 지운다. 원래 없던 문구에 빈 문자열을
        // 보내면 서버에 null 대신 빈 문자열이 남는다.
        : (previousPlaceholder ?? '').isNotEmpty
        ? ''
        : null,
    isRequired: isRequired,
  );
}
