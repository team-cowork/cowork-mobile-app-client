import 'package:equatable/equatable.dart';

import 'enums/note_section_type.dart';

/// 채널의 회의록 템플릿. 새 회의록을 만들 때 고르는 양식이다.
///
/// 템플릿은 팀이 아니라 채널에 속한다. 서버는 채널마다 템플릿 하나를 활성
/// (`isActive`)으로 두는데, 화면은 이것을 `기본 템플릿` 이라 부르고 새 노트
/// 시트에서 먼저 골라 둔다.
class NoteTemplate extends Equatable {
  const NoteTemplate({
    required this.id,
    required this.channelId,
    required this.name,
    this.isDefault = false,
    this.sections = const [],
  });

  final int id;

  /// 템플릿이 속한 채널. 템플릿 API 경로에 들어간다.
  final int channelId;

  final String name;

  /// 채널의 기본 템플릿인지. 서버의 `isActive` 다.
  final bool isDefault;

  /// 섹션. 서버가 돌려준 순서(추가한 순서) 그대로다.
  final List<NoteTemplateSection> sections;

  NoteTemplate copyWith({
    String? name,
    bool? isDefault,
    List<NoteTemplateSection>? sections,
  }) => NoteTemplate(
    id: id,
    channelId: channelId,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    sections: sections ?? this.sections,
  );

  @override
  List<Object?> get props => [id, channelId, name, isDefault, sections];
}

/// 템플릿 섹션 하나. 회의록 본문은 [title] 을 키로 이 섹션의 내용을 담는다.
class NoteTemplateSection extends Equatable {
  const NoteTemplateSection({
    required this.id,
    required this.title,
    required this.type,
    this.placeholder = '',
    this.isRequired = false,
  });

  final int id;

  /// 섹션 제목 (예: 안건). 회의록 본문의 키다.
  final String title;

  final NoteSectionType type;

  /// 비어 있을 때 입력 칸에 보이는 안내 문구. 없으면 빈 문자열.
  final String placeholder;

  /// 비어 있으면 회의록을 저장할 수 없는 섹션인지.
  ///
  /// 서버는 저장할 때 검사하지 않는다. 앱이 편집 화면에서 막는다.
  final bool isRequired;

  @override
  List<Object?> get props => [id, title, type, placeholder, isRequired];
}
