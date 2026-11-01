import 'package:equatable/equatable.dart';

import 'enums/note_section_type.dart';
import 'note_template.dart';

/// 회의록 편집 화면이 그리는 입력 칸 하나.
///
/// 템플릿 섹션이 기본이다. 본문에는 있는데 템플릿에는 없는 키도 [extra] 로 붙여
/// 내용을 잃지 않게 한다. 템플릿에서 섹션 제목을 바꾸거나 지우면 이미 쓴 회의록의
/// 본문 키가 템플릿과 어긋나기 때문이다.
class NoteSectionField extends Equatable {
  const NoteSectionField({
    required this.title,
    this.type = NoteSectionType.markdown,
    this.placeholder = '',
    this.isRequired = false,
    this.extra = false,
  });

  factory NoteSectionField.of(NoteTemplateSection section) => NoteSectionField(
    title: section.title,
    type: section.type,
    placeholder: section.placeholder,
    isRequired: section.isRequired,
  );

  /// 섹션 제목. 회의록 본문의 키다.
  final String title;

  final NoteSectionType type;

  /// 비어 있을 때 보이는 안내 문구.
  final String placeholder;

  /// 비어 있으면 저장할 수 없는 칸인지.
  final bool isRequired;

  /// 템플릿에는 없고 본문에만 남은 칸인지.
  final bool extra;

  @override
  List<Object?> get props => [title, type, placeholder, isRequired, extra];
}

/// [template] 섹션 순서대로 칸을 만들고, 템플릿에 없는 [content] 키를 뒤에 붙인다.
///
/// 템플릿을 못 읽었으면([template] 이 null) 본문 키만으로 긴 텍스트 칸을 만든다.
/// 이때는 무엇이 템플릿 밖인지 알 수 없으므로 [NoteSectionField.extra] 를 세우지 않는다.
List<NoteSectionField> sectionFieldsOf(
  NoteTemplate? template,
  Map<String, String> content,
) {
  final fields = [
    for (final section in template?.sections ?? const <NoteTemplateSection>[])
      NoteSectionField.of(section),
  ];
  final titles = {for (final field in fields) field.title};
  return [
    ...fields,
    for (final key in content.keys)
      if (!titles.contains(key))
        NoteSectionField(title: key, extra: template != null),
  ];
}
