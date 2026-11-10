/// 회의록 템플릿 섹션의 입력 형식. 표시 문구·입력 위젯은 프레젠테이션 쪽에서 매핑한다.
enum NoteSectionType {
  /// 한 줄 텍스트
  text,

  /// 여러 줄 마크다운
  markdown,

  /// 날짜
  date,

  /// 날짜와 시간
  dateTime,

  /// 참석자 목록
  userList,
}
