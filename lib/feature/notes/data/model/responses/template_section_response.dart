import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/note_template.dart';
import '../section_type_value.dart';

part 'template_section_response.freezed.dart';
part 'template_section_response.g.dart';

/// 회의록 템플릿 섹션 하나. 템플릿 응답에 실려 오고, 섹션 추가·수정도 이 모양을 돌려준다.
@freezed
abstract class TemplateSectionResponse with _$TemplateSectionResponse {
  const TemplateSectionResponse._();

  const factory TemplateSectionResponse({
    /// 없으면 fromJson 이 던진다.
    required int id,
    @Default('') String title,

    /// 입력 형식. (예: TEXT, MARKDOWN, DATETIME)
    String? type,
    String? placeholder,
    @Default(false) bool isRequired,
  }) = _TemplateSectionResponse;

  factory TemplateSectionResponse.fromJson(Map<String, dynamic> json) =>
      _$TemplateSectionResponseFromJson(json);

  NoteTemplateSection toSection() => NoteTemplateSection(
    id: id,
    title: title,
    type: sectionTypeOf(type),
    placeholder: placeholder ?? '',
    isRequired: isRequired,
  );
}
