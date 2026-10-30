import 'package:equatable/equatable.dart';

import '../data/meeting_note_response.dart';

/// 회의록 화면에서 사용하는 도메인 모델.
///
/// UI 색상 등은 위젯 쪽에서 매핑한다. 여기서는 표시할 데이터만 담는다.
class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    this.channelId = 0,
    this.templateId = 0,
    required this.tags,
    required this.author,
    this.participants = const [],
    this.sections = const {},
  });

  /// 회의록 식별자. 서버가 준 회의록 id 다.
  final int id;

  /// 회의록이 속한 채널 id. 수정 요청 경로에 쓴다.
  final int channelId;

  /// 회의록을 쓸 때 고른 템플릿 id. 편집 화면이 섹션 형식을 여기서 읽는다.
  final int templateId;

  /// 회의록 제목 (예: 2026 1분기 킥오프 회의).
  final String title;

  /// 제목 우측에 붙는 태그 배지 라벨 (예: 확정, OKR).
  final List<String> tags;

  /// 작성자 정보.
  final NoteAuthor author;

  /// 참여자 이니셜. 상세 화면 우측 아바타 스택에 표시된다.
  final List<String> participants;

  /// 섹션 제목 → 내용 (예: `{'안건': '1. ...'}`).
  ///
  /// 서버는 저장한 키 순서를 그대로 돌려준다. 상세 화면도 이 순서로 보여준다.
  final Map<String, String> sections;

  /// 카드에 보이는 본문 요약 (2줄 내외).
  ///
  /// 예전 회의록이 쓰던 `요약`·`내용` 섹션이 있으면 그것을, 없으면 모든 섹션을
  /// 이어 붙인다.
  String get summary =>
      sections['요약'] ?? sections['내용'] ?? sections.values.join(' ').trim();

  /// 서버 회의록을 화면 모델로 옮긴다. 태그·참여자는 서버에 없어 비운다.
  factory Note.fromMeetingNote(
    MeetingNoteResponse note, {
    required NoteAuthor author,
  }) => Note(
    id: note.id,
    channelId: note.channelId,
    templateId: note.templateId,
    title: note.title,
    tags: const [],
    author: author,
    sections: note.sections,
  );

  Note copyWith({
    String? title,
    List<String>? tags,
    NoteAuthor? author,
    List<String>? participants,
    Map<String, String>? sections,
  }) => Note(
    id: id,
    channelId: channelId,
    templateId: templateId,
    title: title ?? this.title,
    tags: tags ?? this.tags,
    author: author ?? this.author,
    participants: participants ?? this.participants,
    sections: sections ?? this.sections,
  );

  @override
  List<Object?> get props => [
    id,
    channelId,
    templateId,
    title,
    tags,
    author,
    participants,
    sections,
  ];
}

/// 섹션 본문의 체크박스 한 줄 (`- [ ] 할 일`). 상세 화면이 체크 칸으로 그린다.
class NoteActionItem extends Equatable {
  const NoteActionItem({required this.label, this.done = false});

  /// `- [x] 할 일` 한 줄을 읽는다. 체크 표시가 없으면 미완료로 본다.
  factory NoteActionItem.fromLine(String line) {
    final match = RegExp(r'^-?\s*\[( |x|X)\]\s*').firstMatch(line);
    if (match == null) return NoteActionItem(label: line);
    return NoteActionItem(
      label: line.substring(match.end),
      done: match.group(1)!.toLowerCase() == 'x',
    );
  }

  /// 할 일 문구 (예: Riverpod 상태 구조 초안 공유 (junjuny)).
  final String label;

  /// 완료 여부.
  final bool done;

  @override
  List<Object?> get props => [label, done];
}

/// 회의록 작성자. 하단의 아바타 + `이름 · 날짜` 라인에 쓰인다.
class NoteAuthor extends Equatable {
  const NoteAuthor({
    required this.authorId,
    required this.name,
    required this.initial,
    required this.date,
    this.avatarUrl = '',
  });

  /// 작성자 사용자 id. [ProfileStore.currentUserId] 와 같으면 내 노트다.
  final int authorId;

  /// 표시 이름 (예: junjuny).
  final String name;

  /// 아바타 프로필 이미지 URL. 있으면 이미지를 표시하고, 비어 있으면 [initial] 폴백.
  final String avatarUrl;

  /// 아바타 이미지가 없을 때 표시할 한 글자 (예: 준).
  final String initial;

  /// 작성 날짜 라벨 (예: 03.12).
  final String date;

  @override
  List<Object?> get props => [authorId, name, avatarUrl, initial, date];
}
