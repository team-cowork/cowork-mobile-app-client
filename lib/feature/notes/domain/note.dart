import 'package:equatable/equatable.dart';

/// 회의록 화면에서 사용하는 도메인 모델.
///
/// UI 색상 등은 위젯 쪽에서 매핑한다. 여기서는 표시할 데이터만 담는다.
class Note extends Equatable {
  const Note({
    required this.title,
    required this.tags,
    required this.summary,
    required this.author,
  });

  /// 회의록 제목 (예: 2026 1분기 킥오프 회의).
  final String title;

  /// 제목 우측에 붙는 태그 배지 라벨 (예: 확정, OKR).
  final List<String> tags;

  /// 본문 요약 (2줄 내외).
  final String summary;

  /// 작성자 정보.
  final NoteAuthor author;

  @override
  List<Object?> get props => [title, tags, summary, author];
}

/// 회의록 작성자. 하단의 아바타 + `이름 · 날짜` 라인에 쓰인다.
class NoteAuthor extends Equatable {
  const NoteAuthor({
    required this.name,
    required this.initial,
    required this.date,
    this.avatarUrl = '',
  });

  /// 표시 이름 (예: junjuny).
  final String name;

  /// 아바타 프로필 이미지 URL. 있으면 이미지를 표시하고, 비어 있으면 [initial] 폴백.
  final String avatarUrl;

  /// 아바타 이미지가 없을 때 표시할 한 글자 (예: 준).
  final String initial;

  /// 작성 날짜 라벨 (예: 03.12).
  final String date;

  @override
  List<Object?> get props => [name, avatarUrl, initial, date];
}
