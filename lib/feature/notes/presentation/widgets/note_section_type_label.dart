import '../../domain/enums/note_section_type.dart';

/// 섹션 입력 형식의 표시 문구. 데스크톱 앱과 같은 낱말을 쓴다.
extension NoteSectionTypeLabel on NoteSectionType {
  String get label => switch (this) {
    NoteSectionType.text => '짧은 텍스트',
    NoteSectionType.markdown => '긴 텍스트',
    NoteSectionType.date => '날짜',
    NoteSectionType.dateTime => '날짜와 시간',
    NoteSectionType.userList => '참석자 목록',
  };
}
