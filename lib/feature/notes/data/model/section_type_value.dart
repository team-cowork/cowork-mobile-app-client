import '../../domain/enums/note_section_type.dart';

/// 앱의 [NoteSectionType] 과 서버 섹션 `type` 의 짝. 서버 enum `SectionType` 과 같다.
const _values = {
  NoteSectionType.text: 'TEXT',
  NoteSectionType.markdown: 'MARKDOWN',
  NoteSectionType.date: 'DATE',
  NoteSectionType.dateTime: 'DATETIME',
  NoteSectionType.userList: 'USER_LIST',
};

/// 요청에 실을 서버 섹션 `type`.
String sectionTypeValueOf(NoteSectionType type) => _values[type]!;

/// 서버 섹션 `type` 을 앱 형식으로. 모르는 값은 긴 텍스트로 본다.
///
/// 긴 텍스트 칸은 무엇이든 받아 적을 수 있어서, 서버에 형식이 새로 생겨도 이미 쓴
/// 내용을 그대로 보여주고 고칠 수 있다.
NoteSectionType sectionTypeOf(String? value) =>
    _values.entries.where((entry) => entry.value == value).firstOrNull?.key ??
    NoteSectionType.markdown;
