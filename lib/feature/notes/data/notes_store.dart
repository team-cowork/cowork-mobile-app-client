import '../domain/note.dart';

/// 회의록 목(mock) 데이터 저장소.
///
/// 백엔드 연동 전까지 정적 시드 데이터를 반환한다.
/// 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.
class NotesStore {
  NotesStore._();

  static final NotesStore instance = NotesStore._();

  List<Note> get notes => const [
    Note(
      title: '2026 1분기 킥오프 회의',
      tags: ['확정', 'OKR'],
      summary: '분기 목표 정렬 및 팀별 OKR 확정. 채팅·이슈 트래커 MVP 범위 합의, 음성 채널은 입장/대화만 포함하기로 결정.',
      author: NoteAuthor(
        name: 'junjuny',
        initial: '준',
        date: '03.12',
      ),
    ),
    Note(
      title: '디자인 시스템 리뷰',
      tags: ['리뷰'],
      summary: '컬러·타이포 토큰 확정, 공통 컴포넌트 17종 스펙 검토. Pretendard 적용 및 다크 테마 기준 합의.',
      author: NoteAuthor(
        name: '도윤',
        initial: '도',
        date: '03.08',
      ),
    ),
    Note(
      title: '음성 채널 기술 검토',
      tags: ['확정', '기술'],
      summary: 'WebRTC 직접 구현 vs 외부 SDK 비교. 동시 접속 인원 제한 정책 논의 — 채널 설정에서 선택 적용하기로.',
      author: NoteAuthor(
        name: '서연',
        initial: '서',
        date: '03.05',
      ),
    ),
    Note(
      title: '스프린트 회고 #3',
      tags: ['회고'],
      summary: '완료 항목 점검 및 블로커 정리. 다음 스프린트 칸반 백로그 재배치, 웹훅 보안 모드 우선순위 상향.',
      author: NoteAuthor(
        name: '민재',
        initial: '민',
        date: '02.28',
      ),
    ),
  ];
}
