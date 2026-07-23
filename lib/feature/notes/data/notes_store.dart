import '../domain/note.dart';

/// 회의록 목(mock) 데이터 저장소.
///
/// 백엔드 연동 전까지 시드 데이터와 앱 세션 동안 추가된 노트를 함께 보관한다.
/// 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.
///
// ponytail: 앱 재시작 시 초기화됨. 영구 저장이 필요하면 shared_preferences로 승격.
class NotesStore {
  NotesStore._();

  static final NotesStore instance = NotesStore._();

  final List<Note> _notes = [..._seed];

  List<Note> get notes => List.unmodifiable(_notes);

  /// 새 노트에 부여할 다음 식별자. 시드 다음 인덱스부터 시작해 계속 증가한다.
  int _nextId = _seed.length;

  /// 새 노트용으로 유일한 int id를 하나 발급한다.
  int get nextId => _nextId++;

  /// 새 노트를 목록 맨 앞에 추가한다.
  void add(Note note) => _notes.insert(0, note);

  /// 편집된 노트를 [Note.id] 기준으로 교체한다. 없으면 무시한다.
  void update(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) _notes[index] = note;
  }

  static const _seed = [
    Note(
      id: 0,
      title: '2026 1분기 킥오프 회의',
      tags: ['확정', 'OKR'],
      summary: '분기 목표 정렬 및 팀별 OKR 확정. 채팅·이슈 트래커 MVP 범위 합의, 음성 채널은 입장/대화만 포함하기로 결정.',
      // 데모: 킥오프 회의록은 현재 사용자(id 1) 소유 → 상세뷰에서 수정 아이콘 노출.
      author: NoteAuthor(
        authorId: 1,
        name: 'junjuny',
        initial: '준',
        date: '03.12',
      ),
      participants: ['도', '서', '민'],
      agenda: [
        '1. 1분기 팀 목표 및 OKR 정렬',
        '2. 채팅·이슈 트래커 MVP 범위',
        '3. 음성 채널 포함 여부',
      ],
      decisions: [
        '· 채팅과 이슈 트래커를 1차 MVP로 확정.',
        '· 음성 채널은 입장/대화 기능만 포함, 화면공유는 2차로 이관.',
        '· 디자인 토큰·컴포넌트는 다크 테마 기준으로 먼저 정리.',
      ],
      actionItems: [
        NoteActionItem(label: 'Riverpod 상태 구조 초안 공유 (junjuny)', done: true),
        NoteActionItem(label: '이슈 트래커 칸반 스펙 문서화 (민재)'),
        NoteActionItem(label: '음성 채널 인원 제한 정책 확정 (서연)'),
      ],
    ),
    Note(
      id: 1,
      title: '디자인 시스템 리뷰',
      tags: ['리뷰'],
      summary: '컬러·타이포 토큰 확정, 공통 컴포넌트 17종 스펙 검토. Pretendard 적용 및 다크 테마 기준 합의.',
      author: NoteAuthor(
        authorId: 2,
        name: '도윤',
        initial: '도',
        date: '03.08',
      ),
    ),
    Note(
      id: 2,
      title: '음성 채널 기술 검토',
      tags: ['확정', '기술'],
      summary: 'WebRTC 직접 구현 vs 외부 SDK 비교. 동시 접속 인원 제한 정책 논의 — 채널 설정에서 선택 적용하기로.',
      author: NoteAuthor(
        authorId: 3,
        name: '서연',
        initial: '서',
        date: '03.05',
      ),
    ),
    Note(
      id: 3,
      title: '스프린트 회고 #3',
      tags: ['회고'],
      summary: '완료 항목 점검 및 블로커 정리. 다음 스프린트 칸반 백로그 재배치, 웹훅 보안 모드 우선순위 상향.',
      author: NoteAuthor(
        authorId: 4,
        name: '민재',
        initial: '민',
        date: '02.28',
      ),
    ),
  ];
}
